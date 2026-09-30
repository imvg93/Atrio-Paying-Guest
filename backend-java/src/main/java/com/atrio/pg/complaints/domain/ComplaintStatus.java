package com.atrio.pg.complaints.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code complaints_status_enum}. */
public enum ComplaintStatus implements PgEnum {

    OPEN("open"),
    IN_PROGRESS("in_progress"),
    RESOLVED("resolved"),
    CLOSED("closed");

    private final String dbValue;

    ComplaintStatus(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static ComplaintStatus from(String value) {
        for (ComplaintStatus status : values()) {
            if (status.dbValue.equals(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown complaint status: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<ComplaintStatus> {
        public Conv() {
            super(ComplaintStatus.class);
        }
    }
}
