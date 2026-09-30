package com.atrio.pg.users.dto;

import com.atrio.pg.users.domain.Gender;
import com.atrio.pg.users.domain.User;
import com.atrio.pg.users.domain.UserRole;
import java.time.Instant;
import java.util.UUID;

/**
 * The user as the API exposes it. Field names and JSON types match
 * {@code app/lib/features/auth/data/models/user.dart} exactly.
 *
 * <p>Nothing sensitive is here to omit today, but the entity is deliberately
 * never serialized directly - that is how a column added in a later phase ends
 * up on the wire by accident.
 *
 * @param roleLocked true once the role has been chosen; the client can use it
 *                   to stop offering a choice it knows will be rejected
 */
public record UserResponse(
        UUID id,
        String phone,
        String name,
        String email,
        UserRole role,
        Gender gender,
        String avatarUrl,
        boolean isActive,
        boolean roleLocked,
        Instant lastLoginAt,
        Instant createdAt,
        Instant updatedAt) {

    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getPhone(),
                user.getName(),
                user.getEmail(),
                user.getRole(),
                user.getGender(),
                user.getAvatarUrl(),
                user.isActive(),
                !user.canChooseRole(),
                user.getLastLoginAt(),
                user.getCreatedAt(),
                user.getUpdatedAt());
    }
}
