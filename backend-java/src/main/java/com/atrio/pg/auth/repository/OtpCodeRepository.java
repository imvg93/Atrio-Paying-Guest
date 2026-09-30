package com.atrio.pg.auth.repository;

import com.atrio.pg.auth.domain.OtpCode;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, UUID> {

    /** Newest live code for a phone - the verify path. */
    Optional<OtpCode> findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(String phone);

    /** Rate limiting: how many codes were issued for this phone in the window. */
    long countByPhoneAndCreatedAtAfter(String phone, Instant since);
}
