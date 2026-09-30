package com.atrio.pg.common.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

/**
 * Base class for deliberate domain errors. Carrying its own {@link ErrorCode}
 * reproduces the NestJS convention where a thrown exception could override the
 * status-derived code via a {@code code} property on its response body.
 */
@Getter
public class ApiException extends RuntimeException {

    private final ErrorCode code;
    private final HttpStatus status;

    public ApiException(ErrorCode code, String message) {
        this(code, code.status(), message);
    }

    public ApiException(ErrorCode code, HttpStatus status, String message) {
        super(message);
        this.code = code;
        this.status = status;
    }

    public static ApiException notFound(String message) {
        return new ApiException(ErrorCode.NOT_FOUND, message);
    }

    public static ApiException forbidden(String message) {
        return new ApiException(ErrorCode.FORBIDDEN, message);
    }

    public static ApiException conflict(String message) {
        return new ApiException(ErrorCode.CONFLICT, message);
    }

    public static ApiException badRequest(String message) {
        return new ApiException(ErrorCode.BAD_REQUEST, message);
    }
}
