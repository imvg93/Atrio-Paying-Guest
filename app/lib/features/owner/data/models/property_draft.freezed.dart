// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'property_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PropertyDraft {

 String get name; String get description; PropertyGenderType? get genderType; String get addressLine; String get locality; String get city; String get state; String get pincode; double? get latitude; double? get longitude; Map<String, bool> get amenities; Map<String, dynamic> get rules; bool get foodIncluded; int get noticePeriodDays;
/// Create a copy of PropertyDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyDraftCopyWith<PropertyDraft> get copyWith => _$PropertyDraftCopyWithImpl<PropertyDraft>(this as PropertyDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropertyDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.genderType, genderType) || other.genderType == genderType)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.pincode, pincode) || other.pincode == pincode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&const DeepCollectionEquality().equals(other.rules, rules)&&(identical(other.foodIncluded, foodIncluded) || other.foodIncluded == foodIncluded)&&(identical(other.noticePeriodDays, noticePeriodDays) || other.noticePeriodDays == noticePeriodDays));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,genderType,addressLine,locality,city,state,pincode,latitude,longitude,const DeepCollectionEquality().hash(amenities),const DeepCollectionEquality().hash(rules),foodIncluded,noticePeriodDays);

@override
String toString() {
  return 'PropertyDraft(name: $name, description: $description, genderType: $genderType, addressLine: $addressLine, locality: $locality, city: $city, state: $state, pincode: $pincode, latitude: $latitude, longitude: $longitude, amenities: $amenities, rules: $rules, foodIncluded: $foodIncluded, noticePeriodDays: $noticePeriodDays)';
}


}

