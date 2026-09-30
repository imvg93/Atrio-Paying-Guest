package com.atrio.pg.common.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.UuidGenerator;
import org.hibernate.proxy.HibernateProxy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

/**
 * The four columns every table in this system carries (CLAUDE.md 3.1-3.3).
 *
 * <p>Note on {@code updated_at}: every table also has a {@code BEFORE UPDATE}
 * trigger setting {@code updated_at = now()}. The trigger fires after
 * Hibernate has written its own value, so <strong>the trigger always
 * wins</strong>. That is intentional (it also covers raw SQL), but it means an
 * in-memory entity's {@code updatedAt} is stale immediately after a flush.
 * Re-read the row if a response must return the stored value.
 *
 * <p>Subclasses must declare {@code @SQLRestriction("deleted_at IS NULL")} and
 * {@code @SQLDelete} themselves - Hibernate does not inherit those from a
 * mapped superclass.
 */
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
public abstract class BaseEntity {

    @Id
    @GeneratedValue
    @UuidGenerator
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    /** Soft delete marker. Never hard-delete a row (CLAUDE.md 3.2). */
    @Column(name = "deleted_at")
    private Instant deletedAt;

    public boolean isDeleted() {
        return deletedAt != null;
    }

    /*
     * Identity is the primary key only, and unsaved entities are never equal.
     * Lombok's @Data/@EqualsAndHashCode are deliberately avoided on entities:
     * they pull in lazy associations and break proxies.
     */
    @Override
    public final boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null) {
            return false;
        }
        Class<?> thisType = this instanceof HibernateProxy hp
                ? hp.getHibernateLazyInitializer().getPersistentClass()
                : getClass();
        Class<?> otherType = o instanceof HibernateProxy hp
                ? hp.getHibernateLazyInitializer().getPersistentClass()
                : o.getClass();
        if (!thisType.equals(otherType)) {
            return false;
        }
        BaseEntity other = (BaseEntity) o;
        return id != null && id.equals(other.getId());
    }

    @Override
    public final int hashCode() {
        return getClass().hashCode();
    }
}
