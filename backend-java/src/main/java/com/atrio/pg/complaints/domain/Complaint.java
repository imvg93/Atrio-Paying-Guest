package com.atrio.pg.complaints.domain;

import com.atrio.pg.common.persistence.BaseEntity;
import com.atrio.pg.occupancies.domain.Occupancy;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import org.hibernate.type.SqlTypes;

/**
 * Table {@code complaints}. Scoped to an occupancy - that is what ties a
 * complaint to a bed and a property.
 *
 * <p>{@code photos} is a JSONB array of URLs; a database check constraint
 * enforces {@code jsonb_typeof(photos) = 'array'}.
 *
 * <p>Entity only: no endpoints until Phase 2.
 */
@Entity
@Table(name = "complaints")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE complaints SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class Complaint extends BaseEntity {

    @Column(name = "occupancy_id", nullable = false)
    private UUID occupancyId;

    @Column(name = "category", nullable = false,
            columnDefinition = "complaints_category_enum")
    private ComplaintCategory category;

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "description", nullable = false, columnDefinition = "text")
    private String description;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "photos", columnDefinition = "jsonb")
    private List<String> photos;

    @Column(name = "status", nullable = false, columnDefinition = "complaints_status_enum")
    private ComplaintStatus status = ComplaintStatus.OPEN;

    @Column(name = "resolved_at")
    private Instant resolvedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "occupancy_id", insertable = false, updatable = false)
    private Occupancy occupancy;
}
