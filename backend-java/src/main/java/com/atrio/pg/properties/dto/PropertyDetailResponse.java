package com.atrio.pg.properties.dto;

import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.properties.domain.PropertyGenderType;
import com.atrio.pg.properties.domain.PropertyStatus;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * The full property, for H2 (overview), H3 (wizard, when editing) and H11
 * (settings).
 *
 * <p>The entity is never serialized directly - a column added in a later phase
 * would otherwise land on the wire by accident, and {@code ownerId} would leak
 * a user id into a payload that has no use for one.
 */
public record PropertyDetailResponse(
        UUID id,
        String name,
        String description,
        PropertyGenderType genderType,
        String addressLine,
        String locality,
        String city,
        String state,
        String pincode,
        BigDecimal latitude,
        BigDecimal longitude,
        Map<String, Boolean> amenities,
        Map<String, Object> rules,
        boolean foodIncluded,
        int noticePeriodDays,
        PropertyStatus status,
        List<PropertyPhotoResponse> photos,
        OccupancySummary occupancy,
        Long minRentPaise,
        Long maxRentPaise,
        Instant createdAt,
        Instant updatedAt) {

    public static PropertyDetailResponse from(
            Property property, PropertyStats stats, List<PropertyPhotoResponse> photos) {
        return new PropertyDetailResponse(
                property.getId(),
                property.getName(),
                property.getDescription(),
                property.getGenderType(),
                property.getAddressLine(),
                property.getLocality(),
                property.getCity(),
                property.getState(),
                property.getPincode(),
                property.getLatitude(),
                property.getLongitude(),
                property.getAmenities(),
                property.getRules(),
                property.isFoodIncluded(),
                property.getNoticePeriodDays(),
                property.getStatus(),
                photos,
                OccupancySummary.from(stats),
                stats.minRentPaise(),
                stats.maxRentPaise(),
                property.getCreatedAt(),
                property.getUpdatedAt());
    }
}
