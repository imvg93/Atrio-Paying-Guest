package com.atrio.pg.auth.service;

import com.atrio.pg.auth.domain.OtpCode;
import com.atrio.pg.auth.repository.OtpCodeRepository;
import com.atrio.pg.auth.security.AuthProperties;
import com.atrio.pg.auth.sms.SmsSender;
import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.exception.ErrorCode;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Issues and verifies one-time codes (MIGRATION_PLAN.md 6.1).
 *
 * <p>Codes are stored BCrypt-hashed. That is safe despite BCrypt being salted
 * because lookup is by {@code phone} - never by the hash - via
 * {@code idx_otp_codes_phone_created_at}. A 6-digit code is trivially
 * brute-forceable offline, so a slow salted hash is exactly right here, and
 * exactly wrong for refresh tokens.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OtpService {

    private final OtpCodeRepository otpCodeRepository;
    private final OtpAttemptRecorder attemptRecorder;
    private final PasswordEncoder passwordEncoder;
    private final SmsSender smsSender;
    private final AuthProperties properties;

    private final SecureRandom random = new SecureRandom();

    /**
     * Generates a code, stores its hash, and hands the plaintext to the sender.
     *
     * @return how long the issued code stays valid
     * @throws ApiException {@code PHONE_RATE_LIMITED} above the per-phone limit
     */
    @Transactional
    public Duration issue(String phone, Instant now) {
        enforceRequestRateLimit(phone, now);

        String code = generateCode();
        Duration ttl = properties.otp().ttl();

        OtpCode entity = new OtpCode();
        entity.setPhone(phone);
        entity.setCodeHash(passwordEncoder.encode(code));
        entity.setExpiresAt(now.plus(ttl));
        otpCodeRepository.save(entity);

        // Delivery is last: a send failure must not leave an unusable row
        // behind, and it must abort the request rather than report success.
        smsSender.sendOtp(phone, code);
        return ttl;
    }

    /**
     * Checks {@code code} against the newest unconsumed code for {@code phone}
     * and consumes it on success.
     *
     * <p>Order matters: the attempt cap is checked before expiry so a caller
     * that has already burned its attempts cannot learn anything more from the
     * error, and a wrong guess is recorded even though this method then throws
     * (see {@link OtpAttemptRecorder}).
     *
     * @throws ApiException {@code OTP_INVALID}, {@code OTP_EXPIRED} or
     *                      {@code OTP_MAX_ATTEMPTS}
     */
    @Transactional
    public void verify(String phone, String code, Instant now) {
        OtpCode otp = otpCodeRepository
                .findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(phone)
                .orElseThrow(() -> new ApiException(
                        ErrorCode.OTP_INVALID,
                        "That code is not valid. Request a new one."));

        if (otp.getAttempts() >= properties.otp().maxAttempts()) {
            throw maxAttempts();
        }
        if (otp.isExpired(now)) {
            throw new ApiException(
                    ErrorCode.OTP_EXPIRED, "That code has expired. Request a new one.");
        }

        if (!passwordEncoder.matches(code, otp.getCodeHash())) {
            int attempts = attemptRecorder.recordFailure(otp.getId());
            if (attempts >= properties.otp().maxAttempts()) {
                throw maxAttempts();
            }
            throw new ApiException(ErrorCode.OTP_INVALID, "That code is not correct.");
        }

        otp.setConsumedAt(now);
        otpCodeRepository.save(otp);
    }

    /**
     * CLAUDE.md 6: max 3 per phone per 10 minutes, from
     * {@code OTP_REQUEST_LIMIT} / {@code OTP_REQUEST_WINDOW_SECONDS}. Served by
     * the partial index {@code idx_otp_codes_phone_created_at}.
     */
    private void enforceRequestRateLimit(String phone, Instant now) {
        Instant windowStart = now.minus(properties.otp().requestWindow());
        long issued = otpCodeRepository.countByPhoneAndCreatedAtAfter(phone, windowStart);
        if (issued >= properties.otp().requestLimit()) {
            log.warn("OTP rate limit hit for {} ({} in window)", phone, issued);
            throw new ApiException(
                    ErrorCode.PHONE_RATE_LIMITED,
                    "Too many codes requested. Please wait a few minutes and try again.");
        }
    }

    private String generateCode() {
        int length = properties.otp().codeLength();
        StringBuilder code = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            code.append(random.nextInt(10));
        }
        return code.toString();
    }

    private ApiException maxAttempts() {
        return new ApiException(
                ErrorCode.OTP_MAX_ATTEMPTS,
                "Too many incorrect attempts. Request a new code.");
    }
}
