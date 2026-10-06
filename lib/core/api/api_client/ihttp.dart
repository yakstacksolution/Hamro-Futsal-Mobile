import 'package:dio/dio.dart';

class IHttp {
  get({
    String? url,
    String? token,
    Map? query,
    dynamic data,
    ResponseType? responseType,
  }) {}

  post({String? url, dynamic data, Map? query, String? token}) {}

  delete({String? url, dynamic data, String? token}) {}

  patch({String? url, dynamic data, String? token}) {}

  put({String? url, dynamic data, String? token}) {}
}
