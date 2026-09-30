import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// `users.role`. JSON values match the Postgres enum labels exactly.
enum UserRole {
  @JsonValue('student')
  student,
  @JsonValue('owner')
  owner,
  @JsonValue('admin')
  admin;

  bool get isStudent => this == UserRole.student;
  bool get isOwner => this == UserRole.owner;
  bool get isAdmin => this == UserRole.admin;
}

/// `users.gender`.
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other;

  String get label => switch (this) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.other => 'Other',
      };
}

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String phone,
    String? name,
    String? email,
    required UserRole role,
    Gender? gender,
    String? avatarUrl,
    @Default(true) bool isActive,

    /// True once the role has been chosen. The server sets this the first time
    /// `PATCH /auth/profile` supplies a role and refuses to change it after,
    /// so it is the authoritative answer to "has this user picked yet?" —
    /// `role` alone cannot say, since a new account starts as a provisional
    /// student.
    @Default(false) bool roleLocked,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// True until the user has both named themselves and picked a role on the
  /// profile screen. Both halves matter: a user who somehow has a name but no
  /// chosen role would otherwise be routed into the app as a student they
  /// never agreed to be.
  bool get needsProfileCompletion =>
      name == null || name!.trim().isEmpty || !roleLocked;

  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : phone;
}
