package com.atrio.pg.config;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.module.SimpleModule;
import java.io.IOException;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Timestamp format decision from MIGRATION_PLAN.md 8.5.
 *
 * <p>Postgres {@code timestamptz} carries microseconds, so a raw
 * {@link Instant} serializes as {@code 2026-07-24T18:15:16.123456Z}. JavaScript
 * {@code Date.toISOString()} - what the NestJS API would have emitted - uses
 * exactly three fractional digits. We truncate to milliseconds and always emit
 * a trailing {@code Z} so the wire format is stable and matches what a Dart
 * client expects.
 */
@Configuration
public class JacksonConfig {

    private static final DateTimeFormatter ISO_MILLIS_UTC =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").withZone(ZoneOffset.UTC);

    @Bean
    public SimpleModule atrioTimeModule() {
        SimpleModule module = new SimpleModule("AtrioTimeModule");
        module.addSerializer(Instant.class, new JsonSerializer<>() {
            @Override
            public void serialize(Instant value, JsonGenerator gen, SerializerProvider serializers)
                    throws IOException {
                gen.writeString(ISO_MILLIS_UTC.format(value.truncatedTo(ChronoUnit.MILLIS)));
            }
        });
        return module;
    }
}
