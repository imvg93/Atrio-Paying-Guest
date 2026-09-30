package com.atrio.pg.beds.domain;

import com.atrio.pg.common.persistence.BaseEntity;
import com.atrio.pg.rooms.domain.Room;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

/**
 * Table {@code beds}. The unit that actually gets rented (CLAUDE.md 4).
 * Auto-created from a room's {@code sharing_type}; {@code label} is unique per
 * room among non-deleted beds.
 */
@Entity
@Table(name = "beds")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE beds SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class Bed extends BaseEntity {

    @Column(name = "room_id", nullable = false)
    private UUID roomId;

    /** e.g. "A", "B". Labelling scheme still to be decided. */
    @Column(name = "label", nullable = false, length = 20)
    private String label;

    @Column(name = "status", nullable = false, columnDefinition = "beds_status_enum")
    private BedStatus status = BedStatus.AVAILABLE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", insertable = false, updatable = false)
    private Room room;
}
