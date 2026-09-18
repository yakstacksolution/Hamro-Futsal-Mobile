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

/// A 422 from the API. [fieldErrors] carries the server's `errors` map as it
/// arrived — key (`closed_dates.1.date`, `court_name`, ...) to the messages for
/// that key — so a screen can point at the offending field instead of only
/// showing the flattened [errorMessage].
class ValidationException extends AppException {
  ValidationException({
    required super.errorMessage,
    required super.statusCode,
    super.icon,
    super.data,
    this.fieldErrors = const <String, List<String>>{},
  });

  final Map<String, List<String>> fieldErrors;

  /// Every message the server sent, in the order the keys arrived.
  List<String> get allMessages =>
      fieldErrors.values.expand((List<String> item) => item).toList();

  /// Messages for [field], or for any indexed member of it — passing
  /// `closed_dates` also collects `closed_dates.1.date`.
  List<String> messagesFor(String field) {
    final List<String> messages = <String>[];
    fieldErrors.forEach((String key, List<String> value) {
      if (key == field || key.startsWith('$field.')) {
        messages.addAll(value);
      }
    });
    return messages;
  }
}
