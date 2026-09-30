package com.atrio.pg.beds.repository;

import com.atrio.pg.beds.domain.Bed;
import com.atrio.pg.beds.domain.BedStatus;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BedRepository extends JpaRepository<Bed, UUID> {

    List<Bed> findAllByRoomId(UUID roomId);

    long countByRoomIdAndStatus(UUID roomId, BedStatus status);
}
