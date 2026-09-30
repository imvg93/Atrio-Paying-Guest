package com.atrio.pg.support;

import com.atrio.pg.auth.security.AuthProperties;
import com.atrio.pg.users.domain.User;
import com.atrio.pg.users.domain.UserRole;
import java.time.Duration;
import java.util.UUID;

/** Shared builders so each test states only what it actually cares about. */
public final class AuthTestFixtures {

    /** 64 chars, mirroring the shape of a real base64-encoded 48-byte secret. */
    public static final String ACCESS_SECRET =
            "test-access-secret-that-is-long-enough-for-hs256-aaaaaaaaaaaaaaaa";
    public static final String REFRESH_SECRET =
            "test-refresh-secret-that-is-long-enough-for-hmac-bbbbbbbbbbbbbbbb";

    private AuthTestFixtures() {
    }

    public static AuthProperties properties() {
        return properties(Duration.ofMinutes(15));
    }

    public static AuthProperties properties(Duration accessTtl) {
        return new AuthProperties(
                new AuthProperties.Jwt(
                        ACCESS_SECRET, accessTtl, REFRESH_SECRET, Duration.ofDays(30)),
                new AuthProperties.Otp(
                        Duration.ofSeconds(300), 5, 3, Duration.ofSeconds(600), 6));
    }

    public static User user(String phone, UserRole role) {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setPhone(phone);
        user.setRole(role);
        user.setActive(true);
        return user;
    }
}
