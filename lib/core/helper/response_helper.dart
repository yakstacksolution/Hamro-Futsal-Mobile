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
    final dynamic payload = error.data;

    if (payload is Map) {
      final dynamic message = payload['message'];

      if (message is Map) {
        for (final dynamic value in message.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value != null) {
            return value.toString();
          }
        }
      }

      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final dynamic errorText = payload['error'] ?? payload['detail'];
      if (errorText is String && errorText.trim().isNotEmpty) {
        return errorText;
      }
    }

    return _extractMessage(error);
  }

  static String _extractMessage(DataError error) {
    final dynamic payload = error.data;

    if (payload is Map) {
      final dynamic message = payload['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }

      final dynamic errorText = payload['error'] ?? payload['detail'];
      if (errorText is String && errorText.trim().isNotEmpty) {
        return errorText;
      }
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
}
