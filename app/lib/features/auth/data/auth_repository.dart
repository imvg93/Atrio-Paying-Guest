import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'models/auth_tokens.dart';
import 'models/user.dart';

/// Talks to the auth endpoints in CLAUDE.md 6.
///
/// NOTE: none of these endpoints exist on the backend yet — the Java build is
/// at Step 0 (skeleton + health only). The paths and payloads here are the
/// contract the backend must implement; the screens can be written against
/// them now and will work the moment Step 1 lands.
class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  /// `POST /auth/otp/request` — rate limited to 3 per phone per 10 minutes.
  Future<void> requestOtp(String phone) async {
    await _api.post('/auth/otp/request', body: {'phone': phone}, isPublic: true);
  }

  /// `POST /auth/otp/verify` → `{ accessToken, refreshToken, user, isNewUser }`
  Future<AuthTokens> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final data = await _api.post(
      '/auth/otp/verify',
      body: {'phone': phone, 'code': code},
      isPublic: true,
    );
    return AuthTokens.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /me` — the current user profile.
  Future<User> me() async {
    final data = await _api.get('/me');
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /auth/profile` — name, role (settable once), gender, email.
  Future<User> updateProfile({
    String? name,
    UserRole? role,
    Gender? gender,
    String? email,
  }) async {
    final body = <String, dynamic>{
      'name': ?name,
      'role': ?role?.name,
      'gender': ?gender?.name,
      'email': ?email,
    };
    final data = await _api.patch('/auth/profile', body: body);
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// `POST /auth/logout` — revokes the presented refresh token.
  Future<void> logout(String refreshToken) async {
    await _api.post('/auth/logout', body: {'refreshToken': refreshToken});
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});
