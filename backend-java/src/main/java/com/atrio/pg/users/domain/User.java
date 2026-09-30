package com.atrio.pg.users.domain;

import com.atrio.pg.common.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.Instant;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

/**
 * Table {@code users}.
 *
 * <p>Uniqueness of {@code phone} and {@code lower(email)} is enforced by
 * partial unique indexes scoped {@code WHERE deleted_at IS NULL}, so a
 * soft-deleted row never blocks re-signup. Email uniqueness is
 * <strong>case-insensitive</strong> - always lowercase before writing or
 * looking up, or the index will reject a value the application thought was new.
 */
@Entity
@Table(name = "users")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE users SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class User extends BaseEntity {

    /** E.164, e.g. +919876543210. Login identifier. */
    @Column(name = "phone", nullable = false, length = 15)
    private String phone;

    @Column(name = "name", length = 255)
    private String name;

    @Column(name = "email", length = 255)
    private String email;

    /**
     * Converted by {@link UserRole.Conv} (autoApply).
     *
     * <p>Provisionally {@code STUDENT} on a fresh account. That is not a
     * choice - see {@link #roleChosenAt}.
     */
    @Column(name = "role", nullable = false, columnDefinition = "users_role_enum")
    private UserRole role = UserRole.STUDENT;

    /**
     * When the user picked their role. {@code null} means they never have, and
     * is the only thing that makes "role is settable once" (CLAUDE.md 6)
     * enforceable - the column default on {@code role} used to make every new
     * account indistinguishable from a deliberate student. Added by
     * {@code V2__role_settable_once.sql}.
     */
    @Column(name = "role_chosen_at")
    private Instant roleChosenAt;

    @Column(name = "gender", columnDefinition = "users_gender_enum")
    private Gender gender;

    @Column(name = "avatar_url", length = 512)
    private String avatarUrl;

    @Column(name = "is_active", nullable = false)
    private boolean isActive = true;

    @Column(name = "last_login_at")
    private Instant lastLoginAt;

    /** True until the user has picked a role; false forever after. */
    public boolean canChooseRole() {
        return roleChosenAt == null;
    }
}
