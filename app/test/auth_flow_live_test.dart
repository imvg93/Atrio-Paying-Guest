import 'dart:io';

import 'package:atrio_pg/core/network/api_client.dart';
import 'package:atrio_pg/core/network/api_exception.dart';
import 'package:atrio_pg/core/network/auth_interceptor.dart';
import 'package:atrio_pg/core/storage/token_storage.dart';
import 'package:atrio_pg/features/auth/application/auth_controller.dart';
import 'package:atrio_pg/features/auth/application/auth_state.dart';
import 'package:atrio_pg/features/auth/data/auth_repository.dart';
import 'package:atrio_pg/features/auth/data/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives the real auth flow against a running backend, through the app's own
/// [ApiClient], [AuthInterceptor], [AuthRepository] and [AuthController].
///
/// This is the piece unit tests cannot give: it proves the envelope unwrapping,
/// the freezed model field names, the enum wire values and the refresh
/// interceptor all agree with what the Java backend actually emits. A contract
/// mismatch here is invisible to `flutter analyze`.
///
/// Skips itself when no backend is listening, so `flutter test` stays green on
/// a machine that is not running one:
///
/// ```
/// flutter test --dart-define=API_BASE_URL=http://localhost:8080/api/v1
/// ```
void main() {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  // The OTP is not delivered anywhere in development — LoggingSmsSender writes
  // it to the backend log — so the test reads it back out of that log.
  const logPath = String.fromEnvironment('BACKEND_LOG');

  late bool backendUp;

  setUpAll(() async {
    // Needed for the platform-channel mock below. It also installs
    // HttpOverrides that answer every real request with an empty 400, so that
    // a widget test can never touch the network by accident — which is exactly
    // what this file is for. Dropping the override restores real dart:io.
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;

    backendUp = await _probe(baseUrl);
    _installSecureStorageMock();
  });

  // Each test starts signed out. Without this the token pair from the previous
  // test survives in the mock keystore and the session looks already restored.
  setUp(_secureStorageContents.clear);

  /// Reads the newest code the backend logged.
  Future<String> latestCode() async {
    final lines = await File(logPath).readAsLines();
    final line = lines.lastWhere((l) => l.contains('code  :'));
    return line.split('code  :').last.trim();
  }

  String newPhone() =>
      '+9199${DateTime.now().microsecondsSinceEpoch % 100000000}'
          .padRight(13, '0')
          .substring(0, 13);

  ProviderContainer container() => ProviderContainer(
        overrides: [
          dioProvider.overrideWith((ref) {
            final options = BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              contentType: Headers.jsonContentType,
            );
            final dio = Dio(options);
            // Same wiring as production, including the queued refresh
            // interceptor — that is the part under test.
            dio.interceptors.add(
              AuthInterceptor(
                storage: ref.watch(tokenStorageProvider),
                refreshDio: Dio(options),
                onAuthFailure: () async {
                  ref.read(authFailureProvider.notifier).signal();
                },
              ),
            );
            return dio;
          }),
        ],
      );

  test('request -> verify -> me -> refresh -> logout', () async {
    if (!backendUp || logPath.isEmpty) {
      markTestSkipped(
        'No backend at $baseUrl (or BACKEND_LOG unset) — skipping live flow.',
      );
      return;
    }

    final ref = container();
    addTearDown(ref.dispose);

    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    final phone = newPhone();

    // --- request ---------------------------------------------------
    await repo.requestOtp(phone);
    final code = await latestCode();
    expect(code, matches(r'^\d{6}$'));

    // --- verify ----------------------------------------------------
    final tokens = await repo.verifyOtp(phone: phone, code: code);
    expect(tokens.accessToken, isNotEmpty);
    expect(tokens.refreshToken, isNotEmpty);
    expect(tokens.isNewUser, isTrue,
        reason: 'a phone never seen before must create an account');
    expect(tokens.user, isNotNull);
    expect(tokens.user!.phone, phone);
    expect(tokens.user!.role, UserRole.student);
    expect(tokens.user!.roleLocked, isFalse);
    expect(tokens.user!.needsProfileCompletion, isTrue);

    await storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    // --- me --------------------------------------------------------
    final me = await repo.me();
    expect(me.id, tokens.user!.id);
    expect(me.phone, phone);
    expect(me.name, isNull);
    expect(me.createdAt, isNotNull,
        reason: 'timestamps must parse as DateTime, not arrive as strings');

    // --- profile ---------------------------------------------------
    final profiled = await repo.updateProfile(
      name: 'Asha Rao',
      role: UserRole.owner,
      gender: Gender.female,
    );
    expect(profiled.role, UserRole.owner);
    expect(profiled.roleLocked, isTrue);
    expect(profiled.needsProfileCompletion, isFalse);

    // Role is settable once — the client must see the documented code.
    await expectLater(
      repo.updateProfile(role: UserRole.student),
      throwsA(isA<ApiException>().having(
        (e) => e.code,
        'code',
        ApiErrorCode.roleAlreadySet,
      )),
    );

    // --- refresh ---------------------------------------------------
    // Poison the access token so the next authenticated call 401s. That is
    // what makes AuthInterceptor run its refresh-and-retry path for real,
    // rather than us calling /auth/refresh by hand.
    await storage.saveTokens(
      accessToken: 'expired.access.token',
      refreshToken: tokens.refreshToken,
    );

    final afterRefresh = await repo.me();
    expect(afterRefresh.phone, phone,
        reason: 'the interceptor should have refreshed and replayed the call');

    final rotated = await storage.readAccessToken();
    expect(rotated, isNot('expired.access.token'),
        reason: 'a refreshed access token must have been stored');
    final rotatedRefresh = await storage.readRefreshToken();
    expect(rotatedRefresh, isNot(tokens.refreshToken),
        reason: 'the backend rotates refresh tokens on every use');

    // --- logout ----------------------------------------------------
    await repo.logout(rotatedRefresh!);

    // The revoked token must not buy a new session. Asked directly, because
    // the client is now signed out and has nothing left to ask with.
    final bare = Dio(BaseOptions(baseUrl: baseUrl));
    final rejected = await bare.post<dynamic>(
      '/auth/refresh',
      data: {'refreshToken': rotatedRefresh},
      options: Options(validateStatus: (_) => true),
    );
    expect(rejected.statusCode, 401);
    expect(rejected.data['success'], isFalse);
  });

  test('AuthController drives the same flow and lands in the right state',
      () async {
    if (!backendUp || logPath.isEmpty) {
      markTestSkipped('No backend at $baseUrl — skipping live flow.');
      return;
    }

    final ref = container();
    addTearDown(ref.dispose);

    final controller = ref.read(authControllerProvider.notifier);
    await ref.read(authControllerProvider.future);
    expect(ref.read(authControllerProvider).value, isA<AuthUnauthenticated>());

    final phone = newPhone();
    await controller.requestOtp(phone);
    await controller.verifyOtp(phone: phone, code: await latestCode());

    expect(ref.read(authControllerProvider).value, isA<AuthNeedsProfile>(),
        reason: 'a brand-new account has no name and no chosen role');

    await controller.completeProfile(name: 'Ravi K', role: UserRole.owner);

    final state = ref.read(authControllerProvider).value;
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).role, UserRole.owner);

    await controller.logout();
    expect(ref.read(authControllerProvider).value, isA<AuthUnauthenticated>());
  });
}

/// True when something answers the health endpoint.
///
/// Reports why it failed rather than skipping silently — a probe that is quietly
/// wrong turns this whole file into a no-op that still prints "All tests passed".
Future<bool> _probe(String baseUrl) async {
  try {
    final response = await Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    )).get<dynamic>('/health');
    return response.statusCode == 200;
  } catch (e) {
    // ignore: avoid_print
    print('Health probe on $baseUrl failed: $e');
    return false;
  }
}

/// Stands in for the platform keystore. Cleared between tests.
final _secureStorageContents = <String, String>{};

/// flutter_secure_storage talks to a platform plugin that does not exist in a
/// Dart-VM test, so back it with a map.
void _installSecureStorageMock() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = _secureStorageContents;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
    final key = args['key'] as String?;
    switch (call.method) {
      case 'write':
        store[key!] = args['value'] as String;
        return null;
      case 'read':
        return store[key];
      case 'delete':
        store.remove(key);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'containsKey':
        return store.containsKey(key);
      default:
        return null;
    }
  });
}
