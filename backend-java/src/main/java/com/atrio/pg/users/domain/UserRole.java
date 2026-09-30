package com.atrio.pg.users.domain;

import com.atrio.pg.common.persistence.PgEnum;
import com.atrio.pg.common.persistence.PgEnumConverter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.Converter;

/** Postgres enum {@code users_role_enum}: student | owner | admin. */
public enum UserRole implements PgEnum {

    STUDENT("student"),
    OWNER("owner"),
    ADMIN("admin");

    private final String dbValue;

    UserRole(String dbValue) {
        this.dbValue = dbValue;
    }

    /** Also the JSON representation, so the API emits lowercase. */
    @Override
    @JsonValue
    public String dbValue() {
        return dbValue;
    }

    @JsonCreator
    public static UserRole from(String value) {
        for (UserRole role : values()) {
            if (role.dbValue.equals(value)) {
                return role;
            }
        }
        throw new IllegalArgumentException("Unknown role: " + value);
    }

    /** Spring Security authority, e.g. ROLE_OWNER. */
    public String authority() {
        return "ROLE_" + name();
    }

    @Converter(autoApply = true)
    public static class Conv extends PgEnumConverter<UserRole> {
        public Conv() {
            super(UserRole.class);
        }
    }
}
