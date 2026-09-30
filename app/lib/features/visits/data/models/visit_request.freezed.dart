// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visit_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VisitRequest {

 String get id; String get propertyId; String get studentId; DateTime get preferredDate; VisitSlot get preferredSlot; String? get message; VisitRequestStatus get status; DateTime? get respondedAt; DateTime? get createdAt;/// Denormalized for list rendering so the client needn't fetch each
/// property separately.
 String? get propertyName; String? get propertyLocality; String? get propertyPhotoUrl; String? get studentName; String? get studentPhone;
/// Create a copy of VisitRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitRequestCopyWith<VisitRequest> get copyWith => _$VisitRequestCopyWithImpl<VisitRequest>(this as VisitRequest, _$identity);

  /// Serializes this VisitRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisitRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.preferredDate, preferredDate) || other.preferredDate == preferredDate)&&(identical(other.preferredSlot, preferredSlot) || other.preferredSlot == preferredSlot)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.propertyLocality, propertyLocality) || other.propertyLocality == propertyLocality)&&(identical(other.propertyPhotoUrl, propertyPhotoUrl) || other.propertyPhotoUrl == propertyPhotoUrl)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentPhone, studentPhone) || other.studentPhone == studentPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,propertyId,studentId,preferredDate,preferredSlot,message,status,respondedAt,createdAt,propertyName,propertyLocality,propertyPhotoUrl,studentName,studentPhone);

@override
String toString() {
  return 'VisitRequest(id: $id, propertyId: $propertyId, studentId: $studentId, preferredDate: $preferredDate, preferredSlot: $preferredSlot, message: $message, status: $status, respondedAt: $respondedAt, createdAt: $createdAt, propertyName: $propertyName, propertyLocality: $propertyLocality, propertyPhotoUrl: $propertyPhotoUrl, studentName: $studentName, studentPhone: $studentPhone)';
}


}

