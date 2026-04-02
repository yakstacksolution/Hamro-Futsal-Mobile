import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/api/api_client/dio_http.dart';
import 'package:hamro_footsall/core/api/api_client/ihttp.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/features/auth/data/model/token_model.dart';
import 'package:jwt_decode/jwt_decode.dart';

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
      error as DioException;
      if (error.response?.statusCode == 401 && token != null) {
        if (isTokenFreshApiCalling) {
          return await retryApiCallWithDelay(url, method, data, query);
        } else {
          TokenModel tokenModel = AppSettings().tokenModel;
          var payload = {'refresh_token': tokenModel.refreshToken};
          isTokenFreshApiCalling = true;
          try {
            var refreshResponse = await _iHttp.patch(
              url: "${APIEndpoint.baseUrl}/auth/refresh-token",
              data: payload,
            );
            isTokenFreshApiCalling = false;
            TokenModel newTokenModel = TokenModel.fromJson(
              await refreshResponse.data,
            );
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
      // Result? result;
      numberOfRetry++;
      if (!isTokenFreshApiCalling) {
        var response = await getResponseFromApi(
          url: url,
          token: AppSettings().tokenModel.accessToken,
          method: method,
          data: data,
          query: query,
        );
        numberOfRetry = 0;
        return Result.success(await response.data);
      } else {
        if (numberOfRetry < 3) {
          return await retryApiCallWithDelay(url, method, data, query);
        } else {
          await revokeAuthFromApp();
          return Result.error("Auth error");
        }
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
    dynamic response;
    switch (method) {
      case HttpVerb.get:
        response = await _iHttp.get(url: url, token: token);
        break;
      case HttpVerb.post:
        response = await _iHttp.post(
          url: url,
          data: data,
          query: query,
          token: token,
        );
        break;
      case HttpVerb.delete:
        response = await _iHttp.delete(url: url, token: token);
        break;
      case HttpVerb.patch:
        response = await _iHttp.patch(url: url, data: data, token: token);
        break;
      case HttpVerb.put:
        response = await _iHttp.put(url: url, data: data, token: token);
        break;
    }
    return response;
  }

  Future revokeAuthFromApp() async {
    isTokenFreshApiCalling = false;
    numberOfRetry = 0;
    await Client.revokeAuth!();
  }

  DataError _getErrorData(error) {
    String errorDescription = "";
    if (error is DioException) {
      DioException dioError = error;
      errorDescription = dioError.message ?? "";
    } else {
      errorDescription = 'Unexpected error';
    }
    return DataError(
      errorDescription,
      error?.response?.statusCode ?? 0,
      error?.response?.data,
    );
  }

  void printTokenDetails(String? token) {
    if (kDebugMode) {
      if (!isTokenPrinted && token != null && token.isNotEmpty) {
        isTokenPrinted = true;
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        print(
          "\n\n===============================================================\n\n",
        );
        print("token-details start");
        log(token);
        print(payload);
        print("token-details end");
        print(
          "\n\n===============================================================\n\n",
        );
      }
    }
  }
}
