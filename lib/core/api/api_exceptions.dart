sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(
      [super.message = 'Network error. Please check your connection.']);
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException(
      [super.message = 'Request timed out. Please try again.']);
}

class ServerException extends ApiException {
  const ServerException(super.message, [super.statusCode]);
}

class AuthException extends ApiException {
  const AuthException(
      [String message = 'Authentication failed. Please sign in again.'])
      : super(message, 401);
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Resource not found.'])
      : super(message, 404);
}
