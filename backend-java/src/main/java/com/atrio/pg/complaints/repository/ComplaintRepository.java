package com.atrio.pg.complaints.repository;

import com.atrio.pg.complaints.domain.Complaint;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, UUID> {

    List<Complaint> findAllByOccupancyIdOrderByCreatedAtDesc(UUID occupancyId);
}
