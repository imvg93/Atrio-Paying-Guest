package com.atrio.pg.common.security;

import com.atrio.pg.properties.domain.Property;
import java.util.UUID;

/**
 * Decides whether a caller may act on a property.
 *
 * <p>CLAUDE.md 3.13 puts ownership checks in services, never controllers - a
 * role guard answers "is this an owner?", which is not the same question as "is
 * this <em>their</em> property?".
 *
 * <p><strong>Why this is an interface for a one-line rule.</strong> Today
 * access means {@code property.owner_id == caller}. The moment staff or manager
 * sub-accounts exist it becomes a membership lookup, and every call site would
 * otherwise have to change. Every owner endpoint from Wave 1 onward routes
 * through here, so the rule stays replaceable at one seam rather than spread
 * across a dozen services. See the plan's note on {@code property_members}.
 *
 * <p>Implementations must throw rather than return false: a caller that forgets
 * to check the result then fails closed.
 */
public interface PropertyAccess {

    /**
     * Loads a property the caller is allowed to act on.
     *
     * @throws com.atrio.pg.common.exception.ApiException {@code NOT_FOUND} when
     *         the property does not exist or is soft-deleted, {@code FORBIDDEN}
     *         when it exists but belongs to somebody else
     */
    Property require(UUID callerId, UUID propertyId);

    /**
     * Asserts access without loading the row, for callers that already hold the
     * property or only need the check.
     */
    void requireAccess(UUID callerId, UUID propertyId);
}
