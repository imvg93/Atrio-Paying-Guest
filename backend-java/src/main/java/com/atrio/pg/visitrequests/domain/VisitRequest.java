package com.atrio.pg.visitrequests.domain;

import com.atrio.pg.common.persistence.BaseEntity;
import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.users.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

/**
 * Table {@code visit_requests}.
 *
 * <p>Nothing at the database level prevents a student raising duplicate
 * pending requests for the same property - CLAUDE.md does not define a rule
 * either, so this is currently allowed.
 */
@Entity
@Table(name = "visit_requests")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE visit_requests SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class VisitRequest extends BaseEntity {

    @Column(name = "property_id", nullable = false)
    private UUID propertyId;

    @Column(name = "student_id", nullable = false)
    private UUID studentId;

    @Column(name = "preferred_date", nullable = false)
    private LocalDate preferredDate;

    @Column(name = "preferred_slot", nullable = false,
            columnDefinition = "visit_requests_preferred_slot_enum")
    private VisitSlot preferredSlot;

    @Column(name = "message", columnDefinition = "text")
    private String message;

    @Column(name = "status", nullable = false,
            columnDefinition = "visit_requests_status_enum")
    private VisitRequestStatus status = VisitRequestStatus.PENDING;

    @Column(name = "responded_at")
    private Instant respondedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", insertable = false, updatable = false)
    private Property property;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", insertable = false, updatable = false)
    private User student;
}
