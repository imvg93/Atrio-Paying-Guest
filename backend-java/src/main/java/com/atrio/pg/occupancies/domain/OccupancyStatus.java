package com.atrio.pg.occupancies.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code occupancies_status_enum}: active | notice_period | ended. */
public enum OccupancyStatus implements PgEnum {

    ACTIVE("active"),
    NOTICE_PERIOD("notice_period"),
    ENDED("ended");

    private final String dbValue;

    OccupancyStatus(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static OccupancyStatus from(String value) {
        for (OccupancyStatus status : values()) {
            if (status.dbValue.equals(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown occupancy status: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<OccupancyStatus> {
        public Conv() {
            super(OccupancyStatus.class);
        }
    }
}
