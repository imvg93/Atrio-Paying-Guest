import 'package:freezed_annotation/freezed_annotation.dart';

part 'property.freezed.dart';
part 'property.g.dart';

/// `properties.gender_type`.
enum PropertyGenderType {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('coliving')
  coliving;

  String get label => switch (this) {
        PropertyGenderType.male => 'Boys',
        PropertyGenderType.female => 'Girls',
        PropertyGenderType.coliving => 'Co-living',
      };

  /// The label the API expects on the wire — `name` happens to match today,
  /// but relying on that would break the moment a value needs an underscore.
  String get wireValue => switch (this) {
        PropertyGenderType.male => 'male',
        PropertyGenderType.female => 'female',
        PropertyGenderType.coliving => 'coliving',
      };
}

/// `properties.status`. Only [published] appears in search.
enum PropertyStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('unlisted')
  unlisted;

  String get label => switch (this) {
        PropertyStatus.draft => 'Draft',
        PropertyStatus.published => 'Published',
        PropertyStatus.unlisted => 'Unlisted',
      };

  String get wireValue => switch (this) {
        PropertyStatus.draft => 'draft',
        PropertyStatus.published => 'published',
        PropertyStatus.unlisted => 'unlisted',
      };
}

@freezed
abstract class PropertyPhoto with _$PropertyPhoto {
  const factory PropertyPhoto({
    required String id,
    required String url,
    @Default(0) int sortOrder,
    String? caption,
  }) = _PropertyPhoto;

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) =>
      _$PropertyPhotoFromJson(json);
}

/// The "12/18 beds filled" figure, aggregated server-side from rooms and beds.
///
/// The API sends counts only and no percentage — how to round, and what to show
/// for a property with no rooms yet, are rendering decisions that belong here.
@freezed
abstract class OccupancySummary with _$OccupancySummary {
  const factory OccupancySummary({
    @Default(0) int totalBeds,
    @Default(0) int occupiedBeds,
    @Default(0) int availableBeds,
    @Default(0) int maintenanceBeds,
  }) = _OccupancySummary;

  const OccupancySummary._();

  factory OccupancySummary.fromJson(Map<String, dynamic> json) =>
      _$OccupancySummaryFromJson(json);

  /// True before any rooms exist — the caller should show "No rooms yet"
  /// rather than a 0% ring, which reads as a full vacancy.
  bool get hasNoBeds => totalBeds == 0;

  /// 0.0–1.0, and 0 rather than NaN when there is nothing to divide by.
  double get occupancyRate => totalBeds == 0 ? 0 : occupiedBeds / totalBeds;

  String get filledLabel => '$occupiedBeds/$totalBeds beds filled';
}

/// A property as the portfolio list (H1) and search results see it.
///
/// Deliberately narrower than [Property]: `GET /owner/properties` does not
/// send addresses, amenities or rules, so modelling the card with the detail
/// class would make every list parse fail on a missing required field.
@freezed
abstract class PropertySummary with _$PropertySummary {
  const factory PropertySummary({
    required String id,
    required String name,
    required String locality,
    required String city,
    required PropertyGenderType genderType,
    required PropertyStatus status,
    @Default(false) bool foodIncluded,
    String? coverPhotoUrl,
    @Default(0) int photoCount,
    @Default(OccupancySummary()) OccupancySummary occupancy,
    int? minRentPaise,
    int? maxRentPaise,

    /// Present on search results when the query supplied lat/lng.
    double? distanceKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PropertySummary;

  const PropertySummary._();

  factory PropertySummary.fromJson(Map<String, dynamic> json) =>
      _$PropertySummaryFromJson(json);

  bool get isPublished => status == PropertyStatus.published;

  String get shortAddress => '$locality, $city';

  /// Null when the property has no rooms, so the caller shows "Add rooms"
  /// instead of a price that does not exist yet.
  bool get hasRent => minRentPaise != null;
}

/// The full property, from `GET /owner/properties/:id`. Money fields are
/// **integer paise** (CLAUDE.md 3.7) — render them through `Money.format`.
@freezed
abstract class Property with _$Property {
  const factory Property({
    required String id,
    required String name,
    String? description,
    required PropertyGenderType genderType,
    required String addressLine,
    required String locality,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    @Default(<String, bool>{}) Map<String, bool> amenities,
    Map<String, dynamic>? rules,
    @Default(false) bool foodIncluded,
    @Default(30) int noticePeriodDays,
    required PropertyStatus status,
    @Default(<PropertyPhoto>[]) List<PropertyPhoto> photos,
    @Default(OccupancySummary()) OccupancySummary occupancy,
    int? minRentPaise,
    int? maxRentPaise,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Property;

  const Property._();

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);

  /// Amenity keys that are switched on, for chips and filter summaries.
  List<String> get activeAmenities => amenities.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList(growable: false);

  bool get isPublished => status == PropertyStatus.published;

  String get shortAddress => '$locality, $city';

  /// Null until rooms exist, so the caller shows a dash rather than "₹0".
  bool get hasRentRange => minRentPaise != null;

  PropertyPhoto? get coverPhoto => photos.isEmpty ? null : photos.first;

  /// The list shape, so a detail response can seed a card without a refetch.
  PropertySummary get asSummary => PropertySummary(
        id: id,
        name: name,
        locality: locality,
        city: city,
        genderType: genderType,
        status: status,
        foodIncluded: foodIncluded,
        coverPhotoUrl: coverPhoto?.url,
        photoCount: photos.length,
        occupancy: occupancy,
        minRentPaise: minRentPaise,
        maxRentPaise: maxRentPaise,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
