// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bed {

 String get id; String get roomId; String get label; BedStatus get status;
/// Create a copy of Bed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BedCopyWith<Bed> get copyWith => _$BedCopyWithImpl<Bed>(this as Bed, _$identity);

  /// Serializes this Bed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bed&&(identical(other.id, id) || other.id == id)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomId,label,status);

@override
String toString() {
  return 'Bed(id: $id, roomId: $roomId, label: $label, status: $status)';
}


}

/// @nodoc
abstract mixin class $BedCopyWith<$Res>  {
  factory $BedCopyWith(Bed value, $Res Function(Bed) _then) = _$BedCopyWithImpl;
@useResult
$Res call({
 String id, String roomId, String label, BedStatus status
});




}
/// @nodoc
class _$BedCopyWithImpl<$Res>
    implements $BedCopyWith<$Res> {
  _$BedCopyWithImpl(this._self, this._then);

  final Bed _self;
  final $Res Function(Bed) _then;

/// Create a copy of Bed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roomId = null,Object? label = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BedStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Bed].
extension BedPatterns on Bed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bed value)  $default,){
final _that = this;
switch (_that) {
case _Bed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bed value)?  $default,){
final _that = this;
switch (_that) {
case _Bed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String roomId,  String label,  BedStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bed() when $default != null:
return $default(_that.id,_that.roomId,_that.label,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String roomId,  String label,  BedStatus status)  $default,) {final _that = this;
switch (_that) {
case _Bed():
return $default(_that.id,_that.roomId,_that.label,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String roomId,  String label,  BedStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Bed() when $default != null:
return $default(_that.id,_that.roomId,_that.label,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bed extends Bed {
  const _Bed({required this.id, required this.roomId, required this.label, required this.status}): super._();
  factory _Bed.fromJson(Map<String, dynamic> json) => _$BedFromJson(json);

@override final  String id;
@override final  String roomId;
@override final  String label;
@override final  BedStatus status;

/// Create a copy of Bed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BedCopyWith<_Bed> get copyWith => __$BedCopyWithImpl<_Bed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bed&&(identical(other.id, id) || other.id == id)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomId,label,status);

@override
String toString() {
  return 'Bed(id: $id, roomId: $roomId, label: $label, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BedCopyWith<$Res> implements $BedCopyWith<$Res> {
  factory _$BedCopyWith(_Bed value, $Res Function(_Bed) _then) = __$BedCopyWithImpl;
@override @useResult
$Res call({
 String id, String roomId, String label, BedStatus status
});




}
/// @nodoc
class __$BedCopyWithImpl<$Res>
    implements _$BedCopyWith<$Res> {
  __$BedCopyWithImpl(this._self, this._then);

  final _Bed _self;
  final $Res Function(_Bed) _then;

/// Create a copy of Bed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? roomId = null,Object? label = null,Object? status = null,}) {
  return _then(_Bed(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BedStatus,
  ));
}


}


/// @nodoc
mixin _$Room {

 String get id; String get propertyId; String get roomNumber; int? get floor; SharingType get sharingType; int get rentPerBedPaise; int get depositPaise; bool get hasAttachedBathroom; bool get hasAc; List<Bed> get beds;
/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomCopyWith<Room> get copyWith => _$RoomCopyWithImpl<Room>(this as Room, _$identity);

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Room&&(identical(other.id, id) || other.id == id)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.sharingType, sharingType) || other.sharingType == sharingType)&&(identical(other.rentPerBedPaise, rentPerBedPaise) || other.rentPerBedPaise == rentPerBedPaise)&&(identical(other.depositPaise, depositPaise) || other.depositPaise == depositPaise)&&(identical(other.hasAttachedBathroom, hasAttachedBathroom) || other.hasAttachedBathroom == hasAttachedBathroom)&&(identical(other.hasAc, hasAc) || other.hasAc == hasAc)&&const DeepCollectionEquality().equals(other.beds, beds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,propertyId,roomNumber,floor,sharingType,rentPerBedPaise,depositPaise,hasAttachedBathroom,hasAc,const DeepCollectionEquality().hash(beds));

@override
String toString() {
  return 'Room(id: $id, propertyId: $propertyId, roomNumber: $roomNumber, floor: $floor, sharingType: $sharingType, rentPerBedPaise: $rentPerBedPaise, depositPaise: $depositPaise, hasAttachedBathroom: $hasAttachedBathroom, hasAc: $hasAc, beds: $beds)';
}


}

/// @nodoc
abstract mixin class $RoomCopyWith<$Res>  {
  factory $RoomCopyWith(Room value, $Res Function(Room) _then) = _$RoomCopyWithImpl;
@useResult
$Res call({
 String id, String propertyId, String roomNumber, int? floor, SharingType sharingType, int rentPerBedPaise, int depositPaise, bool hasAttachedBathroom, bool hasAc, List<Bed> beds
});




}
/// @nodoc
class _$RoomCopyWithImpl<$Res>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._self, this._then);

  final Room _self;
  final $Res Function(Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? propertyId = null,Object? roomNumber = null,Object? floor = freezed,Object? sharingType = null,Object? rentPerBedPaise = null,Object? depositPaise = null,Object? hasAttachedBathroom = null,Object? hasAc = null,Object? beds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,roomNumber: null == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as String,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as int?,sharingType: null == sharingType ? _self.sharingType : sharingType // ignore: cast_nullable_to_non_nullable
as SharingType,rentPerBedPaise: null == rentPerBedPaise ? _self.rentPerBedPaise : rentPerBedPaise // ignore: cast_nullable_to_non_nullable
as int,depositPaise: null == depositPaise ? _self.depositPaise : depositPaise // ignore: cast_nullable_to_non_nullable
as int,hasAttachedBathroom: null == hasAttachedBathroom ? _self.hasAttachedBathroom : hasAttachedBathroom // ignore: cast_nullable_to_non_nullable
as bool,hasAc: null == hasAc ? _self.hasAc : hasAc // ignore: cast_nullable_to_non_nullable
as bool,beds: null == beds ? _self.beds : beds // ignore: cast_nullable_to_non_nullable
as List<Bed>,
  ));
}

}


