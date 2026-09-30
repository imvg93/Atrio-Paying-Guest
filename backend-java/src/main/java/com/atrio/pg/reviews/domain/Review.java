package com.atrio.pg.reviews.domain;

import com.atrio.pg.common.persistence.BaseEntity;
import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.users.domain.User;
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
 * Table {@code reviews}. One live review per student per property, enforced by
 * the partial unique index {@code uq_reviews_property_student}. Rating is
 * constrained to 1-5 by a database check.
 *
 * <p>Entity only: no endpoints until Phase 2.
 */
@Entity
@Table(name = "reviews")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE reviews SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class Review extends BaseEntity {

    @Column(name = "property_id", nullable = false)
    private UUID propertyId;

    @Column(name = "student_id", nullable = false)
    private UUID studentId;

    @Column(name = "rating", nullable = false)
    private int rating;

    @Column(name = "comment", columnDefinition = "text")
    private String comment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", insertable = false, updatable = false)
    private Property property;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", insertable = false, updatable = false)
    private User student;
}
