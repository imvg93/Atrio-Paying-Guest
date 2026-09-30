package com.atrio.pg.auth.security;

import static com.atrio.pg.support.AuthTestFixtures.properties;
import static com.atrio.pg.support.AuthTestFixtures.user;
import static org.assertj.core.api.Assertions.assertThat;

import com.atrio.pg.users.domain.User;
import com.atrio.pg.users.domain.UserRole;
import java.time.Duration;
import java.time.Instant;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class JwtServiceTest {

    private final JwtService jwtService = new JwtService(properties());

    @Test
    @DisplayName("a freshly issued token parses back to the same principal")
    void roundTrip() {
        User user = user("+919876543210", UserRole.OWNER);

        String token = jwtService.issueAccessToken(user, Instant.now());

        assertThat(jwtService.parseAccessToken(token))
                .hasValueSatisfying(principal -> {
                    assertThat(principal.id()).isEqualTo(user.getId());
                    assertThat(principal.phone()).isEqualTo("+919876543210");
                    assertThat(principal.role()).isEqualTo(UserRole.OWNER);
                });
    }

    @Test
    @DisplayName("tokens are signed with HS256, not whatever the key length implies")
    void algorithmIsHs256() {
        String token = jwtService.issueAccessToken(user("+919876543210", UserRole.STUDENT), Instant.now());

        String header = new String(java.util.Base64.getUrlDecoder()
                .decode(token.split("\\.")[0]));

        // The configured secrets are 64 characters, so jjwt's key-length
        // inference would pick HS512 unless the algorithm is stated.
        assertThat(header).contains("\"alg\":\"HS256\"");
    }

    @Test
    @DisplayName("the role claim is the lowercase database label, not the Java constant")
    void roleClaimUsesDbLabel() {
        String token = jwtService.issueAccessToken(user("+919876543210", UserRole.OWNER), Instant.now());

        String payload = new String(java.util.Base64.getUrlDecoder()
                .decode(token.split("\\.")[1]));

        assertThat(payload).contains("\"role\":\"owner\"");
    }

    @Test
    @DisplayName("an expired token is rejected")
    void expiredTokenRejected() {
        JwtService shortLived = new JwtService(properties(Duration.ofSeconds(1)));
        String token = shortLived.issueAccessToken(
                user("+919876543210", UserRole.STUDENT),
                Instant.now().minusSeconds(120));

        assertThat(shortLived.parseAccessToken(token)).isEmpty();
    }

    @Test
    @DisplayName("a token signed with another secret is rejected")
    void foreignSignatureRejected() {
        AuthProperties other = new AuthProperties(
                new AuthProperties.Jwt(
                        "a-completely-different-secret-of-sufficient-length-xxxxxxxx",
                        Duration.ofMinutes(15),
                        "another-refresh-secret-of-sufficient-length-yyyyyyyyyyyyyy",
                        Duration.ofDays(30)),
                properties().otp());
        String foreign = new JwtService(other)
                .issueAccessToken(user("+919876543210", UserRole.STUDENT), Instant.now());

        assertThat(jwtService.parseAccessToken(foreign)).isEmpty();
    }

    @Test
    @DisplayName("a tampered payload is rejected rather than trusted")
    void tamperedTokenRejected() {
        String token = jwtService.issueAccessToken(
                user("+919876543210", UserRole.STUDENT), Instant.now());
        String[] parts = token.split("\\.");
        String forgedPayload = java.util.Base64.getUrlEncoder().withoutPadding()
                .encodeToString(new String(java.util.Base64.getUrlDecoder().decode(parts[1]))
                        .replace("\"role\":\"student\"", "\"role\":\"admin\"")
                        .getBytes());

        assertThat(jwtService.parseAccessToken(parts[0] + "." + forgedPayload + "." + parts[2]))
                .isEmpty();
    }

    @Test
    @DisplayName("structural garbage is rejected without throwing")
    void garbageRejected() {
        assertThat(jwtService.parseAccessToken("not.a.jwt")).isEmpty();
        assertThat(jwtService.parseAccessToken("")).isEmpty();
    }
}
