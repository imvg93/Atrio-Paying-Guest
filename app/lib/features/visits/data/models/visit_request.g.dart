// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VisitRequest _$VisitRequestFromJson(Map<String, dynamic> json) =>
    _VisitRequest(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      studentId: json['studentId'] as String,
      preferredDate: DateTime.parse(json['preferredDate'] as String),
      preferredSlot: $enumDecode(_$VisitSlotEnumMap, json['preferredSlot']),
      message: json['message'] as String?,
      status: $enumDecode(_$VisitRequestStatusEnumMap, json['status']),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      propertyName: json['propertyName'] as String?,
      propertyLocality: json['propertyLocality'] as String?,
      propertyPhotoUrl: json['propertyPhotoUrl'] as String?,
      studentName: json['studentName'] as String?,
      studentPhone: json['studentPhone'] as String?,
    );

Map<String, dynamic> _$VisitRequestToJson(_VisitRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'studentId': instance.studentId,
      'preferredDate': instance.preferredDate.toIso8601String(),
      'preferredSlot': _$VisitSlotEnumMap[instance.preferredSlot]!,
      'message': instance.message,
      'status': _$VisitRequestStatusEnumMap[instance.status]!,
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'propertyName': instance.propertyName,
      'propertyLocality': instance.propertyLocality,
      'propertyPhotoUrl': instance.propertyPhotoUrl,
      'studentName': instance.studentName,
      'studentPhone': instance.studentPhone,
    };

const _$VisitSlotEnumMap = {
  VisitSlot.morning: 'morning',
  VisitSlot.afternoon: 'afternoon',
  VisitSlot.evening: 'evening',
};

const _$VisitRequestStatusEnumMap = {
  VisitRequestStatus.pending: 'pending',
  VisitRequestStatus.accepted: 'accepted',
  VisitRequestStatus.declined: 'declined',
  VisitRequestStatus.completed: 'completed',
  VisitRequestStatus.cancelled: 'cancelled',
};
