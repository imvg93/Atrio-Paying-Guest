package com.atrio.pg.users.web;

import com.atrio.pg.auth.security.AppUserPrincipal;
import com.atrio.pg.auth.service.AuthService;
import com.atrio.pg.users.dto.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * {@code GET /api/v1/me} - the current user profile (CLAUDE.md 6, Shared).
 *
 * <p>Reads the row rather than reflecting the token's claims back: a token
 * lives 15 minutes, so a profile edited in that window would otherwise be
 * reported stale, and the client uses this response to decide whether the
 * profile still needs completing.
 */
@RestController
@RequestMapping("/me")
@RequiredArgsConstructor
public class MeController {

    private final AuthService authService;

    @GetMapping
    public UserResponse me(@AuthenticationPrincipal AppUserPrincipal caller) {
        return authService.currentUser(caller.id());
    }
}
