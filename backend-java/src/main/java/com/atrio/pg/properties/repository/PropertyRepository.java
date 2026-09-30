package com.atrio.pg.properties.repository;

import com.atrio.pg.beds.domain.BedStatus;
import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.properties.domain.PropertyStatus;
import com.atrio.pg.properties.dto.PropertyStats;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface PropertyRepository
        extends JpaRepository<Property, UUID>, JpaSpecificationExecutor<Property> {

    Page<Property> findAllByOwnerId(UUID ownerId, Pageable pageable);

    Page<Property> findAllByOwnerIdAndStatus(UUID ownerId, PropertyStatus status, Pageable pageable);

    Optional<Property> findByIdAndOwnerId(UUID id, UUID ownerId);

    /**
     * Bed counts and rent range for a page of properties, in one query rather
     * than one per card.
     *
     * <p>Soft deletes need no clause here: {@code @SQLRestriction} on
     * {@link com.atrio.pg.beds.domain.Bed}, {@link com.atrio.pg.rooms.domain.Room}
     * and {@link Property} is applied by Hibernate to every JPQL query, and the
     * join is inner, so a deleted room takes its beds out of the aggregate.
     *
     * <p>A property with no rooms - or whose beds are all soft-deleted -
     * produces <em>no row at all</em>, not a row of zeros. Callers must fall
     * back to {@link PropertyStats#EMPTY}.
     *
     * <p>The bed statuses arrive as parameters rather than enum literals so the
     * {@code beds_status_enum} attribute converter runs on them.
     */
    @Query("""
            SELECT new com.atrio.pg.properties.dto.PropertyStats(
                r.propertyId,
                COUNT(b.id),
                SUM(CASE WHEN b.status = :occupied THEN 1L ELSE 0L END),
                SUM(CASE WHEN b.status = :available THEN 1L ELSE 0L END),
                MIN(r.rentPerBedPaise),
                MAX(r.rentPerBedPaise))
            FROM Bed b
            JOIN b.room r
            WHERE r.propertyId IN :propertyIds
            GROUP BY r.propertyId
            """)
    List<PropertyStats> statsForProperties(
            @Param("propertyIds") Collection<UUID> propertyIds,
            @Param("occupied") BedStatus occupied,
            @Param("available") BedStatus available);
}
