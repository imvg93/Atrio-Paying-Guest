package com.atrio.pg.reviews.repository;

import com.atrio.pg.reviews.domain.Review;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {

    List<Review> findAllByPropertyId(UUID propertyId);

    Optional<Review> findByPropertyIdAndStudentId(UUID propertyId, UUID studentId);
}
