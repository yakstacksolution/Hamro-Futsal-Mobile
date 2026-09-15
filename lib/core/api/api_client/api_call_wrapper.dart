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

  /// Builds a standalone wrapper over a specific transport so tests can assert
  /// what is actually put on the wire. Never returns the shared singleton, so
  /// tests cannot leak a fake transport into app code.
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
    // A cleared session means every authenticated endpoint would 401; refuse
    // the call here so late teardown work never reaches the network.
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
          // Inside a `catch`: nothing above would catch a throw from here, so
          // the retry is contracted to return a Result for every outcome.
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

            // If the refresh response does not carry a usable access token,
            // never persist it — doing so would overwrite the stored
            // credentials with nulls and silently log the user out on the
            // next app launch. Treat it as a failed refresh instead.
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

  /// Waits out an in-flight token refresh, then replays the call once.
  ///
  /// Every failure here comes back as a [Result], never as a thrown
  /// [DioException]. This method is awaited from inside [makeRequest]'s own
  /// `catch`, so anything thrown escapes the wrapper entirely and reaches the
  /// zone as an unhandled async error — which is how a replayed request that
  /// 401s again (a refresh that produced a token the server still rejects)
  /// was crashing the app instead of surfacing as a failed call.
  Future<Result> retryApiCallWithDelay(
    String? url,
    HttpVerb method,
    dynamic data,
    Map<dynamic, dynamic>? query,
  ) async {
    return Future.delayed(const Duration(seconds: 2), () async {
      // Everything inside is wrapped: this runs from `makeRequest`'s own
      // `catch`, so a throw from any line here — the replay, the recursion,
      // or the session teardown — leaves the wrapper entirely and lands in
      // the zone as an unhandled async error.
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
            // The replay failed on its own terms. A second 401 means the
            // fresh token is not being accepted either, so the session is
            // gone.
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
        // Nothing is meant to reach here; if something does, it is reported
        // as a failed call rather than as a crash.
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
    // FormData contains one-shot streams. Clone it for every HTTP attempt so
    // token-refresh retries do not resend already-consumed multipart files.
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
    // The session is gone (refresh failed / token revoked): stop all
    // authenticated traffic until a new token is stored.
    SessionGate.close();
    try {
      await Client.revokeAuth?.call();
    } catch (error, stackTrace) {
      // The app's own sign-out hook — it navigates, clears storage and tears
      // down sockets. A failure there must not become the caller's problem:
      // the session is already closed above, and this runs from inside error
      // handling where a throw would escape the wrapper as a crash.
      debugPrint('Sign-out after a lost session failed: $error\n$stackTrace');
    }
  }

  /// Parses the `/auth/refresh-token` response into a [TokenModel].
  ///
  /// The backend wraps successful payloads in a `data` envelope
  /// (`{"data": {"access_token": ...}}`), exactly like the login response.
  /// We unwrap it here and fall back to the top-level map so both shapes work,
  /// and tolerate the `expires_in`/`expired_in` and `access_token`/`token`
  /// key variants used elsewhere in the auth layer.
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
    // Never write bearer tokens or decoded identity claims to device logs.
    // Keep the flag because refresh handling uses it to track a new session.
    if (kDebugMode && !isTokenPrinted && token?.isNotEmpty == true) {
      isTokenPrinted = true;
    }
  }
}
