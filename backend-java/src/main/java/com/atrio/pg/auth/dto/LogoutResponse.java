package com.atrio.pg.auth.dto;

/**
 * Response of {@code POST /auth/logout}.
 *
 * <p>Always {@code true}, and deliberately so: logout is idempotent and does
 * not report whether the presented token was live, already revoked, or unknown.
 * Distinguishing those would let a caller probe which tokens exist.
 */
public record LogoutResponse(boolean loggedOut) {

    public static LogoutResponse done() {
        return new LogoutResponse(true);
    }
}
