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
  get({String? url, String? token}) async {
    _applyHeaders(url: url, token: token);
    await addUserAgent();
    return dio.get(url!);
  }

  @override
  patch({String? url, Map? data, String? token}) async {
    _applyHeaders(url: url, token: token);
    await addUserAgent();
    return dio.patch(url!, data: data);
  }

  @override
  post({String? url, Map? data, Map? query, String? token}) async {
    _applyHeaders(url: url, token: token);
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
      return dio.post(url!, queryParameters: data as Map<String, dynamic>?);
    } else {
      return dio.post(url!, data: data);
    }
  }

  @override
  put({String? url, Map? data, String? token}) async {
    _applyHeaders(url: url, token: token);
    await addUserAgent();
    return dio.put(url!, data: data);
  }

  void _applyHeaders({String? url, String? token}) {
    dio.options.headers['content-Type'] = 'application/json';
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
