package com.atrio.pg.users.repository;

import com.atrio.pg.users.domain.User;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByPhone(String phone);

    boolean existsByPhone(String phone);

    /** Email uniqueness is on lower(email); callers must pass a lowercased value. */
    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);
}
