package com.atrio.pg.properties.dto;

import java.util.UUID;

/**
 * What a soft delete returns. Echoing the id lets a client reconcile an
 * optimistic removal without holding the request it sent.
 */
public record DeletedResponse(UUID id, boolean deleted) {

    public static DeletedResponse of(UUID id) {
        return new DeletedResponse(id, true);
    }
}
