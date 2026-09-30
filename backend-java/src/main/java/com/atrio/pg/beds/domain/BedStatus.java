package com.atrio.pg.beds.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code beds_status_enum}: available | occupied | maintenance. */
public enum BedStatus implements PgEnum {

    AVAILABLE("available"),
    OCCUPIED("occupied"),
    MAINTENANCE("maintenance");

    private final String dbValue;

    BedStatus(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static BedStatus from(String value) {
        for (BedStatus status : values()) {
            if (status.dbValue.equals(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown bed status: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<BedStatus> {
        public Conv() {
            super(BedStatus.class);
        }
    }
}