/// Adds pattern-matching-related methods to [Room].
extension RoomPatterns on Room {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Room value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Room value)  $default,){
final _that = this;
switch (_that) {
case _Room():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Room value)?  $default,){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String propertyId,  String roomNumber,  int? floor,  SharingType sharingType,  int rentPerBedPaise,  int depositPaise,  bool hasAttachedBathroom,  bool hasAc,  List<Bed> beds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.id,_that.propertyId,_that.roomNumber,_that.floor,_that.sharingType,_that.rentPerBedPaise,_that.depositPaise,_that.hasAttachedBathroom,_that.hasAc,_that.beds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String propertyId,  String roomNumber,  int? floor,  SharingType sharingType,  int rentPerBedPaise,  int depositPaise,  bool hasAttachedBathroom,  bool hasAc,  List<Bed> beds)  $default,) {final _that = this;
switch (_that) {
case _Room():
return $default(_that.id,_that.propertyId,_that.roomNumber,_that.floor,_that.sharingType,_that.rentPerBedPaise,_that.depositPaise,_that.hasAttachedBathroom,_that.hasAc,_that.beds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String propertyId,  String roomNumber,  int? floor,  SharingType sharingType,  int rentPerBedPaise,  int depositPaise,  bool hasAttachedBathroom,  bool hasAc,  List<Bed> beds)?  $default,) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.id,_that.propertyId,_that.roomNumber,_that.floor,_that.sharingType,_that.rentPerBedPaise,_that.depositPaise,_that.hasAttachedBathroom,_that.hasAc,_that.beds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Room extends Room {
  const _Room({required this.id, required this.propertyId, required this.roomNumber, this.floor, required this.sharingType, required this.rentPerBedPaise, required this.depositPaise, this.hasAttachedBathroom = false, this.hasAc = false, final  List<Bed> beds = const <Bed>[]}): _beds = beds,super._();
  factory _Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

@override final  String id;
@override final  String propertyId;
@override final  String roomNumber;
@override final  int? floor;
@override final  SharingType sharingType;
@override final  int rentPerBedPaise;
@override final  int depositPaise;
@override@JsonKey() final  bool hasAttachedBathroom;
@override@JsonKey() final  bool hasAc;
 final  List<Bed> _beds;
@override@JsonKey() List<Bed> get beds {
  if (_beds is EqualUnmodifiableListView) return _beds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beds);
}


/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomCopyWith<_Room> get copyWith => __$RoomCopyWithImpl<_Room>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Room&&(identical(other.id, id) || other.id == id)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.sharingType, sharingType) || other.sharingType == sharingType)&&(identical(other.rentPerBedPaise, rentPerBedPaise) || other.rentPerBedPaise == rentPerBedPaise)&&(identical(other.depositPaise, depositPaise) || other.depositPaise == depositPaise)&&(identical(other.hasAttachedBathroom, hasAttachedBathroom) || other.hasAttachedBathroom == hasAttachedBathroom)&&(identical(other.hasAc, hasAc) || other.hasAc == hasAc)&&const DeepCollectionEquality().equals(other._beds, _beds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,propertyId,roomNumber,floor,sharingType,rentPerBedPaise,depositPaise,hasAttachedBathroom,hasAc,const DeepCollectionEquality().hash(_beds));

