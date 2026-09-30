package com.atrio.pg.properties.dto;

/**
 * The "12/18 beds filled" figure behind H1's card and H2's occupancy ring.
 *
 * <p>Counts only, no percentage: a rate is a rendering decision (rounding,
 * the empty-property case) and belongs in the client, not on the wire.
 */
public record OccupancySummary(
        long totalBeds,
        long occupiedBeds,
        long availableBeds,
        long maintenanceBeds) {

    public static OccupancySummary from(PropertyStats stats) {
        return new OccupancySummary(
                stats.total(),
                stats.occupied(),
                stats.available(),
                stats.maintenance());
    }
}
