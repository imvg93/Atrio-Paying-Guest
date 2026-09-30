package com.atrio.pg.auth.security;

import com.atrio.pg.users.domain.UserRole;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

/**
 * The authenticated caller, built from the access token's claims. Reachable in
 * a controller with {@code @AuthenticationPrincipal AppUserPrincipal caller}.
 *
 * <p>Deliberately not the {@code User} entity: this is read from a token on
 * every request and must not imply a database round trip or drag a Hibernate
 * session into the security layer. Services that need the row load it by
 * {@link #id()}.
 */
public record AppUserPrincipal(UUID id, String phone, UserRole role) {

    /** Authority naming that {@code @PreAuthorize("hasRole('OWNER')")} expects. */
    public Collection<? extends GrantedAuthority> authorities() {
        return List.of(new SimpleGrantedAuthority(role.authority()));
    }
}
