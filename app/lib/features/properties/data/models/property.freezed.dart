// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'property.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PropertyPhoto {

 String get id; String get url; int get sortOrder; String? get caption;
/// Create a copy of PropertyPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyPhotoCopyWith<PropertyPhoto> get copyWith => _$PropertyPhotoCopyWithImpl<PropertyPhoto>(this as PropertyPhoto, _$identity);

  /// Serializes this PropertyPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropertyPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.caption, caption) || other.caption == caption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,sortOrder,caption);

@override
String toString() {
  return 'PropertyPhoto(id: $id, url: $url, sortOrder: $sortOrder, caption: $caption)';
}


}

/// @nodoc
abstract mixin class $PropertyPhotoCopyWith<$Res>  {
  factory $PropertyPhotoCopyWith(PropertyPhoto value, $Res Function(PropertyPhoto) _then) = _$PropertyPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String url, int sortOrder, String? caption
});




}
/// @nodoc
class _$PropertyPhotoCopyWithImpl<$Res>
    implements $PropertyPhotoCopyWith<$Res> {
  _$PropertyPhotoCopyWithImpl(this._self, this._then);

  final PropertyPhoto _self;
  final $Res Function(PropertyPhoto) _then;

/// Create a copy of PropertyPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? sortOrder = null,Object? caption = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PropertyPhoto].
extension PropertyPhotoPatterns on PropertyPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PropertyPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PropertyPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PropertyPhoto value)  $default,){
final _that = this;
switch (_that) {
case _PropertyPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PropertyPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _PropertyPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  int sortOrder,  String? caption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PropertyPhoto() when $default != null:
return $default(_that.id,_that.url,_that.sortOrder,_that.caption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  int sortOrder,  String? caption)  $default,) {final _that = this;
switch (_that) {
case _PropertyPhoto():
return $default(_that.id,_that.url,_that.sortOrder,_that.caption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  int sortOrder,  String? caption)?  $default,) {final _that = this;
switch (_that) {
case _PropertyPhoto() when $default != null:
return $default(_that.id,_that.url,_that.sortOrder,_that.caption);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PropertyPhoto implements PropertyPhoto {
  const _PropertyPhoto({required this.id, required this.url, this.sortOrder = 0, this.caption});
  factory _PropertyPhoto.fromJson(Map<String, dynamic> json) => _$PropertyPhotoFromJson(json);

@override final  String id;
@override final  String url;
@override@JsonKey() final  int sortOrder;
@override final  String? caption;

/// Create a copy of PropertyPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertyPhotoCopyWith<_PropertyPhoto> get copyWith => __$PropertyPhotoCopyWithImpl<_PropertyPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropertyPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PropertyPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.caption, caption) || other.caption == caption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,sortOrder,caption);

@override
String toString() {
  return 'PropertyPhoto(id: $id, url: $url, sortOrder: $sortOrder, caption: $caption)';
}


}

/// @nodoc
abstract mixin class _$PropertyPhotoCopyWith<$Res> implements $PropertyPhotoCopyWith<$Res> {
  factory _$PropertyPhotoCopyWith(_PropertyPhoto value, $Res Function(_PropertyPhoto) _then) = __$PropertyPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, int sortOrder, String? caption
});




}
/// @nodoc
class __$PropertyPhotoCopyWithImpl<$Res>
    implements _$PropertyPhotoCopyWith<$Res> {
  __$PropertyPhotoCopyWithImpl(this._self, this._then);

  final _PropertyPhoto _self;
  final $Res Function(_PropertyPhoto) _then;

/// Create a copy of PropertyPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? sortOrder = null,Object? caption = freezed,}) {
  return _then(_PropertyPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OccupancySummary {

 int get totalBeds; int get occupiedBeds; int get availableBeds; int get maintenanceBeds;
/// Create a copy of OccupancySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OccupancySummaryCopyWith<OccupancySummary> get copyWith => _$OccupancySummaryCopyWithImpl<OccupancySummary>(this as OccupancySummary, _$identity);

  /// Serializes this OccupancySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OccupancySummary&&(identical(other.totalBeds, totalBeds) || other.totalBeds == totalBeds)&&(identical(other.occupiedBeds, occupiedBeds) || other.occupiedBeds == occupiedBeds)&&(identical(other.availableBeds, availableBeds) || other.availableBeds == availableBeds)&&(identical(other.maintenanceBeds, maintenanceBeds) || other.maintenanceBeds == maintenanceBeds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalBeds,occupiedBeds,availableBeds,maintenanceBeds);

@override
String toString() {
  return 'OccupancySummary(totalBeds: $totalBeds, occupiedBeds: $occupiedBeds, availableBeds: $availableBeds, maintenanceBeds: $maintenanceBeds)';
}


}

/// @nodoc
abstract mixin class $OccupancySummaryCopyWith<$Res>  {
  factory $OccupancySummaryCopyWith(OccupancySummary value, $Res Function(OccupancySummary) _then) = _$OccupancySummaryCopyWithImpl;
@useResult
$Res call({
 int totalBeds, int occupiedBeds, int availableBeds, int maintenanceBeds
});




}
/// @nodoc
class _$OccupancySummaryCopyWithImpl<$Res>
    implements $OccupancySummaryCopyWith<$Res> {
  _$OccupancySummaryCopyWithImpl(this._self, this._then);

  final OccupancySummary _self;
  final $Res Function(OccupancySummary) _then;

/// Create a copy of OccupancySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalBeds = null,Object? occupiedBeds = null,Object? availableBeds = null,Object? maintenanceBeds = null,}) {
  return _then(_self.copyWith(
totalBeds: null == totalBeds ? _self.totalBeds : totalBeds // ignore: cast_nullable_to_non_nullable
as int,occupiedBeds: null == occupiedBeds ? _self.occupiedBeds : occupiedBeds // ignore: cast_nullable_to_non_nullable
as int,availableBeds: null == availableBeds ? _self.availableBeds : availableBeds // ignore: cast_nullable_to_non_nullable
as int,maintenanceBeds: null == maintenanceBeds ? _self.maintenanceBeds : maintenanceBeds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OccupancySummary].
extension OccupancySummaryPatterns on OccupancySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OccupancySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OccupancySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OccupancySummary value)  $default,){
final _that = this;
switch (_that) {
case _OccupancySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OccupancySummary value)?  $default,){
final _that = this;
switch (_that) {
case _OccupancySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalBeds,  int occupiedBeds,  int availableBeds,  int maintenanceBeds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OccupancySummary() when $default != null:
return $default(_that.totalBeds,_that.occupiedBeds,_that.availableBeds,_that.maintenanceBeds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalBeds,  int occupiedBeds,  int availableBeds,  int maintenanceBeds)  $default,) {final _that = this;
switch (_that) {
case _OccupancySummary():
return $default(_that.totalBeds,_that.occupiedBeds,_that.availableBeds,_that.maintenanceBeds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalBeds,  int occupiedBeds,  int availableBeds,  int maintenanceBeds)?  $default,) {final _that = this;
switch (_that) {
case _OccupancySummary() when $default != null:
return $default(_that.totalBeds,_that.occupiedBeds,_that.availableBeds,_that.maintenanceBeds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OccupancySummary extends OccupancySummary {
  const _OccupancySummary({this.totalBeds = 0, this.occupiedBeds = 0, this.availableBeds = 0, this.maintenanceBeds = 0}): super._();
  factory _OccupancySummary.fromJson(Map<String, dynamic> json) => _$OccupancySummaryFromJson(json);

@override@JsonKey() final  int totalBeds;
@override@JsonKey() final  int occupiedBeds;
@override@JsonKey() final  int availableBeds;
@override@JsonKey() final  int maintenanceBeds;

/// Create a copy of OccupancySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OccupancySummaryCopyWith<_OccupancySummary> get copyWith => __$OccupancySummaryCopyWithImpl<_OccupancySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OccupancySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OccupancySummary&&(identical(other.totalBeds, totalBeds) || other.totalBeds == totalBeds)&&(identical(other.occupiedBeds, occupiedBeds) || other.occupiedBeds == occupiedBeds)&&(identical(other.availableBeds, availableBeds) || other.availableBeds == availableBeds)&&(identical(other.maintenanceBeds, maintenanceBeds) || other.maintenanceBeds == maintenanceBeds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalBeds,occupiedBeds,availableBeds,maintenanceBeds);

@override
String toString() {
  return 'OccupancySummary(totalBeds: $totalBeds, occupiedBeds: $occupiedBeds, availableBeds: $availableBeds, maintenanceBeds: $maintenanceBeds)';
}


}

/// @nodoc
abstract mixin class _$OccupancySummaryCopyWith<$Res> implements $OccupancySummaryCopyWith<$Res> {
  factory _$OccupancySummaryCopyWith(_OccupancySummary value, $Res Function(_OccupancySummary) _then) = __$OccupancySummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalBeds, int occupiedBeds, int availableBeds, int maintenanceBeds
});




}
/// @nodoc
class __$OccupancySummaryCopyWithImpl<$Res>
    implements _$OccupancySummaryCopyWith<$Res> {
  __$OccupancySummaryCopyWithImpl(this._self, this._then);

  final _OccupancySummary _self;
  final $Res Function(_OccupancySummary) _then;

/// Create a copy of OccupancySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalBeds = null,Object? occupiedBeds = null,Object? availableBeds = null,Object? maintenanceBeds = null,}) {
  return _then(_OccupancySummary(
totalBeds: null == totalBeds ? _self.totalBeds : totalBeds // ignore: cast_nullable_to_non_nullable
as int,occupiedBeds: null == occupiedBeds ? _self.occupiedBeds : occupiedBeds // ignore: cast_nullable_to_non_nullable
as int,availableBeds: null == availableBeds ? _self.availableBeds : availableBeds // ignore: cast_nullable_to_non_nullable
as int,maintenanceBeds: null == maintenanceBeds ? _self.maintenanceBeds : maintenanceBeds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PropertySummary {

 String get id; String get name; String get locality; String get city; PropertyGenderType get genderType; PropertyStatus get status; bool get foodIncluded; String? get coverPhotoUrl; int get photoCount; OccupancySummary get occupancy; int? get minRentPaise; int? get maxRentPaise;/// Present on search results when the query supplied lat/lng.
 double? get distanceKm; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertySummaryCopyWith<PropertySummary> get copyWith => _$PropertySummaryCopyWithImpl<PropertySummary>(this as PropertySummary, _$identity);

  /// Serializes this PropertySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropertySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.city, city) || other.city == city)&&(identical(other.genderType, genderType) || other.genderType == genderType)&&(identical(other.status, status) || other.status == status)&&(identical(other.foodIncluded, foodIncluded) || other.foodIncluded == foodIncluded)&&(identical(other.coverPhotoUrl, coverPhotoUrl) || other.coverPhotoUrl == coverPhotoUrl)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.occupancy, occupancy) || other.occupancy == occupancy)&&(identical(other.minRentPaise, minRentPaise) || other.minRentPaise == minRentPaise)&&(identical(other.maxRentPaise, maxRentPaise) || other.maxRentPaise == maxRentPaise)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,locality,city,genderType,status,foodIncluded,coverPhotoUrl,photoCount,occupancy,minRentPaise,maxRentPaise,distanceKm,createdAt,updatedAt);

@override
String toString() {
  return 'PropertySummary(id: $id, name: $name, locality: $locality, city: $city, genderType: $genderType, status: $status, foodIncluded: $foodIncluded, coverPhotoUrl: $coverPhotoUrl, photoCount: $photoCount, occupancy: $occupancy, minRentPaise: $minRentPaise, maxRentPaise: $maxRentPaise, distanceKm: $distanceKm, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PropertySummaryCopyWith<$Res>  {
  factory $PropertySummaryCopyWith(PropertySummary value, $Res Function(PropertySummary) _then) = _$PropertySummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String locality, String city, PropertyGenderType genderType, PropertyStatus status, bool foodIncluded, String? coverPhotoUrl, int photoCount, OccupancySummary occupancy, int? minRentPaise, int? maxRentPaise, double? distanceKm, DateTime? createdAt, DateTime? updatedAt
});


$OccupancySummaryCopyWith<$Res> get occupancy;

}
/// @nodoc
class _$PropertySummaryCopyWithImpl<$Res>
    implements $PropertySummaryCopyWith<$Res> {
  _$PropertySummaryCopyWithImpl(this._self, this._then);

  final PropertySummary _self;
  final $Res Function(PropertySummary) _then;

/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? locality = null,Object? city = null,Object? genderType = null,Object? status = null,Object? foodIncluded = null,Object? coverPhotoUrl = freezed,Object? photoCount = null,Object? occupancy = null,Object? minRentPaise = freezed,Object? maxRentPaise = freezed,Object? distanceKm = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,genderType: null == genderType ? _self.genderType : genderType // ignore: cast_nullable_to_non_nullable
as PropertyGenderType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PropertyStatus,foodIncluded: null == foodIncluded ? _self.foodIncluded : foodIncluded // ignore: cast_nullable_to_non_nullable
as bool,coverPhotoUrl: freezed == coverPhotoUrl ? _self.coverPhotoUrl : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,occupancy: null == occupancy ? _self.occupancy : occupancy // ignore: cast_nullable_to_non_nullable
as OccupancySummary,minRentPaise: freezed == minRentPaise ? _self.minRentPaise : minRentPaise // ignore: cast_nullable_to_non_nullable
as int?,maxRentPaise: freezed == maxRentPaise ? _self.maxRentPaise : maxRentPaise // ignore: cast_nullable_to_non_nullable
as int?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OccupancySummaryCopyWith<$Res> get occupancy {
  
  return $OccupancySummaryCopyWith<$Res>(_self.occupancy, (value) {
    return _then(_self.copyWith(occupancy: value));
  });
}
}


/// Adds pattern-matching-related methods to [PropertySummary].
extension PropertySummaryPatterns on PropertySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PropertySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PropertySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PropertySummary value)  $default,){
final _that = this;
switch (_that) {
case _PropertySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PropertySummary value)?  $default,){
final _that = this;
switch (_that) {
case _PropertySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String locality,  String city,  PropertyGenderType genderType,  PropertyStatus status,  bool foodIncluded,  String? coverPhotoUrl,  int photoCount,  OccupancySummary occupancy,  int? minRentPaise,  int? maxRentPaise,  double? distanceKm,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PropertySummary() when $default != null:
return $default(_that.id,_that.name,_that.locality,_that.city,_that.genderType,_that.status,_that.foodIncluded,_that.coverPhotoUrl,_that.photoCount,_that.occupancy,_that.minRentPaise,_that.maxRentPaise,_that.distanceKm,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String locality,  String city,  PropertyGenderType genderType,  PropertyStatus status,  bool foodIncluded,  String? coverPhotoUrl,  int photoCount,  OccupancySummary occupancy,  int? minRentPaise,  int? maxRentPaise,  double? distanceKm,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PropertySummary():
return $default(_that.id,_that.name,_that.locality,_that.city,_that.genderType,_that.status,_that.foodIncluded,_that.coverPhotoUrl,_that.photoCount,_that.occupancy,_that.minRentPaise,_that.maxRentPaise,_that.distanceKm,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String locality,  String city,  PropertyGenderType genderType,  PropertyStatus status,  bool foodIncluded,  String? coverPhotoUrl,  int photoCount,  OccupancySummary occupancy,  int? minRentPaise,  int? maxRentPaise,  double? distanceKm,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PropertySummary() when $default != null:
return $default(_that.id,_that.name,_that.locality,_that.city,_that.genderType,_that.status,_that.foodIncluded,_that.coverPhotoUrl,_that.photoCount,_that.occupancy,_that.minRentPaise,_that.maxRentPaise,_that.distanceKm,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PropertySummary extends PropertySummary {
  const _PropertySummary({required this.id, required this.name, required this.locality, required this.city, required this.genderType, required this.status, this.foodIncluded = false, this.coverPhotoUrl, this.photoCount = 0, this.occupancy = const OccupancySummary(), this.minRentPaise, this.maxRentPaise, this.distanceKm, this.createdAt, this.updatedAt}): super._();
  factory _PropertySummary.fromJson(Map<String, dynamic> json) => _$PropertySummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String locality;
@override final  String city;
@override final  PropertyGenderType genderType;
@override final  PropertyStatus status;
@override@JsonKey() final  bool foodIncluded;
@override final  String? coverPhotoUrl;
@override@JsonKey() final  int photoCount;
@override@JsonKey() final  OccupancySummary occupancy;
@override final  int? minRentPaise;
@override final  int? maxRentPaise;
/// Present on search results when the query supplied lat/lng.
@override final  double? distanceKm;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertySummaryCopyWith<_PropertySummary> get copyWith => __$PropertySummaryCopyWithImpl<_PropertySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropertySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PropertySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.city, city) || other.city == city)&&(identical(other.genderType, genderType) || other.genderType == genderType)&&(identical(other.status, status) || other.status == status)&&(identical(other.foodIncluded, foodIncluded) || other.foodIncluded == foodIncluded)&&(identical(other.coverPhotoUrl, coverPhotoUrl) || other.coverPhotoUrl == coverPhotoUrl)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.occupancy, occupancy) || other.occupancy == occupancy)&&(identical(other.minRentPaise, minRentPaise) || other.minRentPaise == minRentPaise)&&(identical(other.maxRentPaise, maxRentPaise) || other.maxRentPaise == maxRentPaise)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,locality,city,genderType,status,foodIncluded,coverPhotoUrl,photoCount,occupancy,minRentPaise,maxRentPaise,distanceKm,createdAt,updatedAt);

@override
String toString() {
  return 'PropertySummary(id: $id, name: $name, locality: $locality, city: $city, genderType: $genderType, status: $status, foodIncluded: $foodIncluded, coverPhotoUrl: $coverPhotoUrl, photoCount: $photoCount, occupancy: $occupancy, minRentPaise: $minRentPaise, maxRentPaise: $maxRentPaise, distanceKm: $distanceKm, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PropertySummaryCopyWith<$Res> implements $PropertySummaryCopyWith<$Res> {
  factory _$PropertySummaryCopyWith(_PropertySummary value, $Res Function(_PropertySummary) _then) = __$PropertySummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String locality, String city, PropertyGenderType genderType, PropertyStatus status, bool foodIncluded, String? coverPhotoUrl, int photoCount, OccupancySummary occupancy, int? minRentPaise, int? maxRentPaise, double? distanceKm, DateTime? createdAt, DateTime? updatedAt
});


@override $OccupancySummaryCopyWith<$Res> get occupancy;

}
/// @nodoc
class __$PropertySummaryCopyWithImpl<$Res>
    implements _$PropertySummaryCopyWith<$Res> {
  __$PropertySummaryCopyWithImpl(this._self, this._then);

  final _PropertySummary _self;
  final $Res Function(_PropertySummary) _then;

/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? locality = null,Object? city = null,Object? genderType = null,Object? status = null,Object? foodIncluded = null,Object? coverPhotoUrl = freezed,Object? photoCount = null,Object? occupancy = null,Object? minRentPaise = freezed,Object? maxRentPaise = freezed,Object? distanceKm = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PropertySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,genderType: null == genderType ? _self.genderType : genderType // ignore: cast_nullable_to_non_nullable
as PropertyGenderType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PropertyStatus,foodIncluded: null == foodIncluded ? _self.foodIncluded : foodIncluded // ignore: cast_nullable_to_non_nullable
as bool,coverPhotoUrl: freezed == coverPhotoUrl ? _self.coverPhotoUrl : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,occupancy: null == occupancy ? _self.occupancy : occupancy // ignore: cast_nullable_to_non_nullable
as OccupancySummary,minRentPaise: freezed == minRentPaise ? _self.minRentPaise : minRentPaise // ignore: cast_nullable_to_non_nullable
as int?,maxRentPaise: freezed == maxRentPaise ? _self.maxRentPaise : maxRentPaise // ignore: cast_nullable_to_non_nullable
as int?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OccupancySummaryCopyWith<$Res> get occupancy {
  
  return $OccupancySummaryCopyWith<$Res>(_self.occupancy, (value) {
    return _then(_self.copyWith(occupancy: value));
  });
}
}


/// @nodoc
mixin _$Property {

 String get id; String get name; String? get description; PropertyGenderType get genderType; String get addressLine; String get locality; String get city; String get state; String get pincode; double get latitude; double get longitude; Map<String, bool> get amenities; Map<String, dynamic>? get rules; bool get foodIncluded; int get noticePeriodDays; PropertyStatus get status; List<PropertyPhoto> get photos; OccupancySummary get occupancy; int? get minRentPaise; int? get maxRentPaise; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyCopyWith<Property> get copyWith => _$PropertyCopyWithImpl<Property>(this as Property, _$identity);

  /// Serializes this Property to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Property&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.genderType, genderType) || other.genderType == genderType)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.pincode, pincode) || other.pincode == pincode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&const DeepCollectionEquality().equals(other.rules, rules)&&(identical(other.foodIncluded, foodIncluded) || other.foodIncluded == foodIncluded)&&(identical(other.noticePeriodDays, noticePeriodDays) || other.noticePeriodDays == noticePeriodDays)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.occupancy, occupancy) || other.occupancy == occupancy)&&(identical(other.minRentPaise, minRentPaise) || other.minRentPaise == minRentPaise)&&(identical(other.maxRentPaise, maxRentPaise) || other.maxRentPaise == maxRentPaise)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,genderType,addressLine,locality,city,state,pincode,latitude,longitude,const DeepCollectionEquality().hash(amenities),const DeepCollectionEquality().hash(rules),foodIncluded,noticePeriodDays,status,const DeepCollectionEquality().hash(photos),occupancy,minRentPaise,maxRentPaise,createdAt,updatedAt]);

@override
String toString() {
  return 'Property(id: $id, name: $name, description: $description, genderType: $genderType, addressLine: $addressLine, locality: $locality, city: $city, state: $state, pincode: $pincode, latitude: $latitude, longitude: $longitude, amenities: $amenities, rules: $rules, foodIncluded: $foodIncluded, noticePeriodDays: $noticePeriodDays, status: $status, photos: $photos, occupancy: $occupancy, minRentPaise: $minRentPaise, maxRentPaise: $maxRentPaise, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PropertyCopyWith<$Res>  {
  factory $PropertyCopyWith(Property value, $Res Function(Property) _then) = _$PropertyCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, PropertyGenderType genderType, String addressLine, String locality, String city, String state, String pincode, double latitude, double longitude, Map<String, bool> amenities, Map<String, dynamic>? rules, bool foodIncluded, int noticePeriodDays, PropertyStatus status, List<PropertyPhoto> photos, OccupancySummary occupancy, int? minRentPaise, int? maxRentPaise, DateTime? createdAt, DateTime? updatedAt
});


$OccupancySummaryCopyWith<$Res> get occupancy;

}
/// @nodoc
class _$PropertyCopyWithImpl<$Res>
    implements $PropertyCopyWith<$Res> {
  _$PropertyCopyWithImpl(this._self, this._then);

  final Property _self;
  final $Res Function(Property) _then;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? genderType = null,Object? addressLine = null,Object? locality = null,Object? city = null,Object? state = null,Object? pincode = null,Object? latitude = null,Object? longitude = null,Object? amenities = null,Object? rules = freezed,Object? foodIncluded = null,Object? noticePeriodDays = null,Object? status = null,Object? photos = null,Object? occupancy = null,Object? minRentPaise = freezed,Object? maxRentPaise = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,genderType: null == genderType ? _self.genderType : genderType // ignore: cast_nullable_to_non_nullable
as PropertyGenderType,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,rules: freezed == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,foodIncluded: null == foodIncluded ? _self.foodIncluded : foodIncluded // ignore: cast_nullable_to_non_nullable
as bool,noticePeriodDays: null == noticePeriodDays ? _self.noticePeriodDays : noticePeriodDays // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PropertyStatus,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<PropertyPhoto>,occupancy: null == occupancy ? _self.occupancy : occupancy // ignore: cast_nullable_to_non_nullable
as OccupancySummary,minRentPaise: freezed == minRentPaise ? _self.minRentPaise : minRentPaise // ignore: cast_nullable_to_non_nullable
as int?,maxRentPaise: freezed == maxRentPaise ? _self.maxRentPaise : maxRentPaise // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OccupancySummaryCopyWith<$Res> get occupancy {
  
  return $OccupancySummaryCopyWith<$Res>(_self.occupancy, (value) {
    return _then(_self.copyWith(occupancy: value));
  });
}
}


/// Adds pattern-matching-related methods to [Property].
extension PropertyPatterns on Property {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Property value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Property() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Property value)  $default,){
final _that = this;
switch (_that) {
case _Property():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Property value)?  $default,){
final _that = this;
switch (_that) {
case _Property() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  PropertyGenderType genderType,  String addressLine,  String locality,  String city,  String state,  String pincode,  double latitude,  double longitude,  Map<String, bool> amenities,  Map<String, dynamic>? rules,  bool foodIncluded,  int noticePeriodDays,  PropertyStatus status,  List<PropertyPhoto> photos,  OccupancySummary occupancy,  int? minRentPaise,  int? maxRentPaise,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Property() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.genderType,_that.addressLine,_that.locality,_that.city,_that.state,_that.pincode,_that.latitude,_that.longitude,_that.amenities,_that.rules,_that.foodIncluded,_that.noticePeriodDays,_that.status,_that.photos,_that.occupancy,_that.minRentPaise,_that.maxRentPaise,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  PropertyGenderType genderType,  String addressLine,  String locality,  String city,  String state,  String pincode,  double latitude,  double longitude,  Map<String, bool> amenities,  Map<String, dynamic>? rules,  bool foodIncluded,  int noticePeriodDays,  PropertyStatus status,  List<PropertyPhoto> photos,  OccupancySummary occupancy,  int? minRentPaise,  int? maxRentPaise,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Property():
return $default(_that.id,_that.name,_that.description,_that.genderType,_that.addressLine,_that.locality,_that.city,_that.state,_that.pincode,_that.latitude,_that.longitude,_that.amenities,_that.rules,_that.foodIncluded,_that.noticePeriodDays,_that.status,_that.photos,_that.occupancy,_that.minRentPaise,_that.maxRentPaise,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  PropertyGenderType genderType,  String addressLine,  String locality,  String city,  String state,  String pincode,  double latitude,  double longitude,  Map<String, bool> amenities,  Map<String, dynamic>? rules,  bool foodIncluded,  int noticePeriodDays,  PropertyStatus status,  List<PropertyPhoto> photos,  OccupancySummary occupancy,  int? minRentPaise,  int? maxRentPaise,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Property() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.genderType,_that.addressLine,_that.locality,_that.city,_that.state,_that.pincode,_that.latitude,_that.longitude,_that.amenities,_that.rules,_that.foodIncluded,_that.noticePeriodDays,_that.status,_that.photos,_that.occupancy,_that.minRentPaise,_that.maxRentPaise,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Property extends Property {
  const _Property({required this.id, required this.name, this.description, required this.genderType, required this.addressLine, required this.locality, required this.city, required this.state, required this.pincode, required this.latitude, required this.longitude, final  Map<String, bool> amenities = const <String, bool>{}, final  Map<String, dynamic>? rules, this.foodIncluded = false, this.noticePeriodDays = 30, required this.status, final  List<PropertyPhoto> photos = const <PropertyPhoto>[], this.occupancy = const OccupancySummary(), this.minRentPaise, this.maxRentPaise, this.createdAt, this.updatedAt}): _amenities = amenities,_rules = rules,_photos = photos,super._();
  factory _Property.fromJson(Map<String, dynamic> json) => _$PropertyFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  PropertyGenderType genderType;
@override final  String addressLine;
@override final  String locality;
@override final  String city;
@override final  String state;
@override final  String pincode;
@override final  double latitude;
@override final  double longitude;
 final  Map<String, bool> _amenities;
@override@JsonKey() Map<String, bool> get amenities {
  if (_amenities is EqualUnmodifiableMapView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_amenities);
}

 final  Map<String, dynamic>? _rules;
@override Map<String, dynamic>? get rules {
  final value = _rules;
  if (value == null) return null;
  if (_rules is EqualUnmodifiableMapView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  bool foodIncluded;
@override@JsonKey() final  int noticePeriodDays;
@override final  PropertyStatus status;
 final  List<PropertyPhoto> _photos;
@override@JsonKey() List<PropertyPhoto> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override@JsonKey() final  OccupancySummary occupancy;
@override final  int? minRentPaise;
@override final  int? maxRentPaise;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertyCopyWith<_Property> get copyWith => __$PropertyCopyWithImpl<_Property>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropertyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Property&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.genderType, genderType) || other.genderType == genderType)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.pincode, pincode) || other.pincode == pincode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&const DeepCollectionEquality().equals(other._rules, _rules)&&(identical(other.foodIncluded, foodIncluded) || other.foodIncluded == foodIncluded)&&(identical(other.noticePeriodDays, noticePeriodDays) || other.noticePeriodDays == noticePeriodDays)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.occupancy, occupancy) || other.occupancy == occupancy)&&(identical(other.minRentPaise, minRentPaise) || other.minRentPaise == minRentPaise)&&(identical(other.maxRentPaise, maxRentPaise) || other.maxRentPaise == maxRentPaise)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,genderType,addressLine,locality,city,state,pincode,latitude,longitude,const DeepCollectionEquality().hash(_amenities),const DeepCollectionEquality().hash(_rules),foodIncluded,noticePeriodDays,status,const DeepCollectionEquality().hash(_photos),occupancy,minRentPaise,maxRentPaise,createdAt,updatedAt]);

@override
String toString() {
  return 'Property(id: $id, name: $name, description: $description, genderType: $genderType, addressLine: $addressLine, locality: $locality, city: $city, state: $state, pincode: $pincode, latitude: $latitude, longitude: $longitude, amenities: $amenities, rules: $rules, foodIncluded: $foodIncluded, noticePeriodDays: $noticePeriodDays, status: $status, photos: $photos, occupancy: $occupancy, minRentPaise: $minRentPaise, maxRentPaise: $maxRentPaise, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PropertyCopyWith<$Res> implements $PropertyCopyWith<$Res> {
  factory _$PropertyCopyWith(_Property value, $Res Function(_Property) _then) = __$PropertyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, PropertyGenderType genderType, String addressLine, String locality, String city, String state, String pincode, double latitude, double longitude, Map<String, bool> amenities, Map<String, dynamic>? rules, bool foodIncluded, int noticePeriodDays, PropertyStatus status, List<PropertyPhoto> photos, OccupancySummary occupancy, int? minRentPaise, int? maxRentPaise, DateTime? createdAt, DateTime? updatedAt
});


@override $OccupancySummaryCopyWith<$Res> get occupancy;

}
/// @nodoc
class __$PropertyCopyWithImpl<$Res>
    implements _$PropertyCopyWith<$Res> {
  __$PropertyCopyWithImpl(this._self, this._then);

  final _Property _self;
  final $Res Function(_Property) _then;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? genderType = null,Object? addressLine = null,Object? locality = null,Object? city = null,Object? state = null,Object? pincode = null,Object? latitude = null,Object? longitude = null,Object? amenities = null,Object? rules = freezed,Object? foodIncluded = null,Object? noticePeriodDays = null,Object? status = null,Object? photos = null,Object? occupancy = null,Object? minRentPaise = freezed,Object? maxRentPaise = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Property(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,genderType: null == genderType ? _self.genderType : genderType // ignore: cast_nullable_to_non_nullable
as PropertyGenderType,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,rules: freezed == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,foodIncluded: null == foodIncluded ? _self.foodIncluded : foodIncluded // ignore: cast_nullable_to_non_nullable
as bool,noticePeriodDays: null == noticePeriodDays ? _self.noticePeriodDays : noticePeriodDays // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PropertyStatus,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<PropertyPhoto>,occupancy: null == occupancy ? _self.occupancy : occupancy // ignore: cast_nullable_to_non_nullable
as OccupancySummary,minRentPaise: freezed == minRentPaise ? _self.minRentPaise : minRentPaise // ignore: cast_nullable_to_non_nullable
as int?,maxRentPaise: freezed == maxRentPaise ? _self.maxRentPaise : maxRentPaise // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OccupancySummaryCopyWith<$Res> get occupancy {
  
  return $OccupancySummaryCopyWith<$Res>(_self.occupancy, (value) {
    return _then(_self.copyWith(occupancy: value));
  });
}
}

// dart format on
