package com.atrio.pg.auth.service;

import static com.atrio.pg.support.AuthTestFixtures.properties;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.atrio.pg.auth.domain.OtpCode;
import com.atrio.pg.auth.repository.OtpCodeRepository;
import com.atrio.pg.auth.sms.SmsSender;
import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.exception.ErrorCode;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class OtpServiceTest {

    private static final String PHONE = "+919876543210";
    private static final Instant NOW = Instant.parse("2026-07-25T10:00:00Z");

    @Mock private OtpCodeRepository otpCodeRepository;
    @Mock private OtpAttemptRecorder attemptRecorder;
    @Mock private SmsSender smsSender;

    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(4);

    private OtpService service() {
        return new OtpService(
                otpCodeRepository, attemptRecorder, passwordEncoder, smsSender, properties());
    }

    private OtpCode storedCode(String plaintext, Instant expiresAt, int attempts) {
        OtpCode code = new OtpCode();
        code.setId(UUID.randomUUID());
        code.setPhone(PHONE);
        code.setCodeHash(passwordEncoder.encode(plaintext));
        code.setExpiresAt(expiresAt);
        code.setAttempts(attempts);
        return code;
    }

    @Test
    @DisplayName("issue stores only a hash and hands the plaintext to the sender")
    void issueHashesAndSends() {
        when(otpCodeRepository.countByPhoneAndCreatedAtAfter(eq(PHONE), any())).thenReturn(0L);

        service().issue(PHONE, NOW);

        ArgumentCaptor<OtpCode> saved = ArgumentCaptor.forClass(OtpCode.class);
        verify(otpCodeRepository).save(saved.capture());
        ArgumentCaptor<String> sent = ArgumentCaptor.forClass(String.class);
        verify(smsSender).sendOtp(eq(PHONE), sent.capture());

        assertThat(sent.getValue()).matches("\\d{6}");
        assertThat(saved.getValue().getCodeHash())
                .as("plaintext must never reach the database")
                .isNotEqualTo(sent.getValue())
                .startsWith("$2");
        assertThat(saved.getValue().getExpiresAt()).isEqualTo(NOW.plusSeconds(300));
    }

    @Test
    @DisplayName("the fourth request inside the window is rate limited and sends nothing")
    void rateLimited() {
        when(otpCodeRepository.countByPhoneAndCreatedAtAfter(eq(PHONE), any())).thenReturn(3L);

        assertThatThrownBy(() -> service().issue(PHONE, NOW))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.PHONE_RATE_LIMITED);

        verify(otpCodeRepository, never()).save(any());
        verify(smsSender, never()).sendOtp(anyString(), anyString());
    }

    @Test
    @DisplayName("the correct code is consumed exactly once")
    void verifyConsumes() {
        OtpCode stored = storedCode("123456", NOW.plusSeconds(60), 0);
        when(otpCodeRepository.findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(PHONE))
                .thenReturn(Optional.of(stored));

        service().verify(PHONE, "123456", NOW);

        assertThat(stored.getConsumedAt()).isEqualTo(NOW);
        verify(otpCodeRepository).save(stored);
    }

    @Test
    @DisplayName("a wrong code is recorded as an attempt and then rejected")
    void wrongCodeRecordsAttempt() {
        OtpCode stored = storedCode("123456", NOW.plusSeconds(60), 0);
        when(otpCodeRepository.findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(PHONE))
                .thenReturn(Optional.of(stored));
        when(attemptRecorder.recordFailure(stored.getId())).thenReturn(1);

        assertThatThrownBy(() -> service().verify(PHONE, "999999", NOW))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.OTP_INVALID);

        // Recording the attempt must go through the REQUIRES_NEW recorder,
        // or the throw below would roll the increment back and the attempt
        // cap would never bite.
        verify(attemptRecorder).recordFailure(stored.getId());
        assertThat(stored.getConsumedAt()).isNull();
    }

    @Test
    @DisplayName("the attempt that reaches the cap reports OTP_MAX_ATTEMPTS")
    void attemptReachingCap() {
        OtpCode stored = storedCode("123456", NOW.plusSeconds(60), 4);
        when(otpCodeRepository.findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(PHONE))
                .thenReturn(Optional.of(stored));
        when(attemptRecorder.recordFailure(stored.getId())).thenReturn(5);

        assertThatThrownBy(() -> service().verify(PHONE, "999999", NOW))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.OTP_MAX_ATTEMPTS);
    }

    @Test
    @DisplayName("a capped code stays dead even when the right code is finally supplied")
    void cappedCodeRejectsCorrectCode() {
        OtpCode stored = storedCode("123456", NOW.plusSeconds(60), 5);
        when(otpCodeRepository.findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(PHONE))
                .thenReturn(Optional.of(stored));

        assertThatThrownBy(() -> service().verify(PHONE, "123456", NOW))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.OTP_MAX_ATTEMPTS);

        assertThat(stored.getConsumedAt()).isNull();
    }

    @Test
    @DisplayName("an expired code is rejected without burning an attempt")
    void expiredCode() {
        OtpCode stored = storedCode("123456", NOW.minusSeconds(1), 0);
        when(otpCodeRepository.findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(PHONE))
                .thenReturn(Optional.of(stored));

        assertThatThrownBy(() -> service().verify(PHONE, "123456", NOW))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.OTP_EXPIRED);

        verify(attemptRecorder, never()).recordFailure(any());
    }

    @Test
    @DisplayName("verifying with no live code at all is OTP_INVALID")
    void noLiveCode() {
        when(otpCodeRepository.findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(PHONE))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service().verify(PHONE, "123456", NOW))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.OTP_INVALID);
    }
}
