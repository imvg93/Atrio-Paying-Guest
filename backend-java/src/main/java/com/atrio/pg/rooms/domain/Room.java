package com.atrio.pg.rooms.domain;

import com.atrio.pg.common.persistence.BaseEntity;
import com.atrio.pg.properties.domain.Property;
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
 * Table {@code rooms}. {@code roomNumber} is unique per property among
 * non-deleted rooms.
 *
 * <p>{@code depositPaise} is NOT NULL with no database default, although
 * CLAUDE.md 5 describes it as "default = rent, editable" - that defaulting must
 * happen in application code or the insert fails.
 */
@Entity
@Table(name = "rooms")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE rooms SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class Room extends BaseEntity {

    @Column(name = "property_id", nullable = false)
    private UUID propertyId;

    @Column(name = "room_number", nullable = false, length = 50)
    private String roomNumber;

    @Column(name = "floor")
    private Integer floor;

    @Column(name = "sharing_type", nullable = false,
            columnDefinition = "rooms_sharing_type_enum")
    private SharingType sharingType;

    /** Money is BIGINT paise (CLAUDE.md 3.7). */
    @Column(name = "rent_per_bed_paise", nullable = false)
    private long rentPerBedPaise;

    @Column(name = "deposit_paise", nullable = false)
    private long depositPaise;

    @Column(name = "has_attached_bathroom", nullable = false)
    private boolean hasAttachedBathroom = false;

    @Column(name = "has_ac", nullable = false)
    private boolean hasAc = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", insertable = false, updatable = false)
    private Property property;
}
