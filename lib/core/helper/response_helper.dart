import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class ResponseHelper {
  static AppException error(dynamic source) {
    final DataError error = _resolveError(source);
    final int statusCode = error.errorCode;
    String errorMessage = '';
    const String icon = 'images/close.svg';
    final dynamic errorData = _extractData(error);

    switch (statusCode) {
      case 1517:
        errorMessage = StringConstants.serverMalformedData;
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
        // ApiCallWrapper sets the localized upload-timeout copy itself, so
        // match it by value as well as by the English server wording.
        final bool uploadTimedOut =
            error.message == StringConstants.uploadSendTimedOut ||
            error.message == StringConstants.uploadProcessingTimedOut ||
            error.message.toLowerCase().contains('upload timed out');
        errorMessage = uploadTimedOut
            ? error.message
            : StringConstants.serverErrorRetry;
        return ServerException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      case 1503:
        errorMessage = StringConstants.noInternetConnectionCheckSettings;
        return NetworkException(
          errorMessage: errorMessage,
          statusCode: statusCode,
          icon: icon,
          data: errorData,
        );
      case 1599:
      case 1525:
        errorMessage = StringConstants.networkUnreachable;
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
        errorMessage = StringConstants.noContentFound;
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
          errorMessage: StringConstants.fileTooLargeForServer,
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
      return StringConstants.serverCouldNotReadAttachment;
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

    return StringConstants.somethingWentWrongTryAgain;
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