/// @nodoc
abstract mixin class $PropertyDraftCopyWith<$Res>  {
  factory $PropertyDraftCopyWith(PropertyDraft value, $Res Function(PropertyDraft) _then) = _$PropertyDraftCopyWithImpl;
@useResult
$Res call({
 String name, String description, PropertyGenderType? genderType, String addressLine, String locality, String city, String state, String pincode, double? latitude, double? longitude, Map<String, bool> amenities, Map<String, dynamic> rules, bool foodIncluded, int noticePeriodDays
});




}
/// @nodoc
class _$PropertyDraftCopyWithImpl<$Res>
    implements $PropertyDraftCopyWith<$Res> {
  _$PropertyDraftCopyWithImpl(this._self, this._then);

  final PropertyDraft _self;
  final $Res Function(PropertyDraft) _then;

/// Create a copy of PropertyDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? genderType = freezed,Object? addressLine = null,Object? locality = null,Object? city = null,Object? state = null,Object? pincode = null,Object? latitude = freezed,Object? longitude = freezed,Object? amenities = null,Object? rules = null,Object? foodIncluded = null,Object? noticePeriodDays = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,genderType: freezed == genderType ? _self.genderType : genderType // ignore: cast_nullable_to_non_nullable
as PropertyGenderType?,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,foodIncluded: null == foodIncluded ? _self.foodIncluded : foodIncluded // ignore: cast_nullable_to_non_nullable
as bool,noticePeriodDays: null == noticePeriodDays ? _self.noticePeriodDays : noticePeriodDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PropertyDraft].
extension PropertyDraftPatterns on PropertyDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PropertyDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PropertyDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PropertyDraft value)  $default,){
final _that = this;
switch (_that) {
case _PropertyDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PropertyDraft value)?  $default,){
final _that = this;
switch (_that) {
case _PropertyDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  PropertyGenderType? genderType,  String addressLine,  String locality,  String city,  String state,  String pincode,  double? latitude,  double? longitude,  Map<String, bool> amenities,  Map<String, dynamic> rules,  bool foodIncluded,  int noticePeriodDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PropertyDraft() when $default != null:
return $default(_that.name,_that.description,_that.genderType,_that.addressLine,_that.locality,_that.city,_that.state,_that.pincode,_that.latitude,_that.longitude,_that.amenities,_that.rules,_that.foodIncluded,_that.noticePeriodDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  PropertyGenderType? genderType,  String addressLine,  String locality,  String city,  String state,  String pincode,  double? latitude,  double? longitude,  Map<String, bool> amenities,  Map<String, dynamic> rules,  bool foodIncluded,  int noticePeriodDays)  $default,) {final _that = this;
switch (_that) {
case _PropertyDraft():
return $default(_that.name,_that.description,_that.genderType,_that.addressLine,_that.locality,_that.city,_that.state,_that.pincode,_that.latitude,_that.longitude,_that.amenities,_that.rules,_that.foodIncluded,_that.noticePeriodDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  PropertyGenderType? genderType,  String addressLine,  String locality,  String city,  String state,  String pincode,  double? latitude,  double? longitude,  Map<String, bool> amenities,  Map<String, dynamic> rules,  bool foodIncluded,  int noticePeriodDays)?  $default,) {final _that = this;
switch (_that) {
case _PropertyDraft() when $default != null:
return $default(_that.name,_that.description,_that.genderType,_that.addressLine,_that.locality,_that.city,_that.state,_that.pincode,_that.latitude,_that.longitude,_that.amenities,_that.rules,_that.foodIncluded,_that.noticePeriodDays);case _:
  return null;

}
}

}

/// @nodoc


class _PropertyDraft extends PropertyDraft {
  const _PropertyDraft({this.name = '', this.description = '', this.genderType, this.addressLine = '', this.locality = '', this.city = '', this.state = '', this.pincode = '', this.latitude, this.longitude, final  Map<String, bool> amenities = const <String, bool>{}, final  Map<String, dynamic> rules = const <String, dynamic>{}, this.foodIncluded = false, this.noticePeriodDays = 30}): _amenities = amenities,_rules = rules,super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override final  PropertyGenderType? genderType;
@override@JsonKey() final  String addressLine;
@override@JsonKey() final  String locality;
@override@JsonKey() final  String city;
@override@JsonKey() final  String state;
@override@JsonKey() final  String pincode;
@override final  double? latitude;
@override final  double? longitude;
 final  Map<String, bool> _amenities;
@override@JsonKey() Map<String, bool> get amenities {
  if (_amenities is EqualUnmodifiableMapView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_amenities);
}

 final  Map<String, dynamic> _rules;
@override@JsonKey() Map<String, dynamic> get rules {
  if (_rules is EqualUnmodifiableMapView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rules);
}

@override@JsonKey() final  bool foodIncluded;
@override@JsonKey() final  int noticePeriodDays;

/// Create a copy of PropertyDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertyDraftCopyWith<_PropertyDraft> get copyWith => __$PropertyDraftCopyWithImpl<_PropertyDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PropertyDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.genderType, genderType) || other.genderType == genderType)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.pincode, pincode) || other.pincode == pincode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&const DeepCollectionEquality().equals(other._rules, _rules)&&(identical(other.foodIncluded, foodIncluded) || other.foodIncluded == foodIncluded)&&(identical(other.noticePeriodDays, noticePeriodDays) || other.noticePeriodDays == noticePeriodDays));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,genderType,addressLine,locality,city,state,pincode,latitude,longitude,const DeepCollectionEquality().hash(_amenities),const DeepCollectionEquality().hash(_rules),foodIncluded,noticePeriodDays);

@override
String toString() {
  return 'PropertyDraft(name: $name, description: $description, genderType: $genderType, addressLine: $addressLine, locality: $locality, city: $city, state: $state, pincode: $pincode, latitude: $latitude, longitude: $longitude, amenities: $amenities, rules: $rules, foodIncluded: $foodIncluded, noticePeriodDays: $noticePeriodDays)';
}


}

/// @nodoc
abstract mixin class _$PropertyDraftCopyWith<$Res> implements $PropertyDraftCopyWith<$Res> {
  factory _$PropertyDraftCopyWith(_PropertyDraft value, $Res Function(_PropertyDraft) _then) = __$PropertyDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, PropertyGenderType? genderType, String addressLine, String locality, String city, String state, String pincode, double? latitude, double? longitude, Map<String, bool> amenities, Map<String, dynamic> rules, bool foodIncluded, int noticePeriodDays
});




}
/// @nodoc
class __$PropertyDraftCopyWithImpl<$Res>
    implements _$PropertyDraftCopyWith<$Res> {
  __$PropertyDraftCopyWithImpl(this._self, this._then);

  final _PropertyDraft _self;
  final $Res Function(_PropertyDraft) _then;

/// Create a copy of PropertyDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? genderType = freezed,Object? addressLine = null,Object? locality = null,Object? city = null,Object? state = null,Object? pincode = null,Object? latitude = freezed,Object? longitude = freezed,Object? amenities = null,Object? rules = null,Object? foodIncluded = null,Object? noticePeriodDays = null,}) {
  return _then(_PropertyDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,genderType: freezed == genderType ? _self.genderType : genderType // ignore: cast_nullable_to_non_nullable
as PropertyGenderType?,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,foodIncluded: null == foodIncluded ? _self.foodIncluded : foodIncluded // ignore: cast_nullable_to_non_nullable
as bool,noticePeriodDays: null == noticePeriodDays ? _self.noticePeriodDays : noticePeriodDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
