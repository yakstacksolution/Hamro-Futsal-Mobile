import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/api/api_client/api_constants.dart';
import 'package:hamro_futsal/core/api/api_client/dio_http.dart';
import 'package:hamro_futsal/core/api/api_client/ihttp.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/api_client/session_gate.dart';
import 'package:hamro_futsal/core/api/client.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';
import 'package:hamro_futsal/features/auth/data/model/token_model.dart';

typedef ApiCall = Future<Response> Function();

enum HttpVerb { get, post, delete, patch, put }

class ApiCallWrapper {
  late IHttp _iHttp;
  static bool isTokenFreshApiCalling = false;
  static const int maxNumberOfRetry = 3;
  static int numberOfRetry = 0;
  static bool isTokenPrinted = false;

  ApiCallWrapper._privateConstructor();
  static final ApiCallWrapper _instance = ApiCallWrapper._privateConstructor();

  @visibleForTesting
  ApiCallWrapper.withHttp(IHttp http) {
    _iHttp = http;
  }

  factory ApiCallWrapper() {
    _instance._iHttp = DioHttp();
    return _instance;
  }

  Future<Result> makeRequest({
    String? url,
    String? token,
    HttpVerb method = HttpVerb.get,
    dynamic data,
    Map? query,
  }) async {
    if (SessionGate.blocks(url)) {
      return Result.error(DataError('Session ended', 401, null));
    }
    printTokenDetails(token);
    try {
      if (isTokenFreshApiCalling) {
        return await retryApiCallWithDelay(url, method, data, query);
      } else {
        var response = await getResponseFromApi(
          url: url,
          token: token,
          method: method,
          data: data,
          query: query,
        );
        numberOfRetry = 0;
        return Result.success(response.data);
      }
    } catch (error) {
      if (error is FlutterError) {
        return Result.error(DataError(error.message, 0, null));
      }
      if (error is MissingPluginException) {
        return Result.error(DataError(error.message.toString(), 0, null));
      }
      if (error is UploadValidationException) {
        return Result.error(DataError(error.message, 0, null));
      }
      if (error is! DioException) {
        return Result.error(_getErrorData(error));
      }
      if (error.response?.statusCode == 401 && token != null) {
        if (isTokenFreshApiCalling) {
          return await retryApiCallWithDelay(url, method, data, query);
        } else {
          TokenModel tokenModel = AppSettings().tokenModel;
          var payload = {'refresh_token': tokenModel.refreshToken};
          isTokenFreshApiCalling = true;
          try {
            var refreshResponse = await _iHttp.post(
              url: "${APIEndpoint.baseUrl}/auth/refresh-token",
              data: payload,
            );
            isTokenFreshApiCalling = false;
            final TokenModel newTokenModel = _parseRefreshedToken(
              await refreshResponse.data,
            );

            if (newTokenModel.accessToken == null ||
                newTokenModel.accessToken!.trim().isEmpty) {
              await revokeAuthFromApp();
              return Result.error(
                DataError('Session expired. Please log in again.', 401, null),
              );
            }

            AppSettings().token = newTokenModel;
            isTokenPrinted = false;
            printTokenDetails(newTokenModel.accessToken);
            try {
              var response = await getResponseFromApi(
                url: url,
                token: newTokenModel.accessToken,
                method: method,
                data: data,
                query: query,
              );
              return Result.success(await response.data);
            } catch (error) {
              return Result.error(_getErrorData(error));
            }
          } catch (error) {
            await revokeAuthFromApp();
            return Result.error(_getErrorData(error));
          }
        }
      } else {
        return Result.error(_getErrorData(error));
      }
    }
  }

