/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  const ServerException({required String message}) : super(message);
}

/// Exception thrown when there's a cache error
class CacheException extends AppException {
  const CacheException({required String message}) : super(message);
}

/// Exception thrown when network is unavailable
class NetworkException extends AppException {
  const NetworkException({required String message}) : super(message);
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException({required String message}) : super(message);
}

/// Exception thrown when email verification is required
class EmailVerificationRequiredException extends AppException {
  final String email;
  const EmailVerificationRequiredException({
    required this.email,
    required String message,
  }) : super(message);
}
