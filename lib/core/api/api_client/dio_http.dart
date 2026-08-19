import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_footsall/core/api/api_client/ihttp.dart';
import 'package:hamro_footsall/core/api/api_client/logging_interceptor.dart';

class DioHttp implements IHttp {
  static const String _apiTokenHeader = 'X-API-TOKEN';
  late Dio dio;

  DioHttp._privateConstructor();
  static final DioHttp _instance = DioHttp._privateConstructor();

  factory DioHttp() {
    _instance.dio = Dio();
    _instance.dio.options = BaseOptions(
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 20000),
      listFormat: ListFormat.multiCompatible,
    );
    _instance.dio.interceptors.add(LoggingInterceptor());
    return _instance;
  }

  @override
  delete({String? url, String? token}) async {
    _applyHeaders(url: url, token: token);
    await addUserAgent();
    return dio.delete(url!);
  }

  @override
  get({String? url, String? token, Map? query, dynamic data}) async {
    _applyHeaders(url: url, token: token, data: data);
    await addUserAgent();
    // A few endpoints expect their filters in a JSON body on GET, so the body
    // is only attached when one is supplied.
    return dio.get(
      url!,
      queryParameters: query as Map<String, dynamic>?,
      data: data,
    );
  }

  @override
  patch({String? url, dynamic data, String? token}) async {
    _applyHeaders(url: url, token: token, data: data);
    await addUserAgent();
    return dio.patch(url!, data: data);
  }

  @override
  post({String? url, dynamic data, Map? query, String? token}) async {
    _applyHeaders(url: url, token: token, data: data);
    await addUserAgent();
    if (data != null && query != null) {
      return dio.post(
        url!,
        data: data,
        queryParameters: query as Map<String, dynamic>?,
      );
    } else if (data != null) {
      return dio.post(url!, data: data);
    } else if (query != null) {
      return dio.post(url!, queryParameters: query as Map<String, dynamic>?);
    } else {
      return dio.post(url!, data: data);
    }
  }

  @override
  put({String? url, dynamic data, String? token}) async {
    _applyHeaders(url: url, token: token, data: data);
    await addUserAgent();
    return dio.put(url!, data: data);
  }

  void _applyHeaders({String? url, String? token, dynamic data}) {
    final bool isMultipart = data is FormData;
    dio.options.contentType = isMultipart
        ? Headers.multipartFormDataContentType
        : Headers.jsonContentType;
    dio.options.headers.remove('content-Type');
    dio.options.headers.remove(Headers.contentTypeHeader);
    if (!isMultipart) {
      dio.options.headers[Headers.contentTypeHeader] = Headers.jsonContentType;
    }
    dio.options.headers['Accept'] = 'application/json';

    if (_isApiRequest(url)) {
      final String apiToken = dotenv.env['SECURE_API_TOKEN'] ?? 'hello';
      dio.options.headers[_apiTokenHeader] = apiToken;
    } else {
      dio.options.headers.remove(_apiTokenHeader);
    }

    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  bool _isApiRequest(String? url) => url != null && url.contains('/api/');

  addUserAgent() async {
    /*if (packageInfo == null && deviceInfo == null){
      packageInfo = await PackageInfo.fromPlatform();
      deviceInfo = DeviceInfoPlugin();
    }*/
    // if (Platform.isAndroid) {
    //   androidDeviceInfo ??= await deviceInfo!.androidInfo;
    dio.options.headers["User-Agent"] = " okhttp";
    // } else {
    // iosDeviceInfo ??= await deviceInfo!.iosInfo;
    // dio.options.headers["User-Agent"] = "${packageInfo!.appName}/${packageInfo!.version} (${packageInfo!.packageName}; build: ${packageInfo!.buildNumber}; ${Platform.operatingSystem} ${iosDeviceInfo!.systemVersion})";
    // }
  }
}
