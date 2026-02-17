class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, statusCode: 400);
}

class UnauthorizedException extends AppException {
  UnauthorizedException() : super('Unauthorized', statusCode: 401);
}

class ServerException extends AppException {
  ServerException(String message) : super(message, statusCode: 500);
}