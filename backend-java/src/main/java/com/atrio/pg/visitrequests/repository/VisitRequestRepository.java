package com.atrio.pg.visitrequests.repository;

import com.atrio.pg.visitrequests.domain.VisitRequest;
import com.atrio.pg.visitrequests.domain.VisitRequestStatus;
import java.util.Collection;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VisitRequestRepository extends JpaRepository<VisitRequest, UUID> {

    Page<VisitRequest> findAllByStudentId(UUID studentId, Pageable pageable);

    /** Owner inbox - properties are resolved to ids by the service. */
    Page<VisitRequest> findAllByPropertyIdIn(Collection<UUID> propertyIds, Pageable pageable);

    Page<VisitRequest> findAllByPropertyIdInAndStatus(
            Collection<UUID> propertyIds, VisitRequestStatus status, Pageable pageable);
}
