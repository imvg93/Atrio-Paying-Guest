package com.atrio.pg.common.pagination;

import java.util.List;
import java.util.function.Function;
import org.springframework.data.domain.Page;

/**
 * The list payload shape from CLAUDE.md 3.11:
 * <pre>{ "items": [...], "page": 1, "limit": 20, "total": 0 }</pre>
 *
 * <p>Wrapped by {@code SuccessBodyAdvice} into
 * {@code { "success": true, "data": { ... } }}.
 *
 * <p>Deliberately not Spring's {@code Page} JSON, which exposes a different
 * (and unstable) shape.
 */
public record PagedResponse<T>(List<T> items, int page, int limit, long total) {

    public static <T> PagedResponse<T> from(Page<T> page) {
        return new PagedResponse<>(
                page.getContent(),
                page.getNumber() + 1,
                page.getSize(),
                page.getTotalElements());
    }

    public static <E, T> PagedResponse<T> from(Page<E> page, Function<E, T> mapper) {
        return new PagedResponse<>(
                page.getContent().stream().map(mapper).toList(),
                page.getNumber() + 1,
                page.getSize(),
                page.getTotalElements());
    }
}
