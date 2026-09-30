package com.atrio.pg.common.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.exception.ErrorCode;
import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.properties.repository.PropertyRepository;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class OwnerIdPropertyAccessTest {

    @Mock private PropertyRepository propertyRepository;
    @InjectMocks private OwnerIdPropertyAccess access;

    private Property propertyOwnedBy(UUID ownerId) {
        Property property = new Property();
        property.setId(UUID.randomUUID());
        property.setOwnerId(ownerId);
        property.setName("Sunrise PG");
        return property;
    }

    @Test
    @DisplayName("the owner gets their property back")
    void ownerIsAllowed() {
        UUID owner = UUID.randomUUID();
        Property property = propertyOwnedBy(owner);
        when(propertyRepository.findById(property.getId()))
                .thenReturn(Optional.of(property));

        assertThat(access.require(owner, property.getId())).isSameAs(property);
    }

    @Test
    @DisplayName("another owner is refused with PROPERTY_NOT_OWNED")
    void otherOwnerIsRefused() {
        Property property = propertyOwnedBy(UUID.randomUUID());
        when(propertyRepository.findById(property.getId()))
                .thenReturn(Optional.of(property));

        // The check that matters: holding the owner role is not the same as
        // owning this row. The role guard cannot answer this.
        assertThatThrownBy(() -> access.require(UUID.randomUUID(), property.getId()))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.PROPERTY_NOT_OWNED);
    }

    @Test
    @DisplayName("an unknown or soft-deleted property is a 404")
    void unknownPropertyIsNotFound() {
        UUID missing = UUID.randomUUID();
        // @SQLRestriction hides soft-deleted rows, so both cases arrive here as
        // an empty Optional.
        when(propertyRepository.findById(missing)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> access.require(UUID.randomUUID(), missing))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.NOT_FOUND);
    }

    @Test
    @DisplayName("requireAccess enforces the same rule without returning the row")
    void requireAccessMatches() {
        Property property = propertyOwnedBy(UUID.randomUUID());
        when(propertyRepository.findById(property.getId()))
                .thenReturn(Optional.of(property));

        assertThatThrownBy(() -> access.requireAccess(UUID.randomUUID(), property.getId()))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.PROPERTY_NOT_OWNED);
    }

    @Test
    @DisplayName("PROPERTY_NOT_OWNED is a 403, per docs/CURRENT_STATE.md 4.5")
    void ownershipFailureIsForbidden() {
        assertThat(ErrorCode.PROPERTY_NOT_OWNED.status().value()).isEqualTo(403);
    }

    /**
     * The seam. If staff sub-accounts land, only the implementation changes -
     * this pins the fact that there is an interface to swap.
     */
    @Test
    @DisplayName("access is defined by an interface, so the rule stays replaceable")
    void isASeam() {
        assertThat(PropertyAccess.class.isInterface()).isTrue();
        assertThat(PropertyAccess.class).isAssignableFrom(OwnerIdPropertyAccess.class);
    }
}
