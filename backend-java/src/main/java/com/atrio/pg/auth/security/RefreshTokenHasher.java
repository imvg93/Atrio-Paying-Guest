package com.atrio.pg.auth.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.stereotype.Component;

/**
 * Mints opaque refresh tokens and reduces them to the digest stored in
 * {@code refresh_tokens.token_hash}.
 *
 * <p><strong>The digest must be deterministic.</strong> The refresh flow looks
 * a token up <em>by its hash</em> through the partial unique index
 * {@code uq_refresh_tokens_token_hash}. BCrypt - correct for
 * {@code otp_codes.code_hash} - is salted, so every hash of the same token
 * differs: lookup would always miss and the unique index would mean nothing.
 * This is the one place in the schema where the two hashed columns demand
 * different algorithms (MIGRATION_PLAN.md 6.3).
 *
 * <p>HMAC-SHA256 keyed with {@code JWT_REFRESH_SECRET} rather than a bare
 * SHA-256, so a stolen database dump alone cannot be scanned for a token whose
 * plaintext an attacker already holds. Safe against brute force because the
 * token is 256 bits of {@link SecureRandom} output, not a guessable secret.
 */
@Component
public class RefreshTokenHasher {

    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private static final int TOKEN_BYTES = 32;

    private final SecureRandom random = new SecureRandom();
    private final SecretKeySpec key;

    public RefreshTokenHasher(AuthProperties properties) {
        this.key = new SecretKeySpec(
                properties.jwt().refreshSecret().getBytes(StandardCharsets.UTF_8),
                HMAC_ALGORITHM);
    }

    /** A fresh 256-bit token, URL-safe so it survives any transport. */
    public String newToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /** Base64 of HMAC-SHA256(token) - 44 chars, well inside varchar(255). */
    public String hash(String token) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(key);
            byte[] digest = mac.doFinal(token.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(digest);
        } catch (java.security.GeneralSecurityException e) {
            // Both HmacSHA256 and a non-empty key are guaranteed present.
            throw new IllegalStateException("Refresh token hashing is unavailable", e);
        }
    }

    /** Constant-time comparison, for callers that compare two digests. */
    public boolean matches(String token, String expectedHash) {
        return MessageDigest.isEqual(
                hash(token).getBytes(StandardCharsets.UTF_8),
                expectedHash.getBytes(StandardCharsets.UTF_8));
    }
}
