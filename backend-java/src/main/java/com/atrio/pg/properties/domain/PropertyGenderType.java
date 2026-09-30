package com.atrio.pg.properties.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code properties_gender_type_enum}: male | female | coliving. */
public enum PropertyGenderType implements PgEnum {

    MALE("male"),
    FEMALE("female"),
    COLIVING("coliving");

    private final String dbValue;

    PropertyGenderType(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static PropertyGenderType from(String value) {
        for (PropertyGenderType type : values()) {
            if (type.dbValue.equals(value)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown gender type: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<PropertyGenderType> {
        public Conv() {
            super(PropertyGenderType.class);
        }
    }
}
