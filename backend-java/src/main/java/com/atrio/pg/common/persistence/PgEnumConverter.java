package com.atrio.pg.common.persistence;

import jakarta.persistence.AttributeConverter;

/**
 * Shared JPA converter for {@link PgEnum} types.
 *
 * <p>Each enum declares a nested subclass annotated
 * {@code @Converter(autoApply = true)} so the mapping applies to every field of
 * that type without per-field {@code @Convert}.
 *
 * <p>The converter binds a Java {@code String}. Postgres will not implicitly
 * cast {@code varchar} to a named enum, so the JDBC URL sets
 * {@code stringtype=unspecified}, which makes the driver send the value
 * untyped and lets Postgres infer the enum type.
 */
public abstract class PgEnumConverter<E extends Enum<E> & PgEnum>
        implements AttributeConverter<E, String> {

    private final Class<E> type;

    protected PgEnumConverter(Class<E> type) {
        this.type = type;
    }

    @Override
    public String convertToDatabaseColumn(E attribute) {
        return attribute == null ? null : attribute.dbValue();
    }

    @Override
    public E convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        for (E constant : type.getEnumConstants()) {
            if (constant.dbValue().equals(dbData)) {
                return constant;
            }
        }
        throw new IllegalArgumentException(
                "Unknown %s value from database: %s".formatted(type.getSimpleName(), dbData));
    }
}
