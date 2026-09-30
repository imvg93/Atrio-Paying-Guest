package com.atrio.pg.meta.dto;

/**
 * One entry in the canonical amenity catalogue.
 *
 * @param key      the key stored in {@code properties.amenities} JSONB - the
 *                 only part that is contract, and never renamed once shipped
 * @param label    what the owner's checkbox and the student's amenity grid say
 * @param group    coarse grouping so the wizard can render sections without
 *                 hardcoding which amenity belongs where
 * @param icon     a name from the client's icon set; advisory, and a client
 *                 that does not recognise it falls back to a generic icon
 */
public record AmenityResponse(String key, String label, String group, String icon) {
}
