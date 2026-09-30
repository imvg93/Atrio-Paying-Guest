package com.atrio.pg.auth.service;

import com.atrio.pg.auth.domain.RefreshToken;
import com.atrio.pg.auth.repository.RefreshTokenRepository;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Revokes every live refresh token for a user, in its own transaction.
 *
 * <p>Same reasoning as {@link OtpAttemptRecorder}: reuse detection must revoke
 * the family <em>and</em> fail the request, and the exception that fails the
 * request would otherwise roll the revocation back - leaving a token an
 * attacker is demonstrably holding still valid. That is the exact opposite of
 * what reuse detection is for.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RefreshTokenFamilyRevoker {

    private final RefreshTokenRepository refreshTokenRepository;

    /** @return how many tokens were revoked */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public int revokeAllForUser(UUID userId, Instant now) {
        List<RefreshToken> live = refreshTokenRepository.findAllByUserIdAndRevokedAtIsNull(userId);
        live.forEach(token -> token.setRevokedAt(now));
        refreshTokenRepository.saveAll(live);
        log.warn("Refresh token reuse detected for user {}; revoked {} live token(s)",
                userId, live.size());
        return live.size();
    }
}
