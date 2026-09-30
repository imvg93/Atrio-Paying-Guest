import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

/// `rooms.sharing_type`. Note the JSON value `four_plus`.
enum SharingType {
  @JsonValue('single')
  single,
  @JsonValue('double')
  double_,
  @JsonValue('triple')
  triple,
  @JsonValue('four_plus')
  fourPlus;

  String get label => switch (this) {
        SharingType.single => 'Single sharing',
        SharingType.double_ => 'Double sharing',
        SharingType.triple => 'Triple sharing',
        SharingType.fourPlus => 'Four+ sharing',
      };

  /// Beds created with a room. `fourPlus` is a floor, not a cap — the owner
  /// may add more afterwards.
  int get defaultBedCount => switch (this) {
        SharingType.single => 1,
        SharingType.double_ => 2,
        SharingType.triple => 3,
        SharingType.fourPlus => 4,
      };
}

/// `beds.status`.
enum BedStatus {
  @JsonValue('available')
  available,
  @JsonValue('occupied')
  occupied,
  @JsonValue('maintenance')
  maintenance;

  String get label => switch (this) {
        BedStatus.available => 'Available',
        BedStatus.occupied => 'Occupied',
        BedStatus.maintenance => 'Maintenance',
      };
}

@freezed
abstract class Bed with _$Bed {
  const factory Bed({
    required String id,
    required String roomId,
    required String label,
    required BedStatus status,
  }) = _Bed;

  const Bed._();

  factory Bed.fromJson(Map<String, dynamic> json) => _$BedFromJson(json);

  bool get isAvailable => status == BedStatus.available;
}

@freezed
abstract class Room with _$Room {
  const factory Room({
    required String id,
    required String propertyId,
    required String roomNumber,
    int? floor,
    required SharingType sharingType,
    required int rentPerBedPaise,
    required int depositPaise,
    @Default(false) bool hasAttachedBathroom,
    @Default(false) bool hasAc,
    @Default(<Bed>[]) List<Bed> beds,
  }) = _Room;

  const Room._();

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  int get availableBedCount => beds.where((b) => b.isAvailable).length;

  bool get hasAvailability => availableBedCount > 0;
}