@override
String toString() {
  return 'Room(id: $id, propertyId: $propertyId, roomNumber: $roomNumber, floor: $floor, sharingType: $sharingType, rentPerBedPaise: $rentPerBedPaise, depositPaise: $depositPaise, hasAttachedBathroom: $hasAttachedBathroom, hasAc: $hasAc, beds: $beds)';
}


}

/// @nodoc
abstract mixin class _$RoomCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$RoomCopyWith(_Room value, $Res Function(_Room) _then) = __$RoomCopyWithImpl;
@override @useResult
$Res call({
 String id, String propertyId, String roomNumber, int? floor, SharingType sharingType, int rentPerBedPaise, int depositPaise, bool hasAttachedBathroom, bool hasAc, List<Bed> beds
});




}
/// @nodoc
class __$RoomCopyWithImpl<$Res>
    implements _$RoomCopyWith<$Res> {
  __$RoomCopyWithImpl(this._self, this._then);

  final _Room _self;
  final $Res Function(_Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? propertyId = null,Object? roomNumber = null,Object? floor = freezed,Object? sharingType = null,Object? rentPerBedPaise = null,Object? depositPaise = null,Object? hasAttachedBathroom = null,Object? hasAc = null,Object? beds = null,}) {
  return _then(_Room(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,roomNumber: null == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as String,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as int?,sharingType: null == sharingType ? _self.sharingType : sharingType // ignore: cast_nullable_to_non_nullable
as SharingType,rentPerBedPaise: null == rentPerBedPaise ? _self.rentPerBedPaise : rentPerBedPaise // ignore: cast_nullable_to_non_nullable
as int,depositPaise: null == depositPaise ? _self.depositPaise : depositPaise // ignore: cast_nullable_to_non_nullable
as int,hasAttachedBathroom: null == hasAttachedBathroom ? _self.hasAttachedBathroom : hasAttachedBathroom // ignore: cast_nullable_to_non_nullable
as bool,hasAc: null == hasAc ? _self.hasAc : hasAc // ignore: cast_nullable_to_non_nullable
as bool,beds: null == beds ? _self._beds : beds // ignore: cast_nullable_to_non_nullable
as List<Bed>,
  ));
}


}

// dart format on
