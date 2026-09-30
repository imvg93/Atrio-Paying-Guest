// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'amenity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Amenity {

 String get key; String get label; String get group;/// A name from the client's icon set. Advisory: an unrecognised value falls
/// back to a generic icon rather than failing to render.
 String? get icon;
/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmenityCopyWith<Amenity> get copyWith => _$AmenityCopyWithImpl<Amenity>(this as Amenity, _$identity);

  /// Serializes this Amenity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Amenity&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.group, group) || other.group == group)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,group,icon);

@override
String toString() {
  return 'Amenity(key: $key, label: $label, group: $group, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $AmenityCopyWith<$Res>  {
  factory $AmenityCopyWith(Amenity value, $Res Function(Amenity) _then) = _$AmenityCopyWithImpl;
@useResult
$Res call({
 String key, String label, String group, String? icon
});




}
/// @nodoc
class _$AmenityCopyWithImpl<$Res>
    implements $AmenityCopyWith<$Res> {
  _$AmenityCopyWithImpl(this._self, this._then);

  final Amenity _self;
  final $Res Function(Amenity) _then;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? group = null,Object? icon = freezed,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Amenity].
extension AmenityPatterns on Amenity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Amenity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Amenity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Amenity value)  $default,){
final _that = this;
switch (_that) {
case _Amenity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Amenity value)?  $default,){
final _that = this;
switch (_that) {
case _Amenity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  String group,  String? icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Amenity() when $default != null:
return $default(_that.key,_that.label,_that.group,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  String group,  String? icon)  $default,) {final _that = this;
switch (_that) {
case _Amenity():
return $default(_that.key,_that.label,_that.group,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  String group,  String? icon)?  $default,) {final _that = this;
switch (_that) {
case _Amenity() when $default != null:
return $default(_that.key,_that.label,_that.group,_that.icon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Amenity implements Amenity {
  const _Amenity({required this.key, required this.label, this.group = 'other', this.icon});
  factory _Amenity.fromJson(Map<String, dynamic> json) => _$AmenityFromJson(json);

@override final  String key;
@override final  String label;
@override@JsonKey() final  String group;
/// A name from the client's icon set. Advisory: an unrecognised value falls
/// back to a generic icon rather than failing to render.
@override final  String? icon;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmenityCopyWith<_Amenity> get copyWith => __$AmenityCopyWithImpl<_Amenity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AmenityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Amenity&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.group, group) || other.group == group)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,group,icon);

@override
String toString() {
  return 'Amenity(key: $key, label: $label, group: $group, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$AmenityCopyWith<$Res> implements $AmenityCopyWith<$Res> {
  factory _$AmenityCopyWith(_Amenity value, $Res Function(_Amenity) _then) = __$AmenityCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, String group, String? icon
});




}
/// @nodoc
class __$AmenityCopyWithImpl<$Res>
    implements _$AmenityCopyWith<$Res> {
  __$AmenityCopyWithImpl(this._self, this._then);

  final _Amenity _self;
  final $Res Function(_Amenity) _then;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? group = null,Object? icon = freezed,}) {
  return _then(_Amenity(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
