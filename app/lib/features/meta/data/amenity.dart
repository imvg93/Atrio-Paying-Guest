import 'package:freezed_annotation/freezed_annotation.dart';

part 'amenity.freezed.dart';
part 'amenity.g.dart';

/// One entry from `GET /meta/amenities`.
///
/// Server-driven so a new amenity reaches installed apps without a release
/// (CLAUDE.md 6). [key] is the only part that is contract — it is what lands in
/// `properties.amenities` JSONB — so never key UI off [label], which may be
/// reworded at any time.
@freezed
abstract class Amenity with _$Amenity {
  const factory Amenity({
    required String key,
    required String label,
    @Default('other') String group,

    /// A name from the client's icon set. Advisory: an unrecognised value falls
    /// back to a generic icon rather than failing to render.
    String? icon,
  }) = _Amenity;

  factory Amenity.fromJson(Map<String, dynamic> json) => _$AmenityFromJson(json);
}

/// Display order and titles for the groups the API sends. A group the app does
/// not know about still renders, at the end, under its raw name.
const amenityGroupOrder = <String>[
  'essentials',
  'room',
  'food',
  'safety',
  'common',
];

String amenityGroupTitle(String group) => switch (group) {
      'essentials' => 'Essentials',
      'room' => 'In the room',
      'food' => 'Food & kitchen',
      'safety' => 'Safety',
      'common' => 'Common areas',
      _ => group,
    };
