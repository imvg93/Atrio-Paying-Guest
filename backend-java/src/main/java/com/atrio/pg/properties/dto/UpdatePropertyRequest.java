package com.atrio.pg.properties.dto;

import com.atrio.pg.properties.domain.PropertyGenderType;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.Map;

/**
 * Body of {@code PATCH /owner/properties/:id}. Every field is optional and an
 * absent field means "leave it alone", matching {@code UpdateProfileRequest}.
 *
 * <p><strong>Clearing an optional field.</strong> JSON null is indistinguishable
 * from absent in a record, so null can only ever mean "unchanged". To clear the
 * two nullable fields, send the empty value rather than null:
 * {@code "description": ""} clears the description, {@code "rules": {}} clears
 * the rules. The non-nullable fields have no empty form and simply reject blanks.
 *
 * <p>{@code status} is not here - it is {@code PATCH /:id/status}, for the
 * reason given on {@link CreatePropertyRequest}.
 */
public record UpdatePropertyRequest(
        @Size(min = 2, max = 255, message = "must be between 2 and 255 characters")
        String name,

        @Size(max = 5000, message = "must be at most 5000 characters")
        String description,

        PropertyGenderType genderType,

        @Size(min = 1, max = 512, message = "must be between 1 and 512 characters")
        String addressLine,

        @Size(min = 1, max = 255, message = "must be between 1 and 255 characters")
        String locality,

        @Size(min = 1, max = 255, message = "must be between 1 and 255 characters")
        String city,

        @Size(min = 1, max = 255, message = "must be between 1 and 255 characters")
        String state,

        @Pattern(regexp = "^[1-9][0-9]{5}$", message = "must be a 6-digit Indian pincode")
        String pincode,

        @DecimalMin(value = "-90.0", message = "must be between -90 and 90")
        @DecimalMax(value = "90.0", message = "must be between -90 and 90")
        BigDecimal latitude,

        @DecimalMin(value = "-180.0", message = "must be between -180 and 180")
        @DecimalMax(value = "180.0", message = "must be between -180 and 180")
        BigDecimal longitude,

        Map<String, Boolean> amenities,

        Map<String, Object> rules,

        Boolean foodIncluded,

        @Min(value = 0, message = "must be at least 0")
        @Max(value = 365, message = "must be at most 365")
        Integer noticePeriodDays) {

    /**
     * A pin is only meaningful as a pair. Accepting one half would silently
     * move the property to a point on the equator or the prime meridian.
     */
    public boolean hasPartialCoordinates() {
        return (latitude == null) != (longitude == null);
    }
}
