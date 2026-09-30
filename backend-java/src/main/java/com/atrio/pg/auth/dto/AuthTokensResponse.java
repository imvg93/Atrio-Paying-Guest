package com.atrio.pg.auth.dto;

import com.atrio.pg.users.dto.UserResponse;

/**
 * Response of {@code POST /auth/otp/verify} and {@code POST /auth/refresh}.
 *
 * <p>Shape is fixed by CLAUDE.md 6 and by
 * {@code app/lib/features/auth/data/models/auth_tokens.dart}:
 * {@code { accessToken, refreshToken, user, isNewUser }}.
 *
 * @param isNewUser true only when this verify created the account, so the
 *                  client can tell first sign-in from a returning user
 */
public record AuthTokensResponse(
        String accessToken,
        String refreshToken,
        UserResponse user,
        boolean isNewUser) {
}
