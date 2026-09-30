package com.atrio.pg.auth.domain;

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
 * Table {@code otp_codes}.
 *
 * <p>Deliberately has no association to {@code User}: an OTP is requested
 * before an account exists, and the table has no FK for that reason.
 *
 * <p>{@code codeHash} is a <strong>BCrypt</strong> hash. That is safe here
 * because lookup is by {@code phone} (index
 * {@code idx_otp_codes_phone_created_at}), never by the hash itself - unlike
 * {@link RefreshToken}, which requires a deterministic digest.
 */
@Entity
@Table(name = "otp_codes")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE otp_codes SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class OtpCode extends BaseEntity {

    @Column(name = "phone", nullable = false, length = 15)
    private String phone;

    /** Hashed OTP. Plaintext codes are never persisted. */
    @Column(name = "code_hash", nullable = false, length = 255)
    private String codeHash;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "attempts", nullable = false)
    private int attempts = 0;

    @Column(name = "consumed_at")
    private Instant consumedAt;

    public boolean isConsumed() {
        return consumedAt != null;
    }

    public boolean isExpired(Instant now) {
        return expiresAt.isBefore(now);
    }
}
