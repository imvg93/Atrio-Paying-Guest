package com.atrio.pg.config;

import com.atrio.pg.auth.security.JwtAuthenticationFilter;
import com.atrio.pg.common.exception.RestAccessDeniedHandler;
import com.atrio.pg.common.exception.RestAuthenticationEntryPoint;
import com.atrio.pg.users.domain.UserRole;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Stateless JWT security.
 *
 * <p>The default is {@code authenticated()}: a route added later is protected
 * until someone deliberately opens it, rather than public until someone
 * remembers to close it.
 *
 * <p>Matchers carry the full {@code /api/v1} path because Spring Security sees
 * the request URI, not the handler mapping that {@link WebConfig} prefixes.
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final RestAuthenticationEntryPoint authenticationEntryPoint;
    private final RestAccessDeniedHandler accessDeniedHandler;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // No cookies or sessions are used, so there is no CSRF vector
                // to protect; the credential is a bearer token the browser
                // never attaches automatically.
                .csrf(csrf -> csrf.disable())
                .cors(cors -> {})
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(eh -> eh
                        .authenticationEntryPoint(authenticationEntryPoint)
                        .accessDeniedHandler(accessDeniedHandler))
                .authorizeHttpRequests(auth -> auth
                        // Authenticated /auth routes must precede the public
                        // /auth/** rule below - first match wins.
                        .requestMatchers(HttpMethod.POST, "/api/v1/auth/logout").authenticated()
                        .requestMatchers(HttpMethod.PATCH, "/api/v1/auth/profile").authenticated()

                        // Login is necessarily reachable without a token, and
                        // refresh is called precisely when the access token is
                        // already expired.
                        .requestMatchers("/api/v1/auth/**").permitAll()

                        .requestMatchers("/api/v1/health", "/actuator/health", "/actuator/info")
                        .permitAll()

                        // Role only. Whether it is *their* property is a
                        // different question, answered in the service layer by
                        // PropertyAccess (CLAUDE.md 3.13).
                        .requestMatchers("/api/v1/owner/**").hasRole(UserRole.OWNER.name())

                        .anyRequest().authenticated())
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * Hashes OTP codes (MIGRATION_PLAN.md 6.1). Refresh tokens must
     * <strong>not</strong> use this: they are looked up by hash through a
     * unique index, which needs a deterministic digest, not a salted one. See
     * {@code RefreshTokenHasher}.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
