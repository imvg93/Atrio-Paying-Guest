package com.atrio.pg.users.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code users_gender_enum}: male | female | other. */
public enum Gender implements PgEnum {

    MALE("male"),
    FEMALE("female"),
    OTHER("other");

    private final String dbValue;

    Gender(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static Gender from(String value) {
        for (Gender gender : values()) {
            if (gender.dbValue.equals(value)) {
                return gender;
            }
        }
        throw new IllegalArgumentException("Unknown gender: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<Gender> {
        public Conv() {
            super(Gender.class);
        }
    }
}
