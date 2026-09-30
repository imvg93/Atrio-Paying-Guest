package com.atrio.pg.auth.dto;

import com.atrio.pg.users.domain.Gender;
import com.atrio.pg.users.domain.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

/**
 * Body of {@code PATCH /auth/profile}. Every field is optional - this is a
 * patch, and an absent field means "leave it alone".
 *
 * <p>{@code role} is accepted only while the user has never chosen one
 * (CLAUDE.md 6). A second attempt to change it is rejected with
 * {@code ROLE_ALREADY_SET}; re-sending the <em>same</em> role is a no-op so a
 * client retry is not punished.
 *
 * <p>{@code admin} is deliberately not settable here - it is not something a
 * user may grant themselves.
 */
public record UpdateProfileRequest(
        @Size(min = 2, max = 255, message = "must be between 2 and 255 characters")
        String name,

        UserRole role,

        Gender gender,

        @Email(message = "must be a valid email address")
        @Size(max = 255, message = "must be at most 255 characters")
        String email) {
}
