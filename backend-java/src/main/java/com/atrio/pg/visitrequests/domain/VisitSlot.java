package com.atrio.pg.visitrequests.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code visit_requests_preferred_slot_enum}. */
public enum VisitSlot implements PgEnum {

    MORNING("morning"),
    AFTERNOON("afternoon"),
    EVENING("evening");

    private final String dbValue;

    VisitSlot(String dbValue) {
        this.dbValue = dbValue;
    }

    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static VisitSlot from(String value) {
        for (VisitSlot slot : values()) {
            if (slot.dbValue.equals(value)) {
                return slot;
            }
        }
        throw new IllegalArgumentException("Unknown visit slot: " + value);
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<VisitSlot> {
        public Conv() {
            super(VisitSlot.class);
        }
    }
}