  Future<Result> retryApiCallWithDelay(
    String? url,
    HttpVerb method,
    dynamic data,
    Map<dynamic, dynamic>? query,
  ) async {
    return Future.delayed(const Duration(seconds: 2), () async {
      try {
        numberOfRetry++;
        if (!isTokenFreshApiCalling) {
          try {
            var response = await getResponseFromApi(
              url: url,
              token: AppSettings().tokenModel.accessToken,
              method: method,
              data: data,
              query: query,
            );
            numberOfRetry = 0;
            return Result.success(await response.data);
          } catch (error) {
            numberOfRetry = 0;
            if (error is DioException && error.response?.statusCode == 401) {
              await revokeAuthFromApp();
            }
            return Result.error(_getErrorData(error));
          }
        } else {
          if (numberOfRetry < maxNumberOfRetry) {
            return await retryApiCallWithDelay(url, method, data, query);
          } else {
            numberOfRetry = 0;
            await revokeAuthFromApp();
            return Result.error(
              DataError('Session expired. Please log in again.', 401, null),
            );
          }
        }
      } catch (error, stackTrace) {
        debugPrint('Retry wrapper failed unexpectedly: $error\n$stackTrace');
        numberOfRetry = 0;
        return Result.error(_getErrorData(error));
      }
    });
  }

  Future<dynamic> getResponseFromApi({
    String? url,
    String? token,
    HttpVerb method = HttpVerb.get,
    dynamic data,
    Map? query,
  }) async {
    final dynamic requestData = data is FormData ? data.clone() : data;
    dynamic response;
    switch (method) {
      case HttpVerb.get:
        response = await _iHttp.get(
          url: url,
          token: token,
          query: query,
          data: requestData,
        );
        break;
      case HttpVerb.post:
        response = await _iHttp.post(
          url: url,
          data: requestData,
          query: query,
          token: token,
        );
        break;
      case HttpVerb.delete:
        response = await _iHttp.delete(
          url: url,
          data: requestData,
          token: token,
        );
        break;
      case HttpVerb.patch:
        response = await _iHttp.patch(
          url: url,
          data: requestData,
          token: token,
        );
        break;
      case HttpVerb.put:
        response = await _iHttp.put(url: url, data: requestData, token: token);
        break;
    }
    return response;
  }

  Future revokeAuthFromApp() async {
    isTokenFreshApiCalling = false;
    numberOfRetry = 0;
    SessionGate.close();
    try {
      await Client.revokeAuth?.call();
    } catch (error, stackTrace) {
      debugPrint('Sign-out after a lost session failed: $error\n$stackTrace');
    }
  }

  TokenModel _parseRefreshedToken(dynamic payload) {
    Map<String, dynamic> data = {};
    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      final dynamic inner = map['data'];
      data = inner is Map ? Map<String, dynamic>.from(inner) : map;
    }

    final dynamic expires = data['expires_in'] ?? data['expired_in'];
    return TokenModel(
      tokenType: data['token_type'] as String?,
      expiredIn: expires is int
          ? expires
          : int.tryParse(expires?.toString() ?? ''),
      accessToken: (data['access_token'] ?? data['token']) as String?,
      refreshToken: data['refresh_token'] as String?,
    );
  }

  DataError _getErrorData(error) {
    String errorDescription = "";
    int statusCode = 0;
    dynamic responseData;
    if (error is DioException) {
      DioException dioError = error;
      statusCode = dioError.response?.statusCode ?? 0;
      responseData = dioError.response?.data;
      final bool isUpload = dioError.requestOptions.data is FormData;
      if (isUpload && dioError.type == DioExceptionType.sendTimeout) {
        errorDescription =
            'The upload timed out while sending the attachment. '
            'Check your connection and try again.';
      } else if (isUpload && dioError.type == DioExceptionType.receiveTimeout) {
        errorDescription =
            'The upload timed out while the server was processing it. '
            'Check whether your change was saved before trying again.';
      } else {
        errorDescription = dioError.message ?? "";
      }
    } else if (error is UploadValidationException) {
      errorDescription = error.message;
    } else {
      errorDescription = 'Unexpected error';
    }
    return DataError(errorDescription, statusCode, responseData);
  }

  void printTokenDetails(String? token) {
    if (kDebugMode && !isTokenPrinted && token?.isNotEmpty == true) {
      isTokenPrinted = true;
    }
  }
}
