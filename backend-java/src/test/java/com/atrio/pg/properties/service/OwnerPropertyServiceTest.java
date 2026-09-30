package com.atrio.pg.properties.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.atrio.pg.beds.domain.BedStatus;
import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.exception.ErrorCode;
import com.atrio.pg.common.pagination.PageQuery;
import com.atrio.pg.common.security.OwnerIdPropertyAccess;
import com.atrio.pg.properties.domain.Property;
import com.atrio.pg.properties.domain.PropertyGenderType;
import com.atrio.pg.properties.domain.PropertyStatus;
import com.atrio.pg.properties.dto.CreatePropertyRequest;
import com.atrio.pg.properties.dto.PropertyDetailResponse;
import com.atrio.pg.properties.dto.PropertyStats;
import com.atrio.pg.properties.dto.UpdatePropertyRequest;
import com.atrio.pg.properties.repository.PropertyPhotoRepository;
import com.atrio.pg.properties.repository.PropertyRepository;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

/**
 * The service in isolation, wired to the <em>real</em>
 * {@link OwnerIdPropertyAccess} over a mocked repository - the point of these
 * tests is the ownership rule, and stubbing the thing that enforces it would
 * test nothing.
 */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class OwnerPropertyServiceTest {

    @Mock private PropertyRepository propertyRepository;
    @Mock private PropertyPhotoRepository photoRepository;

    private OwnerPropertyService service;

    private final UUID owner = UUID.randomUUID();
    private final UUID intruder = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new OwnerPropertyService(
                propertyRepository,
                photoRepository,
                new OwnerIdPropertyAccess(propertyRepository));

        // Stands in for the id Hibernate assigns on persist. Without it a
        // freshly created property has a null id and the stats lookup - which
        // keys on it - blows up in the test but not in production.
        when(propertyRepository.save(any(Property.class))).thenAnswer(invocation -> {
            Property saved = invocation.getArgument(0);
            if (saved.getId() == null) {
                saved.setId(UUID.randomUUID());
            }
            return saved;
        });
        when(propertyRepository.statsForProperties(anyCollection(), any(), any()))
                .thenReturn(List.of());
        when(photoRepository.findAllByPropertyIdOrderBySortOrderAsc(any()))
                .thenReturn(List.of());
    }

    private Property existing() {
        Property property = new Property();
        property.setId(UUID.randomUUID());
        property.setOwnerId(owner);
        property.setName("Sunrise PG");
        property.setDescription("Near the metro");
        property.setGenderType(PropertyGenderType.MALE);
        property.setAddressLine("12 MG Road");
        property.setLocality("Indiranagar");
        property.setCity("Bengaluru");
        property.setState("Karnataka");
        property.setPincode("560038");
        property.setLatitude(new BigDecimal("12.971599"));
        property.setLongitude(new BigDecimal("77.594566"));
        property.setAmenities(new LinkedHashMap<>(Map.of("wifi", true)));
        property.setStatus(PropertyStatus.DRAFT);
        when(propertyRepository.findById(property.getId())).thenReturn(Optional.of(property));
        return property;
    }

    private CreatePropertyRequest validCreate() {
        return new CreatePropertyRequest(
                "  Sunrise PG  ", "  Near the metro  ", PropertyGenderType.COLIVING,
                "12 MG Road", "Indiranagar", "Bengaluru", "Karnataka", "560038",
                new BigDecimal("12.971599"), new BigDecimal("77.594566"),
                Map.of("wifi", true), null, null, null);
    }

    // ---- ownership ----------------------------------------------------

    @Test
    @DisplayName("another owner reading a property gets 403 PROPERTY_NOT_OWNED")
    void readByAnotherOwnerIsForbidden() {
        Property property = existing();

        assertThatThrownBy(() -> service.get(intruder, property.getId()))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.PROPERTY_NOT_OWNED);
    }

    @Test
    @DisplayName("another owner cannot edit, publish or delete, and nothing is written")
    void writesByAnotherOwnerAreForbidden() {
        Property property = existing();
        UpdatePropertyRequest patch = new UpdatePropertyRequest(
                "Hijacked", null, null, null, null, null, null, null, null, null,
                null, null, null, null);

        assertThatThrownBy(() -> service.update(intruder, property.getId(), patch))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.PROPERTY_NOT_OWNED);

        assertThatThrownBy(() ->
                service.updateStatus(intruder, property.getId(), PropertyStatus.PUBLISHED))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.PROPERTY_NOT_OWNED);

        assertThatThrownBy(() -> service.delete(intruder, property.getId()))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.PROPERTY_NOT_OWNED);

        // The check must precede the write, not merely accompany it.
        verify(propertyRepository, never()).save(any(Property.class));
        verify(propertyRepository, never()).delete(any(Property.class));
        assertThat(property.getName()).isEqualTo("Sunrise PG");
        assertThat(property.getStatus()).isEqualTo(PropertyStatus.DRAFT);
    }

    @Test
    @DisplayName("an unknown id is 404, whoever asks")
    void unknownIsNotFound() {
        UUID missing = UUID.randomUUID();
        when(propertyRepository.findById(missing)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.get(owner, missing))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.NOT_FOUND);
    }

    // ---- create -------------------------------------------------------

    @Test
    @DisplayName("a new property is always a draft, owned by the caller, and trimmed")
    void createDefaults() {
        PropertyDetailResponse created = service.create(owner, validCreate());

        assertThat(created.status()).isEqualTo(PropertyStatus.DRAFT);
        assertThat(created.name()).isEqualTo("Sunrise PG");
        assertThat(created.description()).isEqualTo("Near the metro");
        assertThat(created.noticePeriodDays())
                .isEqualTo(CreatePropertyRequest.DEFAULT_NOTICE_PERIOD_DAYS);
        assertThat(created.foodIncluded()).isFalse();

        verify(propertyRepository).save(any(Property.class));
    }

    @Test
    @DisplayName("a property with no rooms reports zero beds rather than nulls")
    void createHasEmptyStats() {
        PropertyDetailResponse created = service.create(owner, validCreate());

        assertThat(created.occupancy().totalBeds()).isZero();
        assertThat(created.occupancy().occupiedBeds()).isZero();
        assertThat(created.minRentPaise()).isNull();
        assertThat(created.maxRentPaise()).isNull();
    }

    @Test
    @DisplayName("a blank description is stored as null, not as whitespace")
    void blankDescriptionBecomesNull() {
        CreatePropertyRequest request = new CreatePropertyRequest(
                "Sunrise PG", "   ", PropertyGenderType.MALE,
                "12 MG Road", "Indiranagar", "Bengaluru", "Karnataka", "560038",
                BigDecimal.ONE, BigDecimal.ONE, null, null, null, null);

        assertThat(service.create(owner, request).description()).isNull();
    }

    // ---- update -------------------------------------------------------

    @Test
    @DisplayName("an absent field is left alone; an empty description clears it")
    void patchSemantics() {
        Property property = existing();

        PropertyDetailResponse patched = service.update(owner, property.getId(),
                new UpdatePropertyRequest(
                        "Sunrise PG Deluxe", "", null, null, null, null, null, null,
                        null, null, null, null, null, null));

        assertThat(patched.name()).isEqualTo("Sunrise PG Deluxe");
        assertThat(patched.description()).isNull();
        // Untouched by the patch.
        assertThat(patched.city()).isEqualTo("Bengaluru");
        assertThat(patched.genderType()).isEqualTo(PropertyGenderType.MALE);
    }

    @Test
    @DisplayName("amenities are replaced wholesale, so an amenity can be removed")
    void amenitiesAreReplacedNotMerged() {
        Property property = existing();

        PropertyDetailResponse patched = service.update(owner, property.getId(),
                new UpdatePropertyRequest(
                        null, null, null, null, null, null, null, null, null, null,
                        Map.of("ac", true), null, null, null));

        assertThat(patched.amenities()).containsOnlyKeys("ac");
    }

    @Test
    @DisplayName("half a coordinate pair is rejected before anything is loaded")
    void partialCoordinatesAreRejected() {
        Property property = existing();

        assertThatThrownBy(() -> service.update(owner, property.getId(),
                new UpdatePropertyRequest(
                        null, null, null, null, null, null, null, null,
                        new BigDecimal("13.0"), null, null, null, null, null)))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.BAD_REQUEST);

        verify(propertyRepository, never()).save(any(Property.class));
    }

    // ---- status -------------------------------------------------------

    @Test
    @DisplayName("publishing a property with no rooms is allowed - search hides it anyway")
    void publishingAnEmptyPropertyIsAllowed() {
        Property property = existing();

        PropertyDetailResponse published =
                service.updateStatus(owner, property.getId(), PropertyStatus.PUBLISHED);

        assertThat(published.status()).isEqualTo(PropertyStatus.PUBLISHED);
        assertThat(published.occupancy().totalBeds()).isZero();
    }

    // ---- delete -------------------------------------------------------

    @Test
    @DisplayName("delete goes through the repository, which @SQLDelete turns into a soft delete")
    void deleteIsSoft() {
        Property property = existing();

        service.delete(owner, property.getId());

        verify(propertyRepository).delete(property);
    }

    // ---- list ---------------------------------------------------------

    @Test
    @DisplayName("an empty page asks for no stats and no photos")
    void emptyPageSkipsTheAggregates() {
        when(propertyRepository.findAllByOwnerId(eq(owner), any()))
                .thenReturn(new org.springframework.data.domain.PageImpl<>(
                        List.of(),
                        org.springframework.data.domain.PageRequest.of(0, PageQuery.DEFAULT_LIMIT),
                        0));

        var page = service.list(owner, new PageQuery(null, null), null);

        assertThat(page.items()).isEmpty();
        assertThat(page.page()).isEqualTo(1);
        assertThat(page.limit()).isEqualTo(PageQuery.DEFAULT_LIMIT);
        // An empty IN (...) list is a Postgres syntax error; the guard matters.
        verify(propertyRepository, never()).statsForProperties(anyCollection(), any(), any());
        verify(photoRepository, never()).findAllForProperties(anyCollection());
    }

    @Test
    @DisplayName("cards carry bed counts, rent range, cover photo and photo count")
    void cardsAreAssembledFromTheAggregates() {
        Property property = existing();
        when(propertyRepository.findAllByOwnerId(eq(owner), any()))
                .thenReturn(new org.springframework.data.domain.PageImpl<>(List.of(property)));
        when(propertyRepository.statsForProperties(
                anyCollection(), eq(BedStatus.OCCUPIED), eq(BedStatus.AVAILABLE)))
                .thenReturn(List.of(new PropertyStats(
                        property.getId(), 18L, 12L, 5L, 750_000L, 1_200_000L)));

        var photo = new com.atrio.pg.properties.domain.PropertyPhoto();
        photo.setId(UUID.randomUUID());
        photo.setPropertyId(property.getId());
        photo.setUrl("https://cdn.example/1.jpg");
        var second = new com.atrio.pg.properties.domain.PropertyPhoto();
        second.setId(UUID.randomUUID());
        second.setPropertyId(property.getId());
        second.setUrl("https://cdn.example/2.jpg");
        when(photoRepository.findAllForProperties(anyCollection()))
                .thenReturn(List.of(photo, second));

        var card = service.list(owner, new PageQuery(null, null), null).items().getFirst();

        assertThat(card.occupancy().totalBeds()).isEqualTo(18);
        assertThat(card.occupancy().occupiedBeds()).isEqualTo(12);
        assertThat(card.occupancy().availableBeds()).isEqualTo(5);
        // 18 - 12 - 5: whatever is neither occupied nor available is maintenance.
        assertThat(card.occupancy().maintenanceBeds()).isEqualTo(1);
        assertThat(card.minRentPaise()).isEqualTo(750_000L);
        assertThat(card.coverPhotoUrl()).isEqualTo("https://cdn.example/1.jpg");
        assertThat(card.photoCount()).isEqualTo(2);
    }

    @Test
    @DisplayName("a property with no rooms falls back to EMPTY rather than an NPE")
    void missingStatsRowIsHandled() {
        Property property = existing();
        when(propertyRepository.findAllByOwnerId(eq(owner), any()))
                .thenReturn(new org.springframework.data.domain.PageImpl<>(List.of(property)));
        // The aggregate query returns no row at all for a property with no beds.
        when(propertyRepository.statsForProperties(anyCollection(), any(), any()))
                .thenReturn(List.of());
        when(photoRepository.findAllForProperties(anyCollection())).thenReturn(List.of());

        var card = service.list(owner, new PageQuery(null, null), null).items().getFirst();

        assertThat(card.occupancy().totalBeds()).isZero();
        assertThat(card.coverPhotoUrl()).isNull();
        assertThat(card.photoCount()).isZero();
    }
}
