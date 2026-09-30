import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../properties/data/models/property.dart';

part 'property_draft.freezed.dart';

/// The H3 wizard's working copy of a property, carried across all five steps.
///
/// Not a [Property]: a half-filled wizard has no id, no status and possibly no
/// location yet, so every field here is optional in a way the API model must
/// never be. It converts to a request body at the end, not before.
///
/// No `fromJson` — this is only ever built from a form or from an existing
/// [Property] via [PropertyDraft.from].
@freezed
abstract class PropertyDraft with _$PropertyDraft {
  const factory PropertyDraft({
    @Default('') String name,
    @Default('') String description,
    PropertyGenderType? genderType,
    @Default('') String addressLine,
    @Default('') String locality,
    @Default('') String city,
    @Default('') String state,
    @Default('') String pincode,
    double? latitude,
    double? longitude,
    @Default(<String, bool>{}) Map<String, bool> amenities,
    @Default(<String, dynamic>{}) Map<String, dynamic> rules,
    @Default(false) bool foodIncluded,
    @Default(30) int noticePeriodDays,
  }) = _PropertyDraft;

  const PropertyDraft._();

  /// Seeds the wizard in edit mode.
  factory PropertyDraft.from(Property property) => PropertyDraft(
        name: property.name,
        description: property.description ?? '',
        genderType: property.genderType,
        addressLine: property.addressLine,
        locality: property.locality,
        city: property.city,
        state: property.state,
        pincode: property.pincode,
        latitude: property.latitude,
        longitude: property.longitude,
        amenities: Map<String, bool>.from(property.amenities),
        rules: Map<String, dynamic>.from(property.rules ?? const {}),
        foodIncluded: property.foodIncluded,
        noticePeriodDays: property.noticePeriodDays,
      );

  // ---- per-step completeness, for the stepper's "Next" button ----------

  bool get hasBasics =>
      name.trim().length >= 2 && genderType != null;

  /// The API requires the pin: `latitude`/`longitude` are NOT NULL, so the
  /// wizard cannot save before this step is done.
  bool get hasLocation =>
      addressLine.trim().isNotEmpty &&
      locality.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      _isValidPincode(pincode) &&
      latitude != null &&
      longitude != null;

  bool get isSubmittable => hasBasics && hasLocation;

  static bool _isValidPincode(String value) =>
      RegExp(r'^[1-9][0-9]{5}$').hasMatch(value.trim());

  // ---- request bodies -------------------------------------------------

  /// Body for `POST /owner/properties`. Only valid once [isSubmittable].
  Map<String, dynamic> toCreateJson() {
    assert(isSubmittable, 'toCreateJson called on an incomplete draft');
    return <String, dynamic>{
      'name': name.trim(),
      if (description.trim().isNotEmpty) 'description': description.trim(),
      'genderType': genderType!.wireValue,
      'addressLine': addressLine.trim(),
      'locality': locality.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'pincode': pincode.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'amenities': amenities,
      if (rules.isNotEmpty) 'rules': rules,
      'foodIncluded': foodIncluded,
      'noticePeriodDays': noticePeriodDays,
    };
  }

  /// Body for `PATCH /owner/properties/:id`, containing only what changed.
  ///
  /// An absent key means "leave it alone" server-side, so sending the whole
  /// draft would silently overwrite anything edited elsewhere since the load.
  /// The two nullable fields have an empty form rather than a null one:
  /// `""` clears the description, `{}` clears the rules.
  Map<String, dynamic> toUpdateJson(Property original) {
    final body = <String, dynamic>{};

    void put(String key, Object? value, Object? current) {
      if (value != current) body[key] = value;
    }

    put('name', name.trim(), original.name);
    put('description', description.trim(), original.description ?? '');
    put('genderType', genderType?.wireValue, original.genderType.wireValue);
    put('addressLine', addressLine.trim(), original.addressLine);
    put('locality', locality.trim(), original.locality);
    put('city', city.trim(), original.city);
    put('state', state.trim(), original.state);
    put('pincode', pincode.trim(), original.pincode);
    put('foodIncluded', foodIncluded, original.foodIncluded);
    put('noticePeriodDays', noticePeriodDays, original.noticePeriodDays);

    // A pin is only meaningful as a pair; the API rejects half of one.
    if (latitude != original.latitude || longitude != original.longitude) {
      body['latitude'] = latitude;
      body['longitude'] = longitude;
    }

    // Maps need a deep comparison, and both are replaced wholesale server-side.
    const equality = DeepCollectionEquality();
    if (!equality.equals(amenities, original.amenities)) {
      body['amenities'] = amenities;
    }
    if (!equality.equals(rules, original.rules ?? const <String, dynamic>{})) {
      body['rules'] = rules;
    }

    return body;
  }
}
