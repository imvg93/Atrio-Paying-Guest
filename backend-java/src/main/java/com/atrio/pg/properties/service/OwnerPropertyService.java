package com.atrio.pg.properties.service;

import com.atrio.pg.beds.domain.BedStatus;
import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.pagination.PagedResponse;
import com.atrio.pg.common.pagination.PageQuery;
import com.atrio.pg.common.security.PropertyAccess;
import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.properties.domain.PropertyPhoto;
import com.atrio.pg.properties.domain.PropertyStatus;
import com.atrio.pg.properties.dto.CreatePropertyRequest;
import com.atrio.pg.properties.dto.PropertyDetailResponse;
import com.atrio.pg.properties.dto.PropertyPhotoResponse;
import com.atrio.pg.properties.dto.PropertyStats;
import com.atrio.pg.properties.dto.PropertySummaryResponse;
import com.atrio.pg.properties.dto.UpdatePropertyRequest;
import com.atrio.pg.properties.repository.PropertyPhotoRepository;
import com.atrio.pg.properties.repository.PropertyRepository;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Owner-side property management (Wave 1: H1, H2, H3, H11).
 *
 * <p>The role guard in {@code SecurityConfig} has already established that the
 * caller is an owner. Whether it is <em>their</em> property is answered here,
 * through {@link PropertyAccess} - never in the controller (CLAUDE.md 3.13).
 * Every method that takes a property id routes through it, including the read
 * paths: a listing's rent, occupancy and address are commercially sensitive.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OwnerPropertyService {

    /**
     * Newest first. Owners add properties rarely and look for the one they just
     * created, so recency beats alphabetical here.
     */
    private static final Sort DEFAULT_SORT = Sort.by(Sort.Direction.DESC, "createdAt");

    private final PropertyRepository propertyRepository;
    private final PropertyPhotoRepository photoRepository;
    private final PropertyAccess propertyAccess;

    // ---- reads --------------------------------------------------------

    /**
     * H1's portfolio list, scoped to the caller by query rather than by check:
     * there is no id to authorize, and {@code findAllByOwnerId} cannot return
     * somebody else's row.
     *
     * @param status optional filter; null means every status
     */
    @Transactional(readOnly = true)
    public PagedResponse<PropertySummaryResponse> list(
            UUID ownerId, PageQuery pageQuery, PropertyStatus status) {

        Pageable pageable = PageRequest.of(
                pageQuery.zeroBasedPage(), pageQuery.limitOrDefault(), DEFAULT_SORT);

        Page<Property> page = status == null
                ? propertyRepository.findAllByOwnerId(ownerId, pageable)
                : propertyRepository.findAllByOwnerIdAndStatus(ownerId, status, pageable);

        List<UUID> ids = page.getContent().stream().map(Property::getId).toList();
        Map<UUID, PropertyStats> stats = statsByProperty(ids);
        Map<UUID, List<PropertyPhoto>> photos = photosByProperty(ids);

        return PagedResponse.from(page, property -> {
            List<PropertyPhoto> propertyPhotos =
                    photos.getOrDefault(property.getId(), List.of());
            String cover = propertyPhotos.isEmpty() ? null : propertyPhotos.getFirst().getUrl();
            return PropertySummaryResponse.from(
                    property,
                    stats.getOrDefault(property.getId(), PropertyStats.EMPTY),
                    cover,
                    propertyPhotos.size());
        });
    }

    /** H2's overview and the wizard's edit mode. */
    @Transactional(readOnly = true)
    public PropertyDetailResponse get(UUID ownerId, UUID propertyId) {
        Property property = propertyAccess.require(ownerId, propertyId);
        return detail(property);
    }

    // ---- writes -------------------------------------------------------

    /** Always creates a {@code draft}; see {@link CreatePropertyRequest}. */
    @Transactional
    public PropertyDetailResponse create(UUID ownerId, CreatePropertyRequest request) {
        Property property = new Property();
        property.setOwnerId(ownerId);
        property.setName(request.name().trim());
        property.setDescription(blankToNull(request.description()));
        property.setGenderType(request.genderType());
        property.setAddressLine(request.addressLine().trim());
        property.setLocality(request.locality().trim());
        property.setCity(request.city().trim());
        property.setState(request.state().trim());
        property.setPincode(request.pincode().trim());
        property.setLatitude(request.latitude());
        property.setLongitude(request.longitude());
        property.setAmenities(request.amenitiesOrEmpty());
        property.setRules(request.rules());
        property.setFoodIncluded(request.foodIncludedOrDefault());
        property.setNoticePeriodDays(request.noticePeriodDaysOrDefault());
        property.setStatus(PropertyStatus.DRAFT);

        Property saved = propertyRepository.save(property);
        log.info("Owner {} created property {} ({})", ownerId, saved.getId(), saved.getName());
        return detail(saved);
    }

    /**
     * Patch semantics: a null field is untouched. See
     * {@link UpdatePropertyRequest} for how the two nullable fields are cleared.
     */
    @Transactional
    public PropertyDetailResponse update(
            UUID ownerId, UUID propertyId, UpdatePropertyRequest request) {

        if (request.hasPartialCoordinates()) {
            throw ApiException.badRequest(
                    "latitude and longitude must be sent together.");
        }

        Property property = propertyAccess.require(ownerId, propertyId);

        if (request.name() != null) {
            property.setName(request.name().trim());
        }
        if (request.description() != null) {
            // "" is the clear signal; anything else is the new text.
            property.setDescription(blankToNull(request.description()));
        }
        if (request.genderType() != null) {
            property.setGenderType(request.genderType());
        }
        if (request.addressLine() != null) {
            property.setAddressLine(request.addressLine().trim());
        }
        if (request.locality() != null) {
            property.setLocality(request.locality().trim());
        }
        if (request.city() != null) {
            property.setCity(request.city().trim());
        }
        if (request.state() != null) {
            property.setState(request.state().trim());
        }
        if (request.pincode() != null) {
            property.setPincode(request.pincode().trim());
        }
        if (request.latitude() != null) {
            property.setLatitude(request.latitude());
            property.setLongitude(request.longitude());
        }
        if (request.amenities() != null) {
            // Replaced wholesale, not merged: with a merge there would be no way
            // to turn an amenity off, only to set it false, and the two are
            // indistinguishable to a client rebuilding the map from a form.
            property.setAmenities(new LinkedHashMap<>(request.amenities()));
        }
        if (request.rules() != null) {
            property.setRules(request.rules().isEmpty() ? null : request.rules());
        }
        if (request.foodIncluded() != null) {
            property.setFoodIncluded(request.foodIncluded());
        }
        if (request.noticePeriodDays() != null) {
            property.setNoticePeriodDays(request.noticePeriodDays());
        }

        return detail(propertyRepository.save(property));
    }

    /**
     * H11's publish switch.
     *
     * <p>Publishing an empty property is deliberately allowed. Rooms and beds
     * are Wave 2, so a "must have at least one bed" rule would make the Wave 1
     * wizard unable to finish. It is also harmless: the public search endpoint
     * only returns published properties that have an available bed, so a
     * roomless listing is simply invisible until it is filled.
     */
    @Transactional
    public PropertyDetailResponse updateStatus(
            UUID ownerId, UUID propertyId, PropertyStatus status) {

        Property property = propertyAccess.require(ownerId, propertyId);
        PropertyStatus previous = property.getStatus();
        property.setStatus(status);

        log.info("Owner {} moved property {} from {} to {}",
                ownerId, propertyId, previous.dbValue(), status.dbValue());
        return detail(propertyRepository.save(property));
    }

    /**
     * Soft delete (CLAUDE.md 3.2). {@code @SQLDelete} on the entity turns this
     * into an {@code UPDATE ... SET deleted_at = now()}, so the row and its
     * occupancy history survive; it simply stops being visible.
     */
    @Transactional
    public void delete(UUID ownerId, UUID propertyId) {
        Property property = propertyAccess.require(ownerId, propertyId);
        propertyRepository.delete(property);
        log.info("Owner {} deleted property {}", ownerId, propertyId);
    }

    // ---- helpers ------------------------------------------------------

    private PropertyDetailResponse detail(Property property) {
        PropertyStats stats = statsByProperty(List.of(property.getId()))
                .getOrDefault(property.getId(), PropertyStats.EMPTY);

        List<PropertyPhotoResponse> photos =
                photoRepository.findAllByPropertyIdOrderBySortOrderAsc(property.getId())
                        .stream()
                        .map(PropertyPhotoResponse::from)
                        .toList();

        return PropertyDetailResponse.from(property, stats, photos);
    }

    private Map<UUID, PropertyStats> statsByProperty(Collection<UUID> propertyIds) {
        if (propertyIds.isEmpty()) {
            // An empty IN list is a syntax error in Postgres, and there is
            // nothing to ask about anyway.
            return Map.of();
        }
        return propertyRepository
                .statsForProperties(propertyIds, BedStatus.OCCUPIED, BedStatus.AVAILABLE)
                .stream()
                .collect(Collectors.toMap(PropertyStats::propertyId, Function.identity()));
    }

    private Map<UUID, List<PropertyPhoto>> photosByProperty(Collection<UUID> propertyIds) {
        if (propertyIds.isEmpty()) {
            return Map.of();
        }
        return photoRepository.findAllForProperties(propertyIds).stream()
                .collect(Collectors.groupingBy(PropertyPhoto::getPropertyId));
    }

    private static String blankToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
