import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_futsal/core/api/api_client/ihttp.dart';
import 'package:hamro_futsal/core/api/api_client/logging_interceptor.dart';
import 'package:hamro_futsal/core/utils/upload_part.dart';

class DioHttp implements IHttp {
  static const String _apiTokenHeader = 'X-API-TOKEN';
  late Dio dio;
  bool _initialized = false;

  DioHttp._privateConstructor();
  static final DioHttp _instance = DioHttp._privateConstructor();

  factory DioHttp() {
    if (_instance._initialized) return _instance;
    _instance.dio = Dio();
    _instance.dio.options = BaseOptions(
      connectTimeout: const Duration(milliseconds: 15000),
      // An upload is not a 20-second operation on a phone connection. This is
      // the send timeout specifically; receive stays as it was.
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
    // A few endpoints expect their filters in a JSON body on GET, so the body
    // is only attached when one is supplied.
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

  /// Headers for ONE request.
  ///
  /// These used to be written onto the shared `dio.options`, which every
  /// in-flight request reads from. With an `await` sitting between the write
  /// and the send, a concurrent JSON request could overwrite an upload's
  /// content type in that window — the account screen alone fires several
  /// requests at once. Per-request [Options] cannot be clobbered that way.
  ///
  /// Content type is deliberately left unset for `FormData`: Dio derives
  /// `multipart/form-data; boundary=…` from the body itself, and pinning it
  /// here would strip the boundary the server needs to find the file.
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
      headers[_apiTokenHeader] = dotenv.env['SECURE_API_TOKEN'] ?? 'hello';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return Options(
      headers: headers,
      contentType: isMultipart ? null : Headers.jsonContentType,
      // An upload is two slow phases, not one: pushing the bytes up, then
      // waiting while the server stores and validates them. The default
      // 20-second receive window expires during the second phase and surfaces
      // as a 504 with a null body, even though the file arrived intact.
      sendTimeout: isMultipart ? const Duration(minutes: 2) : null,
      receiveTimeout: isMultipart ? const Duration(minutes: 2) : null,
    );
  }

  bool _isApiRequest(String? url) => url != null && url.contains('/api/');
}
