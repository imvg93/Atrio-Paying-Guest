package com.atrio.pg.auth.service;

import com.atrio.pg.auth.domain.OtpCode;
import com.atrio.pg.auth.repository.OtpCodeRepository;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Increments {@code otp_codes.attempts} in its own transaction.
 *
 * <p>This exists for one reason, and it is not style. A wrong code must both
 * <em>record the attempt</em> and <em>fail the request</em>, but a
 * {@code RuntimeException} thrown from the verify path rolls its transaction
 * back - taking the increment with it. The attempt cap would then never bite
 * and the code could be brute-forced indefinitely.
 *
 * <p>{@code REQUIRES_NEW} suspends the caller's transaction and commits the
 * increment on its own. It is a separate bean because Spring's proxying ignores
 * self-invocation, so an in-class call would silently do nothing.
 */
@Service
@RequiredArgsConstructor
public class OtpAttemptRecorder {

    private final OtpCodeRepository otpCodeRepository;

    /** @return the attempt count after the increment */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public int recordFailure(UUID otpCodeId) {
        OtpCode code = otpCodeRepository.findById(otpCodeId).orElse(null);
        if (code == null) {
            return 0;
        }
        code.setAttempts(code.getAttempts() + 1);
        otpCodeRepository.save(code);
        return code.getAttempts();
    }
}
