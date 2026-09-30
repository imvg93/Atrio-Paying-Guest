package com.atrio.pg.auth.repository;

import com.atrio.pg.auth.domain.RefreshToken;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByTokenHash(String tokenHash);

    /** Used to revoke a whole family when token reuse is detected. */
    List<RefreshToken> findAllByUserIdAndRevokedAtIsNull(UUID userId);
}
