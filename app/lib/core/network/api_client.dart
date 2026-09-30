import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

/// The single HTTP entry point for the whole app (CLAUDE.md 7, Flutter rules).
/// No widget or provider may construct its own Dio.
///
/// Every method returns the **unwrapped** `data` payload: callers never see the
/// `{success, data}` envelope, and any `{success: false}` response is raised as
/// an [ApiException] instead of being returned.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool isPublic = false,
  }) =>
      _send(() => _dio.get<dynamic>(
            path,
            queryParameters: _clean(query),
            options: isPublic ? AuthInterceptor.publicOptions() : null,
          ));

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool isPublic = false,
  }) =>
      _send(() => _dio.post<dynamic>(
            path,
            data: body,
            queryParameters: _clean(query),
            options: isPublic ? AuthInterceptor.publicOptions() : null,
          ));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<dynamic>(path, data: body));

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() => _dio.put<dynamic>(path, data: body));

  Future<dynamic> delete(String path, {Object? body}) =>
      _send(() => _dio.delete<dynamic>(path, data: body));

  /// Multipart upload, used by owner photo upload.
  Future<dynamic> upload(String path, FormData form) =>
      _send(() => _dio.post<dynamic>(path, data: form));

  /// Drops null query values so they are not serialized as "null".
  Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) return null;
    final cleaned = <String, dynamic>{};
    query.forEach((key, value) {
      if (value != null) cleaned[key] = value;
    });
    return cleaned.isEmpty ? null : cleaned;
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return _unwrap(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  /// Strips the success envelope from CLAUDE.md 3.10.
  dynamic _unwrap(Response<dynamic> response) {
    final body = response.data;

    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw _errorFromBody(body, response.statusCode);
      }
      if (body.containsKey('data')) {
        return body['data'];
      }
    }

    // 204 and friends carry no body.
    if (body == null) return null;

    // A response that is not enveloped means the server contract was broken.
    throw ApiException.unexpected(
      'Malformed response from server (missing envelope).',
    );
  }

  ApiException _errorFromBody(Map<String, dynamic> body, int? statusCode) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      final rawDetails = error['details'];
      return ApiException(
        code: error['code'] as String? ?? ApiErrorCode.unknown,
        message: error['message'] as String? ??
            'Something went wrong. Please try again.',
        details: rawDetails is List
            ? rawDetails.map((e) => e.toString()).toList(growable: false)
            : null,
        statusCode: statusCode,
      );
    }
    return ApiException.unexpected();
  }

  ApiException _toApiException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout();
      case DioExceptionType.connectionError:
        return ApiException.network();
      case DioExceptionType.cancel:
        return const ApiException(
          code: ApiErrorCode.unknown,
          message: 'Request cancelled.',
        );
      default:
        break;
    }

    final body = e.response?.data;
    if (body is Map<String, dynamic>) {
      return _errorFromBody(body, e.response?.statusCode);
    }

    final status = e.response?.statusCode;
    if (status == null) return ApiException.network();

    return ApiException(
      code: ApiErrorCode.httpError,
      message: 'Request failed (HTTP $status).',
      statusCode: status,
    );
  }
}

/// Bumped when the refresh token is rejected, so the router can bounce the
/// user back to the phone-entry screen. Watching this is how the app learns
/// that a session died mid-flight.
class AuthFailureNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void signal() => state = state + 1;
}

final authFailureProvider =
    NotifierProvider<AuthFailureNotifier, int>(AuthFailureNotifier.new);

final dioProvider = Provider<Dio>((ref) {
  final baseOptions = BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    contentType: Headers.jsonContentType,
    // Dio's default (2xx only) is deliberate here. An earlier version accepted
    // everything below 500 so the client could read error envelopes itself —
    // but that also meant a 401 never became a DioException, so
    // AuthInterceptor.onError never fired and the refresh-token flow was dead
    // code: the session simply ended when the access token expired.
    //
    // Nothing is lost by letting Dio throw. The response body is already
    // parsed by then, and _toApiException reads the envelope off
    // `e.response.data` exactly as _unwrap would have.
  );

  final dio = Dio(baseOptions);
  final refreshDio = Dio(baseOptions);

  dio.interceptors.add(
    AuthInterceptor(
      storage: ref.watch(tokenStorageProvider),
      refreshDio: refreshDio,
      onAuthFailure: () async {
        ref.read(authFailureProvider.notifier).signal();
      },
    ),
  );

  if (AppConfig.enableNetworkLogs && kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
    ));
  }

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
