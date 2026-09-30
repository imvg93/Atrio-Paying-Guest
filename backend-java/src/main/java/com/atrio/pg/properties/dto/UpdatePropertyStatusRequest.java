package com.atrio.pg.properties.dto;

import com.atrio.pg.properties.domain.PropertyStatus;
import jakarta.validation.constraints.NotNull;

/**
 * Body of {@code PATCH /owner/properties/:id/status} - the publish switch
 * behind H11 and the last step of the H3 wizard.
 */
public record UpdatePropertyStatusRequest(@NotNull PropertyStatus status) {
}
