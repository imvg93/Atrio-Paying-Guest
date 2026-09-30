package com.atrio.pg.complaints.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code complaints_category_enum}. */
public enum ComplaintCategory implements PgEnum {

    ELECTRICAL("electrical"),
    PLUMBING("plumbing"),
    CLEANING("cleaning"),
    FOOD("food"),
    WIFI("wifi"),
    OTHER("other");

    private final String dbValue;

    ComplaintCategory(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static ComplaintCategory from(String value) {
        for (ComplaintCategory category : values()) {
            if (category.dbValue.equals(value)) {
                return category;
            }
        }
        throw new IllegalArgumentException("Unknown complaint category: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<ComplaintCategory> {
        public Conv() {
            super(ComplaintCategory.class);
        }
    }
}
