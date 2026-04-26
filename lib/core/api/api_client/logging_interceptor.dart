import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
 
class LoggingInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print("\n\n===============================================================\n\n");
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      log(options.toCurlCmd());
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
          "\n\n===============================================================\n\n");
      print(
        'RESPONSE PATH[${response.statusCode}] => PATH: ${response
            .requestOptions.path}',
      );
      print(
          'RESPONSE VALUE [${response.statusCode}] => ${jsonEncode(
              response.data.toString())}');
    }
    if(response.statusCode == 204){
      var statusCode = response.statusCode;
      var dioE = DioException(requestOptions: response.requestOptions, response: Response(requestOptions: response.requestOptions, statusCode: statusCode), type: DioExceptionType.badResponse);
      return handler.reject(dioE, true);
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response == null) {
      int statusCode = 1503;
      DioException dioE;
      if (err.error.toString().contains("SocketException")) {
        statusCode = 1503;
      } else {
        switch(err.type) {
          case DioExceptionType.connectionTimeout:
            statusCode = 522;
            break;
          case DioExceptionType.sendTimeout:
            statusCode = 552;
            break;
          case DioExceptionType.receiveTimeout:
            statusCode = 504;
            break;
          case DioExceptionType.badCertificate:
            statusCode = 502;
            break;
          case DioExceptionType.badResponse:
          case DioExceptionType.connectionError:
            statusCode = 400;
            break;
          case DioExceptionType.cancel:
            statusCode = 499;
            break;
          case DioExceptionType.unknown:
            statusCode = 1517;
            break;
        }
      }
      dioE = DioException(requestOptions: err.requestOptions, response: Response(requestOptions: err.requestOptions, statusCode: statusCode));
      if (kDebugMode) {
        print("\n\n===============================================================\n\n");
        print('ERROR[${dioE.response?.statusCode}] => PATH: ${dioE.requestOptions.path}');
        print('ERROR RESPONSE ${jsonEncode(err.response?.data.toString())}');
      }
      return super.onError(dioE, handler);
    } else {
      if (kDebugMode) {
        print("\n\n===============================================================\n\n");
        print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
        print('ERROR RESPONSE ${jsonEncode(err.response?.data.toString())}');
      }
      return super.onError(err, handler);
    }
  }

}

extension Curl on RequestOptions {
  String toCurlCmd() {
    String cmd = "curl";

    String? header = headers
        .map((key, value) {
          if (key == "content-type" &&
              value.toString().contains("multipart/form-data")) {
            value = "multipart/form-data;";
          }
          return MapEntry(key, "-H '$key: $value'");
        })
        .values
        .join(" ");
    String? url = "$baseUrl$path";
    if (queryParameters.isNotEmpty) {
      String query = queryParameters
          .map((key, value) {
            return MapEntry(key, "$key=$value");
          })
          .values
          .join("&");

      url += (url.contains("?")) ? query : "?$query";
    }
    if (method == "GET") {
      cmd += " $header '$url'";
    } else {
      Map<String, dynamic> files = {};
      String postData = "-d ''";
      if (data != null) {
        if (data is FormData) {
          FormData fData = data as FormData;
          for (var element in fData.files) {
            MultipartFile file = element.value;
            files[element.key] = "@${file.filename}";
          }
          for (var element in fData.fields) {
            files[element.key] = element.value;
          }
          if (files.isNotEmpty) {
            postData = files
                .map((key, value) => MapEntry(key, "-F '$key=$value'"))
                .values
                .join(" ");
          }
        } else if (data is Map<String, dynamic>) {
          files.addAll(data);

          if (files.isNotEmpty) {
            postData = "-d '${jsonEncode(files).toString()}'";
          }
        }
      }

      String method = this.method.toString();
      cmd += " -X $method $postData $header '$url'";
    }

    return cmd;
  }
}
