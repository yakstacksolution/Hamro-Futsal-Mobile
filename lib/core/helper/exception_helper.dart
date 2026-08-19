abstract class AppException implements Exception {
  final String errorMessage;
  final int statusCode;
  final String? icon;
  final dynamic data;

  AppException({
    required this.errorMessage,
    required this.statusCode,
    this.icon,
    this.data,
  });
}

class ServerException extends AppException {
  ServerException({
    required super.errorMessage,
    required super.statusCode,
    super.icon,
    super.data,
  });
}

class NetworkException extends AppException {
  NetworkException({
    required super.errorMessage,
    required super.statusCode,
    super.icon,
    super.data,
  });
}

class AuthoriseException extends AppException {
  AuthoriseException({
    required super.errorMessage,
    required super.statusCode,
    super.icon,
    super.data,
  });
}

class NoContentException extends AppException {
  NoContentException({
    required super.errorMessage,
    required super.statusCode,
    super.icon,
    super.data,
  });
}

class DefaultException extends AppException {
  DefaultException({
    required super.errorMessage,
    required super.statusCode,
    super.icon,
    super.data,
  });
}

class ValidationException extends AppException {
  ValidationException({
    required super.errorMessage,
    required super.statusCode,
    super.icon,
    super.data,
  });
}
