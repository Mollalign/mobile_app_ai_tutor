// Custom exceptions for the application.
//
// These are thrown in the data layer and converted to Failures
// in the domain layer for proper error handling.

/// Base exception class for all app exceptions.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  
  const AppException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

/// Thrown when there's a network/server error.
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred', super.statusCode]);
}

/// Thrown when authentication fails (401).
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized'])
      : super(message, 401);
}

/// Thrown when the resource is forbidden (403).
class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Access forbidden'])
      : super(message, 403);
}

/// Thrown when the resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found'])
      : super(message, 404);
}

/// Thrown when validation fails (422).
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;
  
  const ValidationException([
    String message = 'Validation failed',
    this.errors,
  ]) : super(message, 422);
}

/// Thrown when there's no internet connection.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Thrown when request times out.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

/// Thrown when token refresh fails.
class TokenRefreshException extends AppException {
  const TokenRefreshException([String message = 'Session expired. Please login again.'])
      : super(message, 401);
}