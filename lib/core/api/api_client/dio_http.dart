import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/api/api_client/api_constants.dart';
import 'package:hamro_futsal/core/api/api_client/ihttp.dart';
import 'package:hamro_futsal/core/api/api_client/logging_interceptor.dart';
import 'package:hamro_futsal/core/utils/upload_part.dart';

class DioHttp implements IHttp {
  late Dio dio;
  bool _initialized = false;

  DioHttp._privateConstructor();
  static final DioHttp _instance = DioHttp._privateConstructor();

  factory DioHttp() {
    if (_instance._initialized) return _instance;
    _instance.dio = Dio();
    _instance.dio.options = BaseOptions(
      connectTimeout: const Duration(milliseconds: 15000),
      sendTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(milliseconds: 20000),
      listFormat: ListFormat.multiCompatible,
    );
    _instance.dio.interceptors.add(LoggingInterceptor());
    _instance._initialized = true;
    return _instance;
  }

  @visibleForTesting
  DioHttp.withDio(this.dio) : _initialized = true;

  @override
  delete({String? url, dynamic data, String? token}) async {
    return dio.delete(
      url!,
      data: data,
      options: _optionsFor(url: url, token: token, data: data),
    );
  }

  @override
  get({String? url, String? token, Map? query, dynamic data}) async {
    return dio.get(
      url!,
      queryParameters: query as Map<String, dynamic>?,
      data: data,
      options: _optionsFor(url: url, token: token, data: data),
    );
  }

  @override
  patch({String? url, dynamic data, String? token}) async {
    return dio.patch(
      url!,
      data: data,
      options: _optionsFor(url: url, token: token, data: data),
    );
  }

  @override
  post({String? url, dynamic data, Map? query, String? token}) async {
    return dio.post(
      url!,
      data: data,
      queryParameters: query as Map<String, dynamic>?,
      options: _optionsFor(url: url, token: token, data: data),
    );
  }

  @override
  put({String? url, dynamic data, String? token}) async {
    return dio.put(
      url!,
      data: data,
      options: _optionsFor(url: url, token: token, data: data),
    );
  }

  Options _optionsFor({String? url, String? token, dynamic data}) {
    final bool isMultipart = data is FormData;
    if (data case final FormData form) {
      validateMultipartFormData(form);
    }
    final Map<String, dynamic> headers = <String, dynamic>{
      'Accept': 'application/json',
      'User-Agent': ' okhttp',
    };

    if (_isApiRequest(url)) {
      final String apiToken = APIEndpoint.secureApiToken;
      if (apiToken.isNotEmpty) {
        headers[APIEndpoint.secureApiTokenHeader] = apiToken;
      }
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return Options(
      headers: headers,
      contentType: isMultipart ? null : Headers.jsonContentType,
      sendTimeout: isMultipart ? const Duration(minutes: 2) : null,
      receiveTimeout: isMultipart ? const Duration(minutes: 2) : null,
    );
  }

  bool _isApiRequest(String? url) => url != null && url.contains('/api/');
}
