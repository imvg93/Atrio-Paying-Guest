package com.atrio.pg.common.envelope;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

/**
 * The failure half of the envelope from CLAUDE.md 3.10:
 * <pre>{ "success": false, "error": { "code": "...", "message": "..." } }</pre>
 *
 * <p>{@code details} is present only for validation failures, matching the
 * NestJS filter, which added it solely when the ValidationPipe returned an
 * array of constraint messages.
 */
public record ApiError(boolean success, Detail error) {

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record Detail(String code, String message, List<String> details) {
    }

    public static ApiError of(String code, String message) {
        return new ApiError(false, new Detail(code, message, null));
    }

    public static ApiError of(String code, String message, List<String> details) {
        return new ApiError(false, new Detail(code, message, details));
    }
}
