package com.atrio.pg.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Every error code the API can return. Mirrors the NestJS
 * {@code AllExceptionsFilter} status-to-code map exactly, so the wire contract
 * is unchanged.
 *
 * <p>Domain-specific codes (OTP_EXPIRED, PHONE_RATE_LIMITED, ...) are added
 * here as each domain lands; the NestJS side never defined any.
 */
public enum ErrorCode {

    BAD_REQUEST(HttpStatus.BAD_REQUEST),
    VALIDATION_ERROR(HttpStatus.BAD_REQUEST),
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED),
    FORBIDDEN(HttpStatus.FORBIDDEN),
    NOT_FOUND(HttpStatus.NOT_FOUND),
    CONFLICT(HttpStatus.CONFLICT),
    UNPROCESSABLE_ENTITY(HttpStatus.UNPROCESSABLE_ENTITY),
    TOO_MANY_REQUESTS(HttpStatus.TOO_MANY_REQUESTS),
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR),
    /** Fallback for an HTTP status with no dedicated code. */
    HTTP_ERROR(HttpStatus.INTERNAL_SERVER_ERROR),

    // ---- auth domain (Step 1) ----------------------------------------
    // The mobile client branches on these strings, so they are contract:
    // app/lib/core/network/api_exception.dart must stay in step with them.

    /** No live code for this phone, or the code did not match. */
    OTP_INVALID(HttpStatus.BAD_REQUEST),
    /** The code existed but is past {@code expires_at}. */
    OTP_EXPIRED(HttpStatus.BAD_REQUEST),
    /** Too many wrong guesses against one code. A new code must be requested. */
    OTP_MAX_ATTEMPTS(HttpStatus.TOO_MANY_REQUESTS),
    /** More than OTP_REQUEST_LIMIT codes requested for a phone in the window. */
    PHONE_RATE_LIMITED(HttpStatus.TOO_MANY_REQUESTS),

    /** Unknown, expired, or already-superseded refresh token. */
    REFRESH_TOKEN_INVALID(HttpStatus.UNAUTHORIZED),
    /**
     * A revoked refresh token was presented, which means it leaked. The whole
     * family is revoked and the user must sign in again.
     */
    REFRESH_TOKEN_REUSED(HttpStatus.UNAUTHORIZED),

    /** PATCH /auth/profile tried to change a role that is already locked. */
    ROLE_ALREADY_SET(HttpStatus.CONFLICT),
    /** Another live account already holds this email (compared lowercased). */
    EMAIL_TAKEN(HttpStatus.CONFLICT),
    /** The account exists but {@code is_active} is false. */
    ACCOUNT_DISABLED(HttpStatus.FORBIDDEN),

    /** No SMS provider is configured, so a code cannot be delivered. */
    SMS_DELIVERY_UNAVAILABLE(HttpStatus.SERVICE_UNAVAILABLE),

    // ---- ownership (Wave 0) ------------------------------------------
    /**
     * The property exists but belongs to another account. Distinct from
     * FORBIDDEN so the client can say something useful rather than "denied".
     */
    PROPERTY_NOT_OWNED(HttpStatus.FORBIDDEN);

    private final HttpStatus status;

    ErrorCode(HttpStatus status) {
        this.status = status;
    }

    public HttpStatus status() {
        return status;
    }

    /** Maps a status back to its canonical code, as the NestJS filter did. */
    public static ErrorCode forStatus(HttpStatus status) {
        return switch (status) {
            case BAD_REQUEST -> BAD_REQUEST;
            case UNAUTHORIZED -> UNAUTHORIZED;
            case FORBIDDEN -> FORBIDDEN;
            case NOT_FOUND -> NOT_FOUND;
            case CONFLICT -> CONFLICT;
            case UNPROCESSABLE_ENTITY -> UNPROCESSABLE_ENTITY;
            case TOO_MANY_REQUESTS -> TOO_MANY_REQUESTS;
            case INTERNAL_SERVER_ERROR -> INTERNAL_ERROR;
            default -> HTTP_ERROR;
        };
    }
}
