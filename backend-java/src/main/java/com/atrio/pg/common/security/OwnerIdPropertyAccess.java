package com.atrio.pg.common.security;

import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.exception.ErrorCode;
import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.properties.repository.PropertyRepository;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * The rule while a property has exactly one owner: access means
 * {@code properties.owner_id == caller}.
 *
 * <p>Replaced wholesale if staff sub-accounts ever land - which is the entire
 * reason {@link PropertyAccess} is an interface.
 *
 * <p>A property owned by somebody else is {@code 403 PROPERTY_NOT_OWNED}, not
 * {@code 404}, following the convention set in docs/CURRENT_STATE.md 4.5.
 * Hiding it behind a 404 would buy nothing here: ids are random UUIDs, so there
 * is no enumeration to defend against, and the honest status is far easier to
 * act on from the client and to read in a log.
 *
 * <p>Soft-deleted properties are invisible to the repository
 * ({@code @SQLRestriction}), so they surface as {@code 404} - which is correct.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class OwnerIdPropertyAccess implements PropertyAccess {

    private final PropertyRepository propertyRepository;

    @Override
    @Transactional(readOnly = true)
    public Property require(UUID callerId, UUID propertyId) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> ApiException.notFound(
                        "Property %s was not found.".formatted(propertyId)));

        if (!property.getOwnerId().equals(callerId)) {
            log.warn("User {} attempted to access property {} owned by {}",
                    callerId, propertyId, property.getOwnerId());
            throw new ApiException(
                    ErrorCode.PROPERTY_NOT_OWNED,
                    "This property belongs to another account.");
        }
        return property;
    }

    @Override
    @Transactional(readOnly = true)
    public void requireAccess(UUID callerId, UUID propertyId) {
        require(callerId, propertyId);
    }
}
