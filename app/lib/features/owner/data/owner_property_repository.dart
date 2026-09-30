import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import '../../properties/data/models/property.dart';
import 'models/property_draft.dart';

/// Owner-side property endpoints (CLAUDE.md 6, Owner).
///
/// Every call is already scoped to the signed-in owner server-side: the list is
/// filtered by `owner_id` in the query, and single-property routes answer
/// `403 PROPERTY_NOT_OWNED` for somebody else's row. Nothing here needs to send
/// an owner id, and nothing here should filter by one.
class OwnerPropertyRepository {
  OwnerPropertyRepository(this._api);

  final ApiClient _api;

  /// `GET /owner/properties` — the portfolio list (H1).
  Future<Paginated<PropertySummary>> list({
    int page = 1,
    int limit = 20,
    PropertyStatus? status,
  }) async {
    final data = await _api.get(
      '/owner/properties',
      query: <String, dynamic>{
        'page': page,
        'limit': limit,
        // The API spells enums with their database label, not the Dart name.
        'status': status?.wireValue,
      },
    ) as Map<String, dynamic>;

    return Paginated<PropertySummary>.fromJson(data, PropertySummary.fromJson);
  }

  /// `GET /owner/properties/:id` — the overview (H2) and the wizard in edit mode.
  Future<Property> get(String id) async {
    final data = await _api.get('/owner/properties/$id');
    return Property.fromJson(data as Map<String, dynamic>);
  }

  /// `POST /owner/properties` — always creates a draft; publishing is
  /// [updateStatus].
  Future<Property> create(PropertyDraft draft) async {
    final data = await _api.post('/owner/properties', body: draft.toCreateJson());
    return Property.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /owner/properties/:id` with only the fields that changed.
  ///
  /// Returns [original] untouched when the draft matches it, rather than
  /// sending an empty patch — a no-op request that would still bump
  /// `updated_at`.
  Future<Property> update({
    required Property original,
    required PropertyDraft draft,
  }) async {
    final body = draft.toUpdateJson(original);
    if (body.isEmpty) return original;

    final data = await _api.patch('/owner/properties/${original.id}', body: body);
    return Property.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /owner/properties/:id/status` — H11's publish switch.
  Future<Property> updateStatus(String id, PropertyStatus status) async {
    final data = await _api.patch(
      '/owner/properties/$id/status',
      body: <String, dynamic>{'status': status.wireValue},
    );
    return Property.fromJson(data as Map<String, dynamic>);
  }

  /// `DELETE /owner/properties/:id` — a soft delete server-side, so the
  /// property stops being visible but its history survives.
  Future<void> delete(String id) async {
    await _api.delete('/owner/properties/$id');
  }
}

final ownerPropertyRepositoryProvider = Provider<OwnerPropertyRepository>((ref) {
  return OwnerPropertyRepository(ref.watch(apiClientProvider));
});
