package com.atrio.pg.common.persistence;

import com.atrio.pg.common.exception.ApiException;
import org.springframework.core.convert.converter.Converter;
import org.springframework.core.convert.converter.ConverterFactory;
import org.springframework.lang.NonNull;

/**
 * Binds query parameters and path variables to {@link PgEnum} types by their
 * database label, so {@code ?status=published} works.
 *
 * <p>Without this, Spring falls back to {@code Enum.valueOf}, which wants
 * {@code PUBLISHED}. The wire contract is the lowercase label - that is what
 * {@code @JsonValue} emits in every response body - and a filter that had to be
 * spelled differently from the value it filters on would be a trap.
 *
 * <p>Registered once in {@code WebConfig} for every PgEnum, present and future:
 * Wave 2 filters visit requests by status, Wave 4 filters complaints, and none
 * of them should need to remember this.
 */
public class PgEnumConverterFactory implements ConverterFactory<String, PgEnum> {

    @Override
    @NonNull
    public <T extends PgEnum> Converter<String, T> getConverter(@NonNull Class<T> targetType) {
        return new StringToPgEnum<>(constantsOf(targetType), targetType.getSimpleName());
    }

    @SuppressWarnings("unchecked")
    private static <T extends PgEnum> T[] constantsOf(Class<T> targetType) {
        // A constant with a body is an anonymous subclass and has no constants
        // of its own; its superclass is the enum. Spring's own enum factory
        // does the same walk.
        Class<?> type = targetType;
        while (type != null && !type.isEnum()) {
            type = type.getSuperclass();
        }
        if (type == null) {
            throw new IllegalArgumentException(
                    targetType.getName() + " is not a PgEnum-backed enum type");
        }
        return (T[]) type.getEnumConstants();
    }

    private record StringToPgEnum<T extends PgEnum>(T[] constants, String typeName)
            implements Converter<String, T> {

        @Override
        public T convert(@NonNull String source) {
            String value = source.trim();
            if (value.isEmpty()) {
                // An absent optional filter arrives as "" from `?status=`.
                // Treating it as null is friendlier than rejecting a client
                // that always appends the parameter.
                return null;
            }
            for (T constant : constants) {
                if (constant.dbValue().equalsIgnoreCase(value)) {
                    return constant;
                }
            }
            throw ApiException.badRequest(
                    "%s is not a valid %s.".formatted(source, typeName));
        }
    }
}
