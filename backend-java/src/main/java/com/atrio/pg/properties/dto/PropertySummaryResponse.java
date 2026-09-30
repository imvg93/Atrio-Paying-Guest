package com.atrio.pg.properties.dto;

import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.properties.domain.PropertyGenderType;
import com.atrio.pg.properties.domain.PropertyStatus;
import java.time.Instant;
import java.util.UUID;

/**
 * The portfolio card (H1): photo, name, locality, status chip, beds filled,
 * rent range.
 *
 * <p>Deliberately narrower than {@link PropertyDetailResponse} - a list of
 * twenty properties has no use for amenity maps, rules or full addresses, and
 * shipping them turns a card list into a payload. Adding a field here later is
 * additive and allowed (CLAUDE.md 3.9).
 */
public record PropertySummaryResponse(
        UUID id,
        String name,
        String locality,
        String city,
        PropertyGenderType genderType,
        PropertyStatus status,
        boolean foodIncluded,
        String coverPhotoUrl,
        int photoCount,
        OccupancySummary occupancy,
        Long minRentPaise,
        Long maxRentPaise,
        Instant createdAt,
        Instant updatedAt) {

    public static PropertySummaryResponse from(
            Property property, PropertyStats stats, String coverPhotoUrl, int photoCount) {
        return new PropertySummaryResponse(
                property.getId(),
                property.getName(),
                property.getLocality(),
                property.getCity(),
                property.getGenderType(),
                property.getStatus(),
                property.isFoodIncluded(),
                coverPhotoUrl,
                photoCount,
                OccupancySummary.from(stats),
                stats.minRentPaise(),
                stats.maxRentPaise(),
                property.getCreatedAt(),
                property.getUpdatedAt());
    }
}
