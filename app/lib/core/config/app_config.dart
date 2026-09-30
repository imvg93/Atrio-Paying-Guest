/// Environment configuration.
///
/// No URLs or keys are ever hardcoded into widgets (CLAUDE.md 3.16) — every
/// value arrives via `--dart-define` and falls back to a local-development
/// default.
///
/// Run against a local backend:
/// ```
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
/// ```
/// `10.0.2.2` is how the Android emulator reaches the host machine's
/// `localhost`. On a physical device use your machine's LAN IP instead.
class AppConfig {
  const AppConfig._();

  /// Base URL including the `/api/v1` prefix (CLAUDE.md 3.8).
  ///
  /// Defaults to the Java backend's port (8080). The legacy NestJS backend
  /// runs on 3000 and is being retired.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Enables verbose request/response logging. Off in release builds.
  static const bool enableNetworkLogs = bool.fromEnvironment(
    'ENABLE_NETWORK_LOGS',
    defaultValue: true,
  );
}
