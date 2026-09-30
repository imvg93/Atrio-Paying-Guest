package com.atrio.pg.meta.service;

import com.atrio.pg.meta.dto.AmenityResponse;
import java.util.List;
import org.springframework.stereotype.Component;

/**
 * The canonical amenity list, served from the API so a new amenity reaches
 * every installed app without a release (CLAUDE.md 6, Shared).
 *
 * <p><strong>Why a constant and not a table.</strong> The plan's open question
 * was where this list lives. It is a catalogue of about twenty entries that
 * changes a few times a year, has no per-owner variation, and needs no
 * administration UI - a table would buy nothing over a redeploy and would add a
 * migration, a repository and a cache. The seam that matters is the endpoint:
 * clients already fetch it rather than hardcoding it, so moving the source to a
 * table later changes this class and nothing else.
 *
 * <p><strong>Keys are permanent.</strong> They are stored verbatim in
 * {@code properties.amenities} JSONB. Renaming one would orphan the flag on
 * every property that has it set, with no migration to catch it - so add and
 * deprecate, never rename.
 */
@Component
public class AmenityCatalogue {

    private static final List<AmenityResponse> AMENITIES = List.of(
            // Essentials
            new AmenityResponse("wifi", "Wi-Fi", "essentials", "wifi"),
            new AmenityResponse("power_backup", "Power backup", "essentials", "bolt"),
            new AmenityResponse("water_24x7", "24x7 water", "essentials", "water_drop"),
            new AmenityResponse("housekeeping", "Housekeeping", "essentials", "cleaning_services"),
            new AmenityResponse("laundry", "Laundry", "essentials", "local_laundry_service"),

            // Room
            new AmenityResponse("ac", "Air conditioning", "room", "ac_unit"),
            new AmenityResponse("attached_bathroom", "Attached bathroom", "room", "bathtub"),
            new AmenityResponse("geyser", "Geyser", "room", "hot_tub"),
            new AmenityResponse("wardrobe", "Wardrobe", "room", "checkroom"),
            new AmenityResponse("study_table", "Study table", "room", "desk"),

            // Food
            new AmenityResponse("meals", "Meals included", "food", "restaurant"),
            new AmenityResponse("kitchen_access", "Kitchen access", "food", "kitchen"),
            new AmenityResponse("refrigerator", "Refrigerator", "food", "kitchen"),
            new AmenityResponse("ro_water", "RO drinking water", "food", "water_full"),

            // Safety
            new AmenityResponse("cctv", "CCTV", "safety", "videocam"),
            new AmenityResponse("security_guard", "Security guard", "safety", "security"),
            new AmenityResponse("biometric_entry", "Biometric entry", "safety", "fingerprint"),
            new AmenityResponse("fire_safety", "Fire safety", "safety", "fire_extinguisher"),

            // Common areas
            new AmenityResponse("parking", "Parking", "common", "local_parking"),
            new AmenityResponse("lift", "Lift", "common", "elevator"),
            new AmenityResponse("gym", "Gym", "common", "fitness_center"),
            new AmenityResponse("common_tv", "Common TV area", "common", "tv"),
            new AmenityResponse("terrace_access", "Terrace access", "common", "deck"));

    public List<AmenityResponse> all() {
        return AMENITIES;
    }
}
