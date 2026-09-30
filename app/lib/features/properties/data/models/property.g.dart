// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PropertyPhoto _$PropertyPhotoFromJson(Map<String, dynamic> json) =>
    _PropertyPhoto(
      id: json['id'] as String,
      url: json['url'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      caption: json['caption'] as String?,
    );

Map<String, dynamic> _$PropertyPhotoToJson(_PropertyPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'sortOrder': instance.sortOrder,
      'caption': instance.caption,
    };

_OccupancySummary _$OccupancySummaryFromJson(Map<String, dynamic> json) =>
    _OccupancySummary(
      totalBeds: (json['totalBeds'] as num?)?.toInt() ?? 0,
      occupiedBeds: (json['occupiedBeds'] as num?)?.toInt() ?? 0,
      availableBeds: (json['availableBeds'] as num?)?.toInt() ?? 0,
      maintenanceBeds: (json['maintenanceBeds'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OccupancySummaryToJson(_OccupancySummary instance) =>
    <String, dynamic>{
      'totalBeds': instance.totalBeds,
      'occupiedBeds': instance.occupiedBeds,
      'availableBeds': instance.availableBeds,
      'maintenanceBeds': instance.maintenanceBeds,
    };

_PropertySummary _$PropertySummaryFromJson(Map<String, dynamic> json) =>
    _PropertySummary(
      id: json['id'] as String,
      name: json['name'] as String,
      locality: json['locality'] as String,
      city: json['city'] as String,
      genderType: $enumDecode(_$PropertyGenderTypeEnumMap, json['genderType']),
      status: $enumDecode(_$PropertyStatusEnumMap, json['status']),
      foodIncluded: json['foodIncluded'] as bool? ?? false,
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      photoCount: (json['photoCount'] as num?)?.toInt() ?? 0,
      occupancy: json['occupancy'] == null
          ? const OccupancySummary()
          : OccupancySummary.fromJson(
              json['occupancy'] as Map<String, dynamic>,
            ),
      minRentPaise: (json['minRentPaise'] as num?)?.toInt(),
      maxRentPaise: (json['maxRentPaise'] as num?)?.toInt(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PropertySummaryToJson(_PropertySummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'locality': instance.locality,
      'city': instance.city,
      'genderType': _$PropertyGenderTypeEnumMap[instance.genderType]!,
      'status': _$PropertyStatusEnumMap[instance.status]!,
      'foodIncluded': instance.foodIncluded,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'photoCount': instance.photoCount,
      'occupancy': instance.occupancy,
      'minRentPaise': instance.minRentPaise,
      'maxRentPaise': instance.maxRentPaise,
      'distanceKm': instance.distanceKm,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PropertyGenderTypeEnumMap = {
  PropertyGenderType.male: 'male',
  PropertyGenderType.female: 'female',
  PropertyGenderType.coliving: 'coliving',
};

const _$PropertyStatusEnumMap = {
  PropertyStatus.draft: 'draft',
  PropertyStatus.published: 'published',
  PropertyStatus.unlisted: 'unlisted',
};

_Property _$PropertyFromJson(Map<String, dynamic> json) => _Property(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  genderType: $enumDecode(_$PropertyGenderTypeEnumMap, json['genderType']),
  addressLine: json['addressLine'] as String,
  locality: json['locality'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  pincode: json['pincode'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  amenities:
      (json['amenities'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const <String, bool>{},
  rules: json['rules'] as Map<String, dynamic>?,
  foodIncluded: json['foodIncluded'] as bool? ?? false,
  noticePeriodDays: (json['noticePeriodDays'] as num?)?.toInt() ?? 30,
  status: $enumDecode(_$PropertyStatusEnumMap, json['status']),
  photos:
      (json['photos'] as List<dynamic>?)
          ?.map((e) => PropertyPhoto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PropertyPhoto>[],
  occupancy: json['occupancy'] == null
      ? const OccupancySummary()
      : OccupancySummary.fromJson(json['occupancy'] as Map<String, dynamic>),
  minRentPaise: (json['minRentPaise'] as num?)?.toInt(),
  maxRentPaise: (json['maxRentPaise'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PropertyToJson(_Property instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'genderType': _$PropertyGenderTypeEnumMap[instance.genderType]!,
  'addressLine': instance.addressLine,
  'locality': instance.locality,
  'city': instance.city,
  'state': instance.state,
  'pincode': instance.pincode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'amenities': instance.amenities,
  'rules': instance.rules,
  'foodIncluded': instance.foodIncluded,
  'noticePeriodDays': instance.noticePeriodDays,
  'status': _$PropertyStatusEnumMap[instance.status]!,
  'photos': instance.photos,
  'occupancy': instance.occupancy,
  'minRentPaise': instance.minRentPaise,
  'maxRentPaise': instance.maxRentPaise,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
