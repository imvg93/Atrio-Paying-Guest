// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amenity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Amenity _$AmenityFromJson(Map<String, dynamic> json) => _Amenity(
  key: json['key'] as String,
  label: json['label'] as String,
  group: json['group'] as String? ?? 'other',
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$AmenityToJson(_Amenity instance) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'group': instance.group,
  'icon': instance.icon,
};
