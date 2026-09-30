package com.atrio.pg.properties.domain;

import com.atrio.pg.common.persistence.BaseEntity;
import com.atrio.pg.users.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import org.hibernate.type.SqlTypes;

/**
 * Table {@code properties}.
 *
 * <p>{@code minRentPaise} / {@code maxRentPaise} are denormalized from rooms
 * for search cards. <strong>Nothing maintains them yet</strong> - see
 * MIGRATION_PLAN.md Step 5, which adds a database trigger. Until then they
 * stay null and rent sorting/filtering cannot work.
 */
@Entity
@Table(name = "properties")
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE properties SET deleted_at = now() WHERE id = ?")
@Getter
@Setter
@NoArgsConstructor
public class Property extends BaseEntity {

    @Column(name = "owner_id", nullable = false)
    private UUID ownerId;

    @Column(name = "name", nullable = false, length = 255)
    private String name;

    @Column(name = "description", columnDefinition = "text")
    private String description;

    @Column(name = "gender_type", nullable = false,
            columnDefinition = "properties_gender_type_enum")
    private PropertyGenderType genderType;

    @Column(name = "address_line", nullable = false, length = 512)
    private String addressLine;

    @Column(name = "locality", nullable = false, length = 255)
    private String locality;

    @Column(name = "city", nullable = false, length = 255)
    private String city;

    @Column(name = "state", nullable = false, length = 255)
    private String state;

    @Column(name = "pincode", nullable = false, length = 10)
    private String pincode;

    @Column(name = "latitude", nullable = false, precision = 9, scale = 6)
    private BigDecimal latitude;

    @Column(name = "longitude", nullable = false, precision = 9, scale = 6)
    private BigDecimal longitude;

    /** e.g. {"wifi": true, "food": true, "ac": false}. Filtered with JSONB containment. */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "amenities", nullable = false, columnDefinition = "jsonb")
    private Map<String, Boolean> amenities = new LinkedHashMap<>();

    /** e.g. {"gateClosingTime": "22:30", "visitorsAllowed": false}. */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "rules", columnDefinition = "jsonb")
    private Map<String, Object> rules;

    @Column(name = "food_included", nullable = false)
    private boolean foodIncluded = false;

    @Column(name = "notice_period_days", nullable = false)
    private int noticePeriodDays = 30;

    @Column(name = "status", nullable = false, columnDefinition = "properties_status_enum")
    private PropertyStatus status = PropertyStatus.DRAFT;

    /** Money is BIGINT paise (CLAUDE.md 3.7). Nullable, hence Long not long. */
    @Column(name = "min_rent_paise")
    private Long minRentPaise;

    @Column(name = "max_rent_paise")
    private Long maxRentPaise;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", insertable = false, updatable = false)
    private User owner;
}
