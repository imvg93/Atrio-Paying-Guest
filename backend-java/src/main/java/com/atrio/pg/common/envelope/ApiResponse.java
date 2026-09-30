package com.atrio.pg.common.envelope;

/**
 * The success half of the envelope from CLAUDE.md 3.10:
 * <pre>{ "success": true, "data": { ... } }</pre>
 */
public record ApiResponse<T>(boolean success, T data) {

    public static <T> ApiResponse<T> of(T data) {
        return new ApiResponse<>(true, data);
    }
}
