package com.atrio.pg.config;

import com.atrio.pg.common.persistence.PgEnumConverterFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.format.FormatterRegistry;
import org.springframework.web.servlet.config.annotation.PathMatchConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.method.HandlerTypePredicate;

/**
 * Puts every application route under /api/v1 (CLAUDE.md 3.8) without moving
 * actuator endpoints, which a platform health check needs at the root.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    public static final String API_PREFIX = "/api/v1";

    @Override
    public void configurePathMatch(PathMatchConfigurer configurer) {
        configurer.addPathPrefix(
                API_PREFIX,
                HandlerTypePredicate.forBasePackage("com.atrio.pg"));
    }

    /**
     * Lets every {@code PgEnum} be used as a query parameter by its database
     * label, matching what those enums serialize to in a response body.
     */
    @Override
    public void addFormatters(FormatterRegistry registry) {
        registry.addConverterFactory(new PgEnumConverterFactory());
    }
}
