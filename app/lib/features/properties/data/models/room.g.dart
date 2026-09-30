// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bed _$BedFromJson(Map<String, dynamic> json) => _Bed(
  id: json['id'] as String,
  roomId: json['roomId'] as String,
  label: json['label'] as String,
  status: $enumDecode(_$BedStatusEnumMap, json['status']),
);

Map<String, dynamic> _$BedToJson(_Bed instance) => <String, dynamic>{
  'id': instance.id,
  'roomId': instance.roomId,
  'label': instance.label,
  'status': _$BedStatusEnumMap[instance.status]!,
};

const _$BedStatusEnumMap = {
  BedStatus.available: 'available',
  BedStatus.occupied: 'occupied',
  BedStatus.maintenance: 'maintenance',
};

_Room _$RoomFromJson(Map<String, dynamic> json) => _Room(
  id: json['id'] as String,
  propertyId: json['propertyId'] as String,
  roomNumber: json['roomNumber'] as String,
  floor: (json['floor'] as num?)?.toInt(),
  sharingType: $enumDecode(_$SharingTypeEnumMap, json['sharingType']),
  rentPerBedPaise: (json['rentPerBedPaise'] as num).toInt(),
  depositPaise: (json['depositPaise'] as num).toInt(),
  hasAttachedBathroom: json['hasAttachedBathroom'] as bool? ?? false,
  hasAc: json['hasAc'] as bool? ?? false,
  beds:
      (json['beds'] as List<dynamic>?)
          ?.map((e) => Bed.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Bed>[],
);

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
  'id': instance.id,
  'propertyId': instance.propertyId,
  'roomNumber': instance.roomNumber,
  'floor': instance.floor,
  'sharingType': _$SharingTypeEnumMap[instance.sharingType]!,
  'rentPerBedPaise': instance.rentPerBedPaise,
  'depositPaise': instance.depositPaise,
  'hasAttachedBathroom': instance.hasAttachedBathroom,
  'hasAc': instance.hasAc,
  'beds': instance.beds,
};

const _$SharingTypeEnumMap = {
  SharingType.single: 'single',
  SharingType.double_: 'double',
  SharingType.triple: 'triple',
  SharingType.fourPlus: 'four_plus',
};
