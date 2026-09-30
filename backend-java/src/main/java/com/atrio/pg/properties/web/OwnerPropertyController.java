package com.atrio.pg.properties.web;

import com.atrio.pg.auth.security.AppUserPrincipal;
import com.atrio.pg.common.pagination.PagedResponse;
import com.atrio.pg.common.pagination.PageQuery;
import com.atrio.pg.properties.domain.PropertyStatus;
import com.atrio.pg.properties.dto.CreatePropertyRequest;
import com.atrio.pg.properties.dto.DeletedResponse;
import com.atrio.pg.properties.dto.PropertyDetailResponse;
import com.atrio.pg.properties.dto.PropertySummaryResponse;
import com.atrio.pg.properties.dto.UpdatePropertyRequest;
import com.atrio.pg.properties.dto.UpdatePropertyStatusRequest;
import com.atrio.pg.properties.service.OwnerPropertyService;
import jakarta.validation.Valid;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * {@code /api/v1/owner/properties} - CLAUDE.md 6, Owner.
 *
 * <p>Binding and delegation only. The role guard is doubled up deliberately:
 * {@code SecurityConfig} locks the whole {@code /owner/**} tree, and
 * {@code @PreAuthorize} states the requirement at the class that would break if
 * a future matcher change loosened the tree. Neither answers ownership - that
 * is {@link OwnerPropertyService}'s job through {@code PropertyAccess}
 * (CLAUDE.md 3.13).
 */
@RestController
@RequestMapping("/owner/properties")
@PreAuthorize("hasRole('OWNER')")
@RequiredArgsConstructor
public class OwnerPropertyController {

    private final OwnerPropertyService ownerPropertyService;

    /** H1's portfolio list. Paginated from day one (CLAUDE.md 3.11). */
    @GetMapping
    public PagedResponse<PropertySummaryResponse> list(
            @AuthenticationPrincipal AppUserPrincipal caller,
            @Valid PageQuery pageQuery,
            @RequestParam(required = false) PropertyStatus status) {

        return ownerPropertyService.list(caller.id(), pageQuery, status);
    }

    /** H2's overview. */
    @GetMapping("/{id}")
    public PropertyDetailResponse get(
            @AuthenticationPrincipal AppUserPrincipal caller,
            @PathVariable UUID id) {

        return ownerPropertyService.get(caller.id(), id);
    }

    /** H3 step 5. Creates a draft; publishing is a separate call. */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PropertyDetailResponse create(
            @AuthenticationPrincipal AppUserPrincipal caller,
            @Valid @RequestBody CreatePropertyRequest request) {

        return ownerPropertyService.create(caller.id(), request);
    }

    /** H3 in edit mode. */
    @PatchMapping("/{id}")
    public PropertyDetailResponse update(
            @AuthenticationPrincipal AppUserPrincipal caller,
            @PathVariable UUID id,
            @Valid @RequestBody UpdatePropertyRequest request) {

        return ownerPropertyService.update(caller.id(), id, request);
    }

    /** H11's publish switch. */
    @PatchMapping("/{id}/status")
    public PropertyDetailResponse updateStatus(
            @AuthenticationPrincipal AppUserPrincipal caller,
            @PathVariable UUID id,
            @Valid @RequestBody UpdatePropertyStatusRequest request) {

        return ownerPropertyService.updateStatus(caller.id(), id, request.status());
    }

    /**
     * Soft delete. Returns a body rather than 204 because the client unwraps
     * {@code {success, data}} on every response and treats an empty one as a
     * broken contract.
     */
    @DeleteMapping("/{id}")
    public DeletedResponse delete(
            @AuthenticationPrincipal AppUserPrincipal caller,
            @PathVariable UUID id) {

        ownerPropertyService.delete(caller.id(), id);
        return DeletedResponse.of(id);
    }
}
