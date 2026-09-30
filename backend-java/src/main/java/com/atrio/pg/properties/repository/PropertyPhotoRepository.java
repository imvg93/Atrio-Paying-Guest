package com.atrio.pg.properties.repository;

import com.atrio.pg.properties.domain.PropertyPhoto;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface PropertyPhotoRepository extends JpaRepository<PropertyPhoto, UUID> {

    List<PropertyPhoto> findAllByPropertyIdOrderBySortOrderAsc(UUID propertyId);

    /**
     * Photos for a whole page of properties, so the portfolio list resolves its
     * cover images in one query instead of one per card.
     *
     * <p>Ordering by {@code sortOrder} then {@code createdAt} makes "first row
     * wins" a deterministic cover-photo rule even when an owner leaves several
     * photos at the default {@code sortOrder} of 0.
     */
    @Query("""
            SELECT p FROM PropertyPhoto p
            WHERE p.propertyId IN :propertyIds
            ORDER BY p.propertyId ASC, p.sortOrder ASC, p.createdAt ASC
            """)
    List<PropertyPhoto> findAllForProperties(@Param("propertyIds") Collection<UUID> propertyIds);
}
