import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Attaches the access token and transparently recovers from expiry.
///
/// Extends [QueuedInterceptor] deliberately: if five requests fire at once and
/// all get 401, a plain interceptor would trigger five concurrent refreshes and
/// — because the backend rotates and revokes on every use — four of them would
/// fail, and reuse-detection would revoke the whole token family. Queuing means
/// exactly one refresh happens and the rest wait for it.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage storage,
    required Dio refreshDio,
    required Future<void> Function() onAuthFailure,
  })  : _storage = storage,
        _refreshDio = refreshDio,
        _onAuthFailure = onAuthFailure;

  final TokenStorage _storage;

  /// A bare Dio with no interceptors — refreshing through the main client
  /// would recurse when the refresh call itself returns 401.
  final Dio _refreshDio;

  final Future<void> Function() _onAuthFailure;

  static const _retriedFlag = 'atrio.retried';
  static const _skipAuthFlag = 'atrio.skipAuth';

  /// Marks a request as public so no token is attached.
  static Options publicOptions([Options? base]) {
    final options = base ?? Options();
    return options.copyWith(extra: {...?options.extra, _skipAuthFlag: true});
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[_skipAuthFlag] != true) {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;
    final isPublic = err.requestOptions.extra[_skipAuthFlag] == true;

    if (!isUnauthorized || alreadyRetried || isPublic) {
      return handler.next(err);
    }

    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _failAuth();
      return handler.next(err);
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final body = response.data;
      final data = body?['data'] as Map<String, dynamic>?;
      final newAccess = data?['accessToken'] as String?;
      final newRefresh = data?['refreshToken'] as String?;

      if (newAccess == null || newRefresh == null) {
        await _failAuth();
        return handler.next(err);
      }

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Replay the original request exactly once, with the new token.
      final retryOptions = err.requestOptions;
      retryOptions.extra[_retriedFlag] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';

      final retried = await _refreshDio.fetch<dynamic>(retryOptions);
      return handler.resolve(retried);
    } on DioException catch (_) {
      await _failAuth();
      return handler.next(err);
    }
  }

  Future<void> _failAuth() async {
    await _storage.clear();
    await _onAuthFailure();
  }
}
