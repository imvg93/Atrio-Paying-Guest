package com.atrio.pg.auth.security;

import static com.atrio.pg.support.AuthTestFixtures.properties;
import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class RefreshTokenHasherTest {

    private final RefreshTokenHasher hasher = new RefreshTokenHasher(properties());

    @Test
    @DisplayName("hashing is deterministic, which is what lookup-by-hash requires")
    void deterministic() {
        String token = hasher.newToken();

        // The whole refresh design rests on this: uq_refresh_tokens_token_hash
        // is looked up by the digest, so a salted hash (BCrypt) would never
        // match and the unique index would be meaningless.
        assertThat(hasher.hash(token)).isEqualTo(hasher.hash(token));
    }

    @Test
    @DisplayName("distinct tokens hash distinctly, and the digest fits the column")
    void distinctAndSized() {
        String a = hasher.newToken();
        String b = hasher.newToken();

        assertThat(a).isNotEqualTo(b);
        assertThat(hasher.hash(a)).isNotEqualTo(hasher.hash(b));
        // refresh_tokens.token_hash is varchar(255).
        assertThat(hasher.hash(a)).hasSize(44);
    }

    @Test
    @DisplayName("tokens carry 256 bits of entropy")
    void tokenEntropy() {
        String token = hasher.newToken();

        assertThat(token).hasSize(43); // 32 bytes, base64url, unpadded
        assertThat(token).doesNotContain("=", "+", "/");
    }

    @Test
    @DisplayName("the digest is keyed, so a different pepper yields a different hash")
    void keyedByRefreshSecret() {
        String token = hasher.newToken();
        AuthProperties otherPepper = new AuthProperties(
                new AuthProperties.Jwt(
                        properties().jwt().accessSecret(),
                        properties().jwt().accessTtl(),
                        "a-different-refresh-pepper-of-sufficient-length-zzzzzzzzzz",
                        properties().jwt().refreshTtl()),
                properties().otp());

        assertThat(new RefreshTokenHasher(otherPepper).hash(token))
                .isNotEqualTo(hasher.hash(token));
    }

    @Test
    @DisplayName("matches() compares a token against a stored digest")
    void matches() {
        String token = hasher.newToken();

        assertThat(hasher.matches(token, hasher.hash(token))).isTrue();
        assertThat(hasher.matches(hasher.newToken(), hasher.hash(token))).isFalse();
    }
}
