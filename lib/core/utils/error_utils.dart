import '../errors/exceptions.dart';

/// Converts raw exceptions into user-friendly error messages.
String friendlyErrorMessage(Object error) {
  if (error is AppException) {
    return _mapAppException(error);
  }

  final msg = error.toString();

  if (msg.contains('SocketException') ||
      msg.contains('Connection refused') ||
      msg.contains('Network is unreachable') ||
      msg.contains('No address associated')) {
    return 'Unable to connect to the server. Check your internet connection and try again.';
  }

  if (msg.contains('TimeoutException') || msg.contains('timed out')) {
    return 'The request took too long. Please try again.';
  }

  if (msg.contains('HandshakeException') || msg.contains('CERTIFICATE')) {
    return 'Secure connection failed. Please try again later.';
  }

  if (msg.contains('FormatException') || msg.contains('Unexpected character')) {
    return 'Received an unexpected response from the server.';
  }

  if (msg.contains('No internet') || msg.contains('NetworkException')) {
    return 'No internet connection. Please check your network and try again.';
  }

  // Strip Dart exception prefixes for cleaner display
  final cleaned = msg
      .replaceFirst(RegExp(r'^Exception:\s*'), '')
      .replaceFirst(RegExp(r'^ServerException:\s*'), '')
      .replaceFirst(RegExp(r'^AppException:\s*'), '');

  if (cleaned.length > 120) {
    return 'Something went wrong. Please try again.';
  }

  return cleaned;
}

String _mapAppException(AppException e) {
  if (e is NetworkException) {
    return 'No internet connection. Please check your network and try again.';
  }
  if (e is TimeoutException) {
    return 'The request took too long. Please try again.';
  }
  if (e is UnauthorizedException) {
    return 'Your session has expired. Please log in again.';
  }
  if (e is ForbiddenException) {
    return 'You don\'t have permission to do that.';
  }
  if (e is NotFoundException) {
    return 'The requested item was not found.';
  }
  if (e is ValidationException) {
    return e.message;
  }
  if (e is ServerException) {
    if (e.statusCode != null && e.statusCode! >= 500) {
      return 'The server is having trouble. Please try again later.';
    }
    return e.message;
  }
  return e.message;
}
