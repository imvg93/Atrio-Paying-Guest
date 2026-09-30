/// A failure returned by the API in the envelope from CLAUDE.md 3.10:
/// ```json
/// { "success": false, "error": { "code": "...", "message": "...", "details": [...] } }
/// ```
///
/// [code] is the stable, machine-readable part — branch on it, never on
/// [message], which is human-facing and may change.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  final String code;
  final String message;
  final List<String>? details;
  final int? statusCode;

  /// The backend could not be reached at all — no HTTP response.
  factory ApiException.network([String? message]) => ApiException(
        code: ApiErrorCode.networkError,
        message: message ?? 'Cannot reach the server. Check your connection.',
      );

  factory ApiException.timeout() => const ApiException(
        code: ApiErrorCode.timeout,
        message: 'The server took too long to respond. Please try again.',
      );

  factory ApiException.unexpected([String? message]) => ApiException(
        code: ApiErrorCode.unknown,
        message: message ?? 'Something went wrong. Please try again.',
      );

  bool get isUnauthorized => statusCode == 401;

  bool get isValidation => code == ApiErrorCode.validationError;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}

/// Error codes the backend can return.
///
/// The first group mirrors the NestJS `AllExceptionsFilter` status map, which
/// the Java `GlobalExceptionHandler` reproduces exactly. The domain-specific
/// codes are not implemented on the backend yet — they are declared here so
/// screens can be written against them as each one lands.
class ApiErrorCode {
  const ApiErrorCode._();

  // --- transport-level, client-generated (never sent by the server) ---
  static const String networkError = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String unknown = 'UNKNOWN';

  // --- returned by the server today ---
  static const String badRequest = 'BAD_REQUEST';
  static const String validationError = 'VALIDATION_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String unprocessableEntity = 'UNPROCESSABLE_ENTITY';
  static const String tooManyRequests = 'TOO_MANY_REQUESTS';
  static const String internalError = 'INTERNAL_ERROR';
  static const String httpError = 'HTTP_ERROR';

  // --- planned domain codes (backend: not yet implemented) ---
  static const String otpInvalid = 'OTP_INVALID';
  static const String otpExpired = 'OTP_EXPIRED';
  static const String otpMaxAttempts = 'OTP_MAX_ATTEMPTS';
  static const String phoneRateLimited = 'PHONE_RATE_LIMITED';
  static const String refreshTokenInvalid = 'REFRESH_TOKEN_INVALID';
  static const String refreshTokenReused = 'REFRESH_TOKEN_REUSED';
  static const String roleAlreadySet = 'ROLE_ALREADY_SET';
}
