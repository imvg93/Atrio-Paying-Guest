package com.atrio.pg.properties.dto;

import com.atrio.pg.properties.domain.PropertyPhoto;
import java.util.UUID;

/** A photo as H8's manager and the detail carousel see it. */
public record PropertyPhotoResponse(
        UUID id,
        String url,
        int sortOrder,
        String caption) {

    public static PropertyPhotoResponse from(PropertyPhoto photo) {
        return new PropertyPhotoResponse(
                photo.getId(),
                photo.getUrl(),
                photo.getSortOrder(),
                photo.getCaption());
    }
}
