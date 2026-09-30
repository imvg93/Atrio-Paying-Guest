package com.atrio.pg.occupancies.domain;

import com.atrio.pg.beds.domain.Bed;
import com.atrio.pg.common.persistence.BaseEntity;
import com.atrio.pg.users.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

/**
 * Table {@code occupancies} - the contract record, and the thing Phase 3
 * payments will hang off.
 *
 * <p><strong>History is sacred</strong> (CLAUDE.md 3.5 and 4). An occupancy is
 * opened with a {@code startDate} and closed with an {@code endDate}; it is
 * never rewritten to represent a different tenancy.
 *
 * <p>The unique index {@code uq_occupancies_open_per_bed} allows at most one
 * open occupancy per bed, keyed on {@code end_date IS NULL} - not on
 * {@code status}. A row with {@code status = ended} but a null {@code endDate}
 * would still hold the slot, so application code must keep the two consistent.
 *
 * <p>Entity only: no endpoints until Phase 2, matching the NestJS state.
 */
@Entity
@Table(name = "occupancies")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE occupancies SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class Occupancy extends BaseEntity {

    @Column(name = "bed_id", nullable = false)
    private UUID bedId;

    @Column(name = "student_id", nullable = false)
    private UUID studentId;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    /** null = ongoing. */
    @Column(name = "end_date")
    private LocalDate endDate;

    /** Locked at move-in; the room's rent may change later. */
    @Column(name = "rent_paise", nullable = false)
    private long rentPaise;

    @Column(name = "deposit_paise", nullable = false)
    private long depositPaise;

    @Column(name = "status", nullable = false, columnDefinition = "occupancies_status_enum")
    private OccupancyStatus status = OccupancyStatus.ACTIVE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bed_id", insertable = false, updatable = false)
    private Bed bed;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", insertable = false, updatable = false)
    private User student;

    public boolean isOpen() {
        return endDate == null;
    }
}
