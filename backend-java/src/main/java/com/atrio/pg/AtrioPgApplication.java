package com.atrio.pg;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

/**
 * Entry point. {@code @ConfigurationPropertiesScan} binds {@code AuthProperties}.
 *
 * <p>{@code UserDetailsServiceAutoConfiguration} is excluded deliberately.
 * Left in, Spring Boot creates an in-memory user with a random password printed
 * at every boot - meaningless for a JWT-only API, and an actual credential
 * nobody is watching.
 */
@ConfigurationPropertiesScan
@SpringBootApplication(exclude = UserDetailsServiceAutoConfiguration.class)
public class AtrioPgApplication {

    public static void main(String[] args) {
        SpringApplication.run(AtrioPgApplication.class, args);
    }
}
