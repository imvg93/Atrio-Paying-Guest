package com.atrio.pg.visitrequests.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code visit_requests_status_enum}. */
public enum VisitRequestStatus implements PgEnum {

    PENDING("pending"),
    ACCEPTED("accepted"),
    DECLINED("declined"),
    COMPLETED("completed"),
    CANCELLED("cancelled");

    private final String dbValue;

    VisitRequestStatus(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static VisitRequestStatus from(String value) {
        for (VisitRequestStatus status : values()) {
            if (status.dbValue.equals(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown visit request status: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<VisitRequestStatus> {
        public Conv() {
            super(VisitRequestStatus.class);
        }
    }
}
