package com.atrio.pg.auth.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Body of {@code POST /auth/refresh} and {@code POST /auth/logout}.
 *
 * <p>The refresh token travels in the body rather than the {@code Authorization}
 * header so it is never confused with the access token by a proxy, a log, or
 * the client's own interceptor.
 */
public record RefreshRequest(@NotBlank(message = "is required") String refreshToken) {
}
