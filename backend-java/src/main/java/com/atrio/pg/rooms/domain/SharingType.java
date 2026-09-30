package com.atrio.pg.rooms.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;
import java.util.Map;

/**
 * Postgres enum {@code rooms_sharing_type_enum}: single | double | triple |
 * four_plus.
 *
 * <p>The {@code double} label is why this codebase maps enum values explicitly
 * rather than by constant name - {@code double} is a Java keyword.
 */
public enum SharingType implements PgEnum {

    SINGLE("single", 1),
    DOUBLE("double", 2),
    TRIPLE("triple", 3),
    /** A floor, not an exact count - owners may add more beds afterwards. */
    FOUR_PLUS("four_plus", 4);

    private final String dbValue;
    private final int defaultBedCount;

    SharingType(String dbValue, int defaultBedCount) {
        this.dbValue = dbValue;
        this.defaultBedCount = defaultBedCount;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    /** Number of beds auto-created when a room of this type is created. */
    public int defaultBedCount() {
        return defaultBedCount;
    }

    /** Equivalent of the NestJS BEDS_PER_SHARING_TYPE constant. */
    public static final Map<SharingType, Integer> BEDS_PER_SHARING_TYPE = Map.of(
            SINGLE, SINGLE.defaultBedCount,
            DOUBLE, DOUBLE.defaultBedCount,
            TRIPLE, TRIPLE.defaultBedCount,
            FOUR_PLUS, FOUR_PLUS.defaultBedCount);

    @JsonCreator
    public static SharingType from(String value) {
        for (SharingType type : values()) {
            if (type.dbValue.equals(value)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown sharing type: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<SharingType> {
        public Conv() {
            super(SharingType.class);
        }
    }
}
