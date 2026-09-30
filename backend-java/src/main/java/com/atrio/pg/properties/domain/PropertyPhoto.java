package com.atrio.pg.properties.domain;

import com.atrio.pg.common.persistence.BaseEntity;
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

/** Table {@code property_photos}. Ordered by {@code sortOrder} within a property. */
@Entity
@Table(name = "property_photos")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE property_photos SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class PropertyPhoto extends BaseEntity {

    @Column(name = "property_id", nullable = false)
    private UUID propertyId;

    @Column(name = "url", nullable = false, length = 1024)
    private String url;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder = 0;

    @Column(name = "caption", length = 255)
    private String caption;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", insertable = false, updatable = false)
    private Property property;
}
