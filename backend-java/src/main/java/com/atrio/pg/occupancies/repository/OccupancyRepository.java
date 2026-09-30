package com.atrio.pg.occupancies.repository;

import com.atrio.pg.occupancies.domain.Occupancy;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OccupancyRepository extends JpaRepository<Occupancy, UUID> {

    /** The single open occupancy for a bed, if any. */
    Optional<Occupancy> findByBedIdAndEndDateIsNull(UUID bedId);

    List<Occupancy> findAllByStudentId(UUID studentId);
}
