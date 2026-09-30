package com.atrio.pg.meta.web;

import com.atrio.pg.meta.dto.AmenityResponse;
import com.atrio.pg.meta.service.AmenityCatalogue;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * {@code /api/v1/meta/*} - server-driven reference data (CLAUDE.md 6, Shared).
 *
 * <p>Authenticated, by the {@code anyRequest().authenticated()} default. Nothing
 * here is secret, but the H3 wizard and the student filter sheet are both behind
 * login, so there is no caller that needs it open. If the public search endpoint
 * later wants the catalogue before sign-in, that is a one-line matcher change.
 */
@RestController
@RequestMapping("/meta")
@RequiredArgsConstructor
public class MetaController {

    private final AmenityCatalogue amenityCatalogue;

    /**
     * The amenity catalogue the H3 wizard renders and the property detail grid
     * labels from.
     *
     * <p>Wrapped in an object rather than returned as a bare array: {@code data}
     * is an object everywhere else in this API, and a wrapper leaves room to add
     * group metadata later without a breaking change (CLAUDE.md 3.9, 3.10).
     */
    @GetMapping("/amenities")
    public AmenitiesResponse amenities() {
        return new AmenitiesResponse(amenityCatalogue.all());
    }

    public record AmenitiesResponse(List<AmenityResponse> amenities) {
    }
}
