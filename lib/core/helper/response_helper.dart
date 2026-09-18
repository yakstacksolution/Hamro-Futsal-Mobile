import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';

class ResponseHelper {
  static AppException error(dynamic source) {
    final DataError error = _resolveError(source);
    final int statusCode = error.errorCode;
    String errorMessage = '';
    const String icon = 'images/close.svg';
    final dynamic errorData = _extractData(error);

    switch (statusCode) {
      case 1517:
        errorMessage =
            'The server responded with malformed data, please retry again.';
        return ServerException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      case 500:
      case 522:
      case 504:
      case 552:
        errorMessage = error.message.toLowerCase().contains('upload timed out')
            ? error.message
            : 'The server encountered an error and could not complete your request, please retry again.';
        return ServerException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      case 1503:
        errorMessage =
            'No Internet Connection, please check your network settings and try again.';
        return NetworkException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      case 1599:
      case 1525:
        errorMessage =
            'Network unreachable, please check your network settings and try again.';
        return NetworkException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      case 401:
      case 403:
        errorMessage = _extractMessage(error);
        return AuthoriseException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      case 204:
        errorMessage = 'No content found.';
        return NoContentException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      case 422:
        final Map<String, List<String>> fieldErrors = _extractFieldErrors(
          error,
        );
        errorMessage = _extractValidationMessage(error, fieldErrors);
        return ValidationException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
          fieldErrors: fieldErrors,
        );
      case 413:
        return ValidationException(
          errorMessage:
              'The selected file is too large for the server. Choose a smaller file and try again.',
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      default:
        errorMessage = _extractMessage(error);
        return DefaultException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
    }
  }

  static DataError _resolveError(dynamic source) {
    if (source is DataError) return source;
    if (source is Result) return source.getErrorMsg() as DataError;
    throw ArgumentError(
      'ResponseHelper.error expects a Result or DataError source.',
    );
  }

  /// Laravel's `errors` bag: `{"closed_dates.1.date": ["...", ...], ...}`.
  /// Kept keyed and ordered so callers can attribute a message to the field —
  /// and, for an indexed key, to the exact row of the list they submitted.
  static Map<String, List<String>> _extractFieldErrors(DataError error) {
    final dynamic payload = _extractPreferredPayload(error);
    final dynamic errors = payload is Map ? payload['errors'] : null;
    if (errors is! Map) return const <String, List<String>>{};

    final Map<String, List<String>> result = <String, List<String>>{};
    errors.forEach((dynamic key, dynamic value) {
      final String field = key.toString();
      final List<String> messages = _flattenMessages(value);
      if (field.trim().isEmpty || messages.isEmpty) return;
      result.putIfAbsent(field, () => <String>[]).addAll(messages);
    });
    return result;
  }

  static List<String> _flattenMessages(dynamic value) {
    if (value is String) {
      return value.trim().isEmpty ? <String>[] : <String>[value.trim()];
    }
    if (value is List) {
      return value.expand((dynamic item) => _flattenMessages(item)).toList();
    }
    if (value is Map) {
      return value.values
          .expand((dynamic item) => _flattenMessages(item))
          .toList();
    }
    return <String>[];
  }

  /// Every validation message, not just the first — a single save can fail on
  /// several closed dates at once, and dropping the rest leaves the vendor
  /// fixing them one round trip at a time.
  static String _extractValidationMessage(
    DataError error, [
    Map<String, List<String>> fieldErrors = const <String, List<String>>{},
  ]) {
    final List<String> messages = <String>[];
    for (final List<String> value in fieldErrors.values) {
      for (final String message in value) {
        if (!messages.contains(message)) messages.add(message);
      }
    }
    if (messages.length == 1) {
      return _actionableUploadMessage(messages.first);
    }
    if (messages.length > 1) {
      return messages
          .map((String item) => '\u2022 ${_actionableUploadMessage(item)}')
          .join('\n');
    }

    final dynamic payload = _extractPreferredPayload(error);

    if (payload is Map) {
      final String? nestedError = _extractNestedErrorMessage(payload['errors']);
      if (nestedError != null) return _actionableUploadMessage(nestedError);

      final String? message = _readMessageValue(payload['message']);
      if (message != null) return _actionableUploadMessage(message);

      final String? errorText = _readMessageValue(
        payload['error'] ?? payload['detail'],
      );
      if (errorText != null) return _actionableUploadMessage(errorText);
    }

    return _actionableUploadMessage(_extractMessage(error));
  }

  static String _actionableUploadMessage(String message) {
    final String lower = message.toLowerCase();
    final bool mentionsUpload =
        lower.contains('upload') ||
        lower.contains('file') ||
        lower.contains('proof') ||
        lower.contains('document');
    final bool unreadable =
        lower.contains('failed to upload') ||
        lower.contains('size 0') ||
        lower.contains('zero byte') ||
        lower.contains('empty');
    if (mentionsUpload && unreadable) {
      return 'The server could not read the attachment. Reattach a smaller file and try again.';
    }
    return message;
  }

  static String _extractMessage(DataError error) {
    final dynamic payload = _extractPreferredPayload(error);

    if (payload is Map) {
      final String? nestedError = _extractNestedErrorMessage(payload['errors']);
      if (nestedError != null) return nestedError;

      final String? message = _readMessageValue(payload['message']);
      if (message != null) return message;

      final String? errorText = _readMessageValue(
        payload['error'] ?? payload['detail'],
      );
      if (errorText != null) return errorText;
    }

    if (error.message.trim().isNotEmpty) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }

  static dynamic _extractData(DataError error) {
    final dynamic payload = error.data;

    if (payload is Map) {
      if (payload['data'] != null) {
        return payload['data'];
      }
      return payload;
    }

    return payload;
  }

  static dynamic _extractPreferredPayload(DataError error) {
    final dynamic payload = error.data;
    if (payload is Map && payload['data'] != null) {
      return payload['data'];
    }
    return payload;
  }

  static String? _readMessageValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    if (value is List) {
      for (final dynamic item in value) {
        final String? message = _readMessageValue(item);
        if (message != null) return message;
      }
    }

    if (value is Map) {
      for (final dynamic item in value.values) {
        final String? message = _readMessageValue(item);
        if (message != null) return message;
      }
    }

    return null;
  }

  static String? _extractNestedErrorMessage(dynamic value) {
    if (value is Map) {
      for (final dynamic item in value.values) {
        final String? message = _readMessageValue(item);
        if (message != null) return message;
      }
    }

    return _readMessageValue(value);
  }
}
