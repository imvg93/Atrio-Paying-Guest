package com.atrio.pg.auth.security;

import com.atrio.pg.users.domain.User;
import com.atrio.pg.users.domain.UserRole;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.Optional;
import java.util.UUID;
import javax.crypto.SecretKey;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Issues and verifies HS256 access tokens (MIGRATION_PLAN.md 6.2).
 *
 * <p>The secret is used as <strong>raw UTF-8 bytes</strong>, not base64-decoded
 * - that is what {@code @nestjs/jwt} would have done, and the choice is
 * permanent once tokens are in the wild.
 *
 * <p>Refresh tokens are deliberately <em>not</em> JWTs. They are opaque random
 * values stored hashed, so they can be revoked server-side; see
 * {@link RefreshTokenHasher}.
 */
@Service
@Slf4j
public class JwtService {

    private static final String CLAIM_ROLE = "role";
    private static final String CLAIM_PHONE = "phone";

    private final SecretKey accessKey;
    private final Duration accessTtl;

    public JwtService(AuthProperties properties) {
        this.accessKey = Keys.hmacShaKeyFor(
                properties.jwt().accessSecret().getBytes(StandardCharsets.UTF_8));
        this.accessTtl = properties.jwt().accessTtl();
    }

    public Duration accessTtl() {
        return accessTtl;
    }

    /** Signs an access token for {@code user}, valid for {@link #accessTtl()}. */
    public String issueAccessToken(User user, Instant now) {
        Instant expiry = now.plus(accessTtl);
        return Jwts.builder()
                .subject(user.getId().toString())
                .claim(CLAIM_ROLE, user.getRole().dbValue())
                .claim(CLAIM_PHONE, user.getPhone())
                .id(UUID.randomUUID().toString())
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiry))
                // HS256 explicitly. The one-argument signWith() derives the
                // algorithm from key length, and the configured 64-character
                // secret is 512 bits, so it would silently produce HS512.
                .signWith(accessKey, Jwts.SIG.HS256)
                .compact();
    }

    /**
     * Verifies signature and expiry and rebuilds the principal.
     *
     * <p>Returns empty rather than throwing on any invalid token: the filter
     * simply leaves the request unauthenticated and
     * {@code RestAuthenticationEntryPoint} renders the 401 envelope. Throwing
     * here would produce Spring's default error body instead.
     */
    public Optional<AppUserPrincipal> parseAccessToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(accessKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            return Optional.of(new AppUserPrincipal(
                    UUID.fromString(claims.getSubject()),
                    claims.get(CLAIM_PHONE, String.class),
                    UserRole.from(claims.get(CLAIM_ROLE, String.class))));
        } catch (JwtException | IllegalArgumentException e) {
            log.debug("Rejected access token: {}", e.getMessage());
            return Optional.empty();
        }
    }
}
