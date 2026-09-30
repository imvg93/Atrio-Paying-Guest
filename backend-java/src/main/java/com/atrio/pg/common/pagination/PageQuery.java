package com.atrio.pg.common.pagination;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

/**
 * Query parameters every list endpoint accepts (CLAUDE.md 3.11).
 * Default limit 20, max 100 - identical to the NestJS PaginationQueryDto.
 */
public record PageQuery(
        @Min(1) Integer page,
        @Min(1) @Max(100) Integer limit) {

    public static final int DEFAULT_PAGE = 1;
    public static final int DEFAULT_LIMIT = 20;

    public PageQuery {
        page = page == null ? DEFAULT_PAGE : page;
        limit = limit == null ? DEFAULT_LIMIT : limit;
    }

    public int pageOrDefault() {
        return page == null ? DEFAULT_PAGE : page;
    }

    public int limitOrDefault() {
        return limit == null ? DEFAULT_LIMIT : limit;
    }

    /** Spring Data pages are zero-based; the API contract is one-based. */
    public int zeroBasedPage() {
        return pageOrDefault() - 1;
    }

    public int skip() {
        return zeroBasedPage() * limitOrDefault();
    }
}
