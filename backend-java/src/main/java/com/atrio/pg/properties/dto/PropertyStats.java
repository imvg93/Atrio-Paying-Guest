package com.atrio.pg.properties.dto;

import java.util.UUID;

/**
 * Bed counts and live rent range for one property, aggregated over its rooms
 * and beds.
 *
 * <p><strong>Why the rent range is computed here rather than read from
 * {@code properties.min_rent_paise}.</strong> Those denormalized columns are
 * maintained by nothing today - the trigger that fills them is Wave 2 work. A
 * card that renders whatever is in them would show null, or worse, a stale
 * price. Aggregating over {@code rooms} is one indexed group-by per page and is
 * correct by construction; the denormalized columns stay for the public search
 * endpoint, which cannot afford the join.
 *
 * <p>Every field is boxed because this is built by a JPQL constructor
 * expression: {@code COUNT}/{@code SUM}/{@code MIN} all hand back {@code Long},
 * and a property with no rooms produces no row at all - hence {@link #EMPTY}.
 */
public record PropertyStats(
        UUID propertyId,
        Long totalBeds,
        Long occupiedBeds,
        Long availableBeds,
        Long minRentPaise,
        Long maxRentPaise) {

    /** What a property with no rooms (or no beds) looks like. */
    public static final PropertyStats EMPTY =
            new PropertyStats(null, 0L, 0L, 0L, null, null);

    public long total() {
        return totalBeds == null ? 0L : totalBeds;
    }

    public long occupied() {
        return occupiedBeds == null ? 0L : occupiedBeds;
    }

    public long available() {
        return availableBeds == null ? 0L : availableBeds;
    }

    /** Whatever is left over is under maintenance - the third bed status. */
    public long maintenance() {
        return total() - occupied() - available();
    }
}
