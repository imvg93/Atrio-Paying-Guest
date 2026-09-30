package com.atrio.pg.properties.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/**
 * Postgres enum {@code properties_status_enum}: draft | published | unlisted.
 * Only {@code published} appears in public search results.
 */
public enum PropertyStatus implements PgEnum {

    DRAFT("draft"),
    PUBLISHED("published"),
    UNLISTED("unlisted");

    private final String dbValue;

    PropertyStatus(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static PropertyStatus from(String value) {
        for (PropertyStatus status : values()) {
            if (status.dbValue.equals(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown property status: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<PropertyStatus> {
        public Conv() {
            super(PropertyStatus.class);
        }
    }
}
