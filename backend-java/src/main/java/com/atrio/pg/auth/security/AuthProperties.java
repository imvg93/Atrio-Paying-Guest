package com.atrio.pg.auth.security;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/**
 * Auth configuration, bound from the same env var names the NestJS backend
 * used ({@code JWT_*}, {@code OTP_*}) so deployment config is unchanged
 * (MIGRATION_PLAN.md 6.4). Bean Validation here replaces the Joi schema and
 * keeps the fail-fast-at-boot behaviour.
 *
 * @param jwt token signing and lifetimes
 * @param otp one-time-code policy
 */
@Validated
@ConfigurationProperties(prefix = "atrio.auth")
public record AuthProperties(@Valid @NotNull Jwt jwt, @Valid @NotNull Otp otp) {

    /**
     * @param accessSecret  HMAC key for access tokens, used as raw UTF-8 bytes
     * @param accessTtl     access token lifetime, e.g. {@code 15m}
     * @param refreshSecret HMAC key for the refresh-token digest (see
     *                      {@link RefreshTokenHasher})
     * @param refreshTtl    refresh token lifetime, e.g. {@code 30d}
     */
    public record Jwt(
            @NotBlank @Size(min = 32, message = "must be at least 32 characters for HS256")
            String accessSecret,
            @NotNull Duration accessTtl,
            @NotBlank @Size(min = 32, message = "must be at least 32 characters")
            String refreshSecret,
            @NotNull Duration refreshTtl) {
    }

    /**
     * @param ttl                  how long a code stays valid
     * @param maxAttempts          wrong guesses allowed against one code
     * @param requestLimit         codes allowed per phone per {@code requestWindow}
     * @param requestWindow        the rate-limit window
     * @param codeLength           digits in a generated code
     */
    public record Otp(
            @NotNull Duration ttl,
            @Min(1) int maxAttempts,
            @Min(1) int requestLimit,
            @NotNull Duration requestWindow,
            @Min(4) int codeLength) {
    }
}
