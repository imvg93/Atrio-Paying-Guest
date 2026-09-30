package com.atrio.pg.properties.dto;

import com.atrio.pg.properties.domain.PropertyGenderType;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Body of {@code POST /owner/properties} - the H3 wizard's first save.
 *
 * <p><strong>Status is not accepted here.</strong> A new property is always a
 * {@code draft}; publishing is {@code PATCH /owner/properties/:id/status}, so
 * "is this listing live?" has exactly one way in and one place to audit.
 *
 * <p><strong>Location is mandatory</strong> because {@code latitude} and
 * {@code longitude} are NOT NULL in the schema. The wizard therefore cannot
 * persist after step 1 alone - it holds basics and location in local state and
 * saves once the pin is dropped. Relaxing that would need a migration making
 * the columns nullable, which would then have to be defended everywhere
 * distance search runs.
 */
public record CreatePropertyRequest(
        @NotBlank
        @Size(min = 2, max = 255, message = "must be between 2 and 255 characters")
        String name,

        @Size(max = 5000, message = "must be at most 5000 characters")
        String description,

        @NotNull
        PropertyGenderType genderType,

        @NotBlank
        @Size(max = 512, message = "must be at most 512 characters")
        String addressLine,

        @NotBlank
        @Size(max = 255, message = "must be at most 255 characters")
        String locality,

        @NotBlank
        @Size(max = 255, message = "must be at most 255 characters")
        String city,

        @NotBlank
        @Size(max = 255, message = "must be at most 255 characters")
        String state,

        @NotBlank
        @Pattern(regexp = "^[1-9][0-9]{5}$", message = "must be a 6-digit Indian pincode")
        String pincode,

        @NotNull
        @DecimalMin(value = "-90.0", message = "must be between -90 and 90")
        @DecimalMax(value = "90.0", message = "must be between -90 and 90")
        BigDecimal latitude,

        @NotNull
        @DecimalMin(value = "-180.0", message = "must be between -180 and 180")
        @DecimalMax(value = "180.0", message = "must be between -180 and 180")
        BigDecimal longitude,

        /**
         * Open-ended by design (CLAUDE.md 3.6). Keys are validated against
         * {@code GET /meta/amenities} on the client; the server stores what it
         * is given so a new amenity needs no migration and no app update.
         */
        Map<String, Boolean> amenities,

        Map<String, Object> rules,

        Boolean foodIncluded,

        @Min(value = 0, message = "must be at least 0")
        @Max(value = 365, message = "must be at most 365")
        Integer noticePeriodDays) {

    public static final int DEFAULT_NOTICE_PERIOD_DAYS = 30;

    public Map<String, Boolean> amenitiesOrEmpty() {
        return amenities == null ? new LinkedHashMap<>() : new LinkedHashMap<>(amenities);
    }

    public boolean foodIncludedOrDefault() {
        return Boolean.TRUE.equals(foodIncluded);
    }

    public int noticePeriodDaysOrDefault() {
        return noticePeriodDays == null ? DEFAULT_NOTICE_PERIOD_DAYS : noticePeriodDays;
    }
}
