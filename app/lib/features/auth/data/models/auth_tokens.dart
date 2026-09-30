import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

/// Response of `POST /auth/otp/verify` and `POST /auth/refresh`.
///
/// Shape per CLAUDE.md 6:
/// `{ accessToken, refreshToken, user, isNewUser }`.
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    User? user,
    @Default(false) bool isNewUser,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
