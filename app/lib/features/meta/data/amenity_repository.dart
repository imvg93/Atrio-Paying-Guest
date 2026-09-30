import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'amenity.dart';

/// `GET /meta/amenities` — the canonical amenity catalogue.
class AmenityRepository {
  AmenityRepository(this._api);

  final ApiClient _api;

  Future<List<Amenity>> list() async {
    final data = await _api.get('/meta/amenities') as Map<String, dynamic>;
    final items = data['amenities'] as List<dynamic>? ?? const [];
    return items
        .map((e) => Amenity.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}

final amenityRepositoryProvider = Provider<AmenityRepository>((ref) {
  return AmenityRepository(ref.watch(apiClientProvider));
});

/// The catalogue, fetched once and held for the session.
///
/// `keepAlive` because it is reference data that changes a few times a year:
/// refetching it every time the wizard opens the amenities step would be a
/// round trip for an answer that cannot have changed.
final amenityCatalogueProvider = FutureProvider<List<Amenity>>((ref) {
  ref.keepAlive();
  return ref.watch(amenityRepositoryProvider).list();
});

/// The catalogue grouped for rendering, in [amenityGroupOrder] with any
/// unknown group appended rather than dropped.
final groupedAmenitiesProvider =
    Provider<AsyncValue<List<MapEntry<String, List<Amenity>>>>>((ref) {
  return ref.watch(amenityCatalogueProvider).whenData((amenities) {
    final byGroup = <String, List<Amenity>>{};
    for (final amenity in amenities) {
      byGroup.putIfAbsent(amenity.group, () => <Amenity>[]).add(amenity);
    }

    final ordered = <MapEntry<String, List<Amenity>>>[];
    for (final group in amenityGroupOrder) {
      final entries = byGroup.remove(group);
      if (entries != null) ordered.add(MapEntry(group, entries));
    }
    // Anything the app has not been taught about still gets shown.
    byGroup.forEach((group, entries) => ordered.add(MapEntry(group, entries)));
    return ordered;
  });
});
