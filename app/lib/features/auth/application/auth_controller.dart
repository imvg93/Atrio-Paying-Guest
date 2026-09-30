import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../data/models/user.dart';
import 'auth_state.dart';

/// Owns the session. All auth business logic lives here, never in a widget
/// (CLAUDE.md 7, Flutter rules).
class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Rebuild whenever the interceptor reports the refresh token was rejected.
    ref.watch(authFailureProvider);
    return _restoreSession();
  }

  TokenStorage get _storage => ref.read(tokenStorageProvider);
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Splash-time check: do we hold tokens, and are they still good?
  Future<AuthState> _restoreSession() async {
    final token = await _storage.readAccessToken();
    if (token == null || token.isEmpty) {
      return const AuthUnauthenticated();
    }

    try {
      final user = await _repo.me();
      return _stateForUser(user);
    } on ApiException catch (e) {
      // 401 means the interceptor already tried to refresh and failed.
      if (e.isUnauthorized) {
        await _storage.clear();
        return const AuthUnauthenticated();
      }
      // A network blip should not silently sign the user out; surface it.
      rethrow;
    }
  }

  AuthState _stateForUser(User user) => user.needsProfileCompletion
      ? AuthNeedsProfile(user)
      : AuthAuthenticated(user);

  /// Step 1 of login. Throws [ApiException] so the screen can show the reason
  /// (rate limited, invalid number, ...).
  Future<void> requestOtp(String phone) => _repo.requestOtp(phone);

  /// Step 2 of login. Persists the token pair and moves the session forward.
  Future<void> verifyOtp({
    required String phone,
    required String code,
  }) async {
    state = const AsyncLoading();
    try {
      final tokens = await _repo.verifyOtp(phone: phone, code: code);
      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      final user = tokens.user ?? await _repo.me();
      state = AsyncData(_stateForUser(user));
    } catch (e, st) {
      // Failing to verify must not destroy an existing session state.
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Completes the profile. `role` is settable only once — the backend
  /// enforces it and returns ROLE_ALREADY_SET on a second attempt.
  Future<void> completeProfile({
    required String name,
    required UserRole role,
    Gender? gender,
    String? email,
  }) async {
    final user = await _repo.updateProfile(
      name: name,
      role: role,
      gender: gender,
      email: email,
    );
    state = AsyncData(_stateForUser(user));
  }

  Future<void> updateProfile({
    String? name,
    Gender? gender,
    String? email,
  }) async {
    final user = await _repo.updateProfile(
      name: name,
      gender: gender,
      email: email,
    );
    state = AsyncData(_stateForUser(user));
  }

  /// Best-effort server-side revocation, then always clear locally — a failed
  /// network call must never leave the user stuck signed in.
  Future<void> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _repo.logout(refreshToken);
      }
    } on ApiException {
      // Ignored on purpose.
    } finally {
      await _storage.clear();
      state = const AsyncData(AuthUnauthenticated());
    }
  }

  Future<void> refreshUser() async {
    final user = await _repo.me();
    state = AsyncData(_stateForUser(user));
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

/// Convenience for widgets that only need the signed-in user.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider).value?.userOrNull;
});
