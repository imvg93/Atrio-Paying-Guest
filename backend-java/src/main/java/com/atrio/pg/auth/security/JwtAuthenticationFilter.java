package com.atrio.pg.auth.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Turns a {@code Authorization: Bearer <jwt>} header into an authenticated
 * {@code SecurityContext}.
 *
 * <p>A missing or unparseable token is <strong>not</strong> an error here - the
 * request simply continues unauthenticated. Public routes then work as normal,
 * and protected ones fall to {@code RestAuthenticationEntryPoint}, which is the
 * single place that renders the 401 envelope.
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtService jwtService;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain)
            throws ServletException, IOException {

        bearerToken(request)
                .flatMap(jwtService::parseAccessToken)
                .ifPresent(principal -> authenticate(principal, request));

        filterChain.doFilter(request, response);
    }

    private void authenticate(AppUserPrincipal principal, HttpServletRequest request) {
        // Never overwrite an authentication another filter already established.
        if (SecurityContextHolder.getContext().getAuthentication() != null) {
            return;
        }
        var authentication = new UsernamePasswordAuthenticationToken(
                principal, null, principal.authorities());
        authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

    private java.util.Optional<String> bearerToken(HttpServletRequest request) {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (header == null || !header.startsWith(BEARER_PREFIX)) {
            return java.util.Optional.empty();
        }
        String token = header.substring(BEARER_PREFIX.length()).trim();
        return token.isEmpty() ? java.util.Optional.empty() : java.util.Optional.of(token);
    }
}