/// @nodoc
abstract mixin class $VisitRequestCopyWith<$Res>  {
  factory $VisitRequestCopyWith(VisitRequest value, $Res Function(VisitRequest) _then) = _$VisitRequestCopyWithImpl;
@useResult
$Res call({
 String id, String propertyId, String studentId, DateTime preferredDate, VisitSlot preferredSlot, String? message, VisitRequestStatus status, DateTime? respondedAt, DateTime? createdAt, String? propertyName, String? propertyLocality, String? propertyPhotoUrl, String? studentName, String? studentPhone
});




}
/// @nodoc
class _$VisitRequestCopyWithImpl<$Res>
    implements $VisitRequestCopyWith<$Res> {
  _$VisitRequestCopyWithImpl(this._self, this._then);

  final VisitRequest _self;
  final $Res Function(VisitRequest) _then;

/// Create a copy of VisitRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? propertyId = null,Object? studentId = null,Object? preferredDate = null,Object? preferredSlot = null,Object? message = freezed,Object? status = null,Object? respondedAt = freezed,Object? createdAt = freezed,Object? propertyName = freezed,Object? propertyLocality = freezed,Object? propertyPhotoUrl = freezed,Object? studentName = freezed,Object? studentPhone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,preferredDate: null == preferredDate ? _self.preferredDate : preferredDate // ignore: cast_nullable_to_non_nullable
as DateTime,preferredSlot: null == preferredSlot ? _self.preferredSlot : preferredSlot // ignore: cast_nullable_to_non_nullable
as VisitSlot,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VisitRequestStatus,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,propertyName: freezed == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String?,propertyLocality: freezed == propertyLocality ? _self.propertyLocality : propertyLocality // ignore: cast_nullable_to_non_nullable
as String?,propertyPhotoUrl: freezed == propertyPhotoUrl ? _self.propertyPhotoUrl : propertyPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentPhone: freezed == studentPhone ? _self.studentPhone : studentPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VisitRequest].
extension VisitRequestPatterns on VisitRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisitRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisitRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisitRequest value)  $default,){
final _that = this;
switch (_that) {
case _VisitRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisitRequest value)?  $default,){
final _that = this;
switch (_that) {
case _VisitRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String propertyId,  String studentId,  DateTime preferredDate,  VisitSlot preferredSlot,  String? message,  VisitRequestStatus status,  DateTime? respondedAt,  DateTime? createdAt,  String? propertyName,  String? propertyLocality,  String? propertyPhotoUrl,  String? studentName,  String? studentPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisitRequest() when $default != null:
return $default(_that.id,_that.propertyId,_that.studentId,_that.preferredDate,_that.preferredSlot,_that.message,_that.status,_that.respondedAt,_that.createdAt,_that.propertyName,_that.propertyLocality,_that.propertyPhotoUrl,_that.studentName,_that.studentPhone);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String propertyId,  String studentId,  DateTime preferredDate,  VisitSlot preferredSlot,  String? message,  VisitRequestStatus status,  DateTime? respondedAt,  DateTime? createdAt,  String? propertyName,  String? propertyLocality,  String? propertyPhotoUrl,  String? studentName,  String? studentPhone)  $default,) {final _that = this;
switch (_that) {
case _VisitRequest():
return $default(_that.id,_that.propertyId,_that.studentId,_that.preferredDate,_that.preferredSlot,_that.message,_that.status,_that.respondedAt,_that.createdAt,_that.propertyName,_that.propertyLocality,_that.propertyPhotoUrl,_that.studentName,_that.studentPhone);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String propertyId,  String studentId,  DateTime preferredDate,  VisitSlot preferredSlot,  String? message,  VisitRequestStatus status,  DateTime? respondedAt,  DateTime? createdAt,  String? propertyName,  String? propertyLocality,  String? propertyPhotoUrl,  String? studentName,  String? studentPhone)?  $default,) {final _that = this;
switch (_that) {
case _VisitRequest() when $default != null:
return $default(_that.id,_that.propertyId,_that.studentId,_that.preferredDate,_that.preferredSlot,_that.message,_that.status,_that.respondedAt,_that.createdAt,_that.propertyName,_that.propertyLocality,_that.propertyPhotoUrl,_that.studentName,_that.studentPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisitRequest implements VisitRequest {
  const _VisitRequest({required this.id, required this.propertyId, required this.studentId, required this.preferredDate, required this.preferredSlot, this.message, required this.status, this.respondedAt, this.createdAt, this.propertyName, this.propertyLocality, this.propertyPhotoUrl, this.studentName, this.studentPhone});
  factory _VisitRequest.fromJson(Map<String, dynamic> json) => _$VisitRequestFromJson(json);

@override final  String id;
@override final  String propertyId;
@override final  String studentId;
@override final  DateTime preferredDate;
@override final  VisitSlot preferredSlot;
@override final  String? message;
@override final  VisitRequestStatus status;
@override final  DateTime? respondedAt;
@override final  DateTime? createdAt;
/// Denormalized for list rendering so the client needn't fetch each
/// property separately.
@override final  String? propertyName;
@override final  String? propertyLocality;
@override final  String? propertyPhotoUrl;
@override final  String? studentName;
@override final  String? studentPhone;

/// Create a copy of VisitRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitRequestCopyWith<_VisitRequest> get copyWith => __$VisitRequestCopyWithImpl<_VisitRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisitRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisitRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.preferredDate, preferredDate) || other.preferredDate == preferredDate)&&(identical(other.preferredSlot, preferredSlot) || other.preferredSlot == preferredSlot)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.propertyLocality, propertyLocality) || other.propertyLocality == propertyLocality)&&(identical(other.propertyPhotoUrl, propertyPhotoUrl) || other.propertyPhotoUrl == propertyPhotoUrl)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentPhone, studentPhone) || other.studentPhone == studentPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,propertyId,studentId,preferredDate,preferredSlot,message,status,respondedAt,createdAt,propertyName,propertyLocality,propertyPhotoUrl,studentName,studentPhone);

@override
String toString() {
  return 'VisitRequest(id: $id, propertyId: $propertyId, studentId: $studentId, preferredDate: $preferredDate, preferredSlot: $preferredSlot, message: $message, status: $status, respondedAt: $respondedAt, createdAt: $createdAt, propertyName: $propertyName, propertyLocality: $propertyLocality, propertyPhotoUrl: $propertyPhotoUrl, studentName: $studentName, studentPhone: $studentPhone)';
}


}

/// @nodoc
abstract mixin class _$VisitRequestCopyWith<$Res> implements $VisitRequestCopyWith<$Res> {
  factory _$VisitRequestCopyWith(_VisitRequest value, $Res Function(_VisitRequest) _then) = __$VisitRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String propertyId, String studentId, DateTime preferredDate, VisitSlot preferredSlot, String? message, VisitRequestStatus status, DateTime? respondedAt, DateTime? createdAt, String? propertyName, String? propertyLocality, String? propertyPhotoUrl, String? studentName, String? studentPhone
});




}
/// @nodoc
class __$VisitRequestCopyWithImpl<$Res>
    implements _$VisitRequestCopyWith<$Res> {
  __$VisitRequestCopyWithImpl(this._self, this._then);

  final _VisitRequest _self;
  final $Res Function(_VisitRequest) _then;

/// Create a copy of VisitRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? propertyId = null,Object? studentId = null,Object? preferredDate = null,Object? preferredSlot = null,Object? message = freezed,Object? status = null,Object? respondedAt = freezed,Object? createdAt = freezed,Object? propertyName = freezed,Object? propertyLocality = freezed,Object? propertyPhotoUrl = freezed,Object? studentName = freezed,Object? studentPhone = freezed,}) {
  return _then(_VisitRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,preferredDate: null == preferredDate ? _self.preferredDate : preferredDate // ignore: cast_nullable_to_non_nullable
as DateTime,preferredSlot: null == preferredSlot ? _self.preferredSlot : preferredSlot // ignore: cast_nullable_to_non_nullable
as VisitSlot,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VisitRequestStatus,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,propertyName: freezed == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String?,propertyLocality: freezed == propertyLocality ? _self.propertyLocality : propertyLocality // ignore: cast_nullable_to_non_nullable
as String?,propertyPhotoUrl: freezed == propertyPhotoUrl ? _self.propertyPhotoUrl : propertyPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentPhone: freezed == studentPhone ? _self.studentPhone : studentPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
