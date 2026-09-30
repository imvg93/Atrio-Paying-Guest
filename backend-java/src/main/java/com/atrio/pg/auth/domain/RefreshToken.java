package com.atrio.pg.auth.domain;

import com.atrio.pg.common.persistence.BaseEntity;
import com.atrio.pg.users.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

/**
 * Table {@code refresh_tokens}.
 *
 * <p>{@code tokenHash} must be a <strong>deterministic</strong> digest
 * (SHA-256), never BCrypt. The refresh flow looks a token up <em>by its
 * hash</em> through the unique index {@code uq_refresh_tokens_token_hash}; a
 * salted hash differs on every computation, so lookup would always miss and
 * the unique index would be meaningless. This is safe because the token is 256
 * bits of entropy, not a guessable secret. See MIGRATION_PLAN.md 6.3.
 */
@Entity
@Table(name = "refresh_tokens")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE refresh_tokens SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class RefreshToken extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "token_hash", nullable = false, length = 255)
    private String tokenHash;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "revoked_at")
    private Instant revokedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    public boolean isRevoked() {
        return revokedAt != null;
    }

    public boolean isUsable(Instant now) {
        return revokedAt == null && expiresAt.isAfter(now);
    }
}
