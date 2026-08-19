import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';

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
        errorMessage =
            'The server encountered an error and could not complete your request, please retry again.';
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
        errorMessage = _extractValidationMessage(error);
        return ValidationException(
          errorMessage: errorMessage,
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

  static String _extractValidationMessage(DataError error) {
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

    return _extractMessage(error);
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
