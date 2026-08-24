import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_footsall/core/api/api_client/api_call_wrapper.dart';
import 'package:hamro_footsall/core/api/api_client/dio_http.dart';
import 'package:hamro_footsall/core/api/api_client/ihttp.dart';
import 'package:hamro_footsall/core/api/api_client/logging_interceptor.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/core/utils/upload_part.dart';
import 'package:hamro_footsall/features/auth/data/model/token_model.dart';

void main() {
  test(
    'concurrent JSON and multipart requests keep isolated headers',
    () async {
      final _RecordingAdapter adapter = _RecordingAdapter();
      final Dio dio = Dio()..httpClientAdapter = adapter;
      final DioHttp http = DioHttp.withDio(dio);
      final FormData form = FormData.fromMap(<String, dynamic>{
        'payment_proof': buildUploadPart(
          UploadAttachment(
            filename: 'proof.jpg',
            bytes: Uint8List.fromList(List<int>.filled(512, 4)),
          ),
        ),
      });

      await Future.wait(<Future<dynamic>>[
        http.post(
          url: 'https://example.test/upload',
          token: 'upload-token',
          data: form,
        ),
        http.post(
          url: 'https://example.test/json',
          token: 'json-token',
          data: <String, dynamic>{'page': 1},
        ),
      ]);

      final _RecordedRequest upload = adapter.requests.singleWhere(
        (request) => request.path.endsWith('/upload'),
      );
      final _RecordedRequest json = adapter.requests.singleWhere(
        (request) => request.path.endsWith('/json'),
      );
      expect(upload.authorization, 'Bearer upload-token');
      expect(json.authorization, 'Bearer json-token');
      expect(upload.contentType, startsWith('multipart/form-data; boundary='));
      expect(json.contentType, Headers.jsonContentType);
      expect(upload.bodyLength, greaterThan(512));
      expect(upload.sendTimeout, const Duration(minutes: 2));
      expect(upload.receiveTimeout, const Duration(minutes: 2));
    },
  );

  test('401 refresh retry sends the full multipart body twice', () async {
    dotenv.loadFromString(
      envString:
          'API_URL=https://example.test\nCHAT_URL=https://chat.example.test\nCHAT_X_ORIGIN=test',
    );
    final _MemoryPreferences preferences = _MemoryPreferences();
    await AppSettings().init(preferences);
    AppSettings().token = const TokenModel(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );
    ApiCallWrapper.isTokenFreshApiCalling = false;
    ApiCallWrapper.numberOfRetry = 0;
    ApiCallWrapper.isTokenPrinted = true;
    final _RefreshThenSuccessHttp http = _RefreshThenSuccessHttp();
    final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(http);
    final FormData original = FormData.fromMap(<String, dynamic>{
      'payment_proof': buildUploadPart(
        UploadAttachment(
          filename: 'proof.jpg',
          bytes: Uint8List.fromList(List<int>.filled(700, 8)),
        ),
      ),
    });

    final result = await wrapper.makeRequest(
      url: 'https://example.test/upload',
      token: 'old-access',
      method: HttpVerb.post,
      data: original,
    );

    expect(
      result.isSuccess(),
      isTrue,
      reason: result.isError()
          ? '${result.getErrorMsg().runtimeType}: ${result.getErrorMsg()}'
          : null,
    );
    expect(http.uploadWireLengths, hasLength(2));
    expect(http.uploadWireLengths[0], greaterThan(700));
    expect(http.uploadWireLengths[1], http.uploadWireLengths[0]);
    expect(http.uploadTokens, <String?>[
      'old-access',
      _RefreshThenSuccessHttp.refreshedAccessToken,
    ]);
  });

  test(
    'multipart send timeout asks the user to retry the connection',
    () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _TimeoutAdapter()
        ..interceptors.add(LoggingInterceptor());
      final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(
        DioHttp.withDio(dio),
      );
      final Result result = await wrapper.makeRequest(
        url: 'https://example.test/upload',
        method: HttpVerb.post,
        data: FormData.fromMap(<String, dynamic>{
          'payment_proof': buildUploadPart(
            UploadAttachment(
              filename: 'proof.jpg',
              bytes: Uint8List.fromList(<int>[1, 2, 3]),
            ),
          ),
        }),
      );

      final DataError error = result.getErrorMsg() as DataError;
      expect(error.errorCode, 552);
      expect(error.message, contains('Check your connection'));
    },
  );
}

final class _RecordedRequest {
  const _RecordedRequest({
    required this.path,
    required this.authorization,
    required this.contentType,
    required this.bodyLength,
    required this.sendTimeout,
    required this.receiveTimeout,
  });

  final String path;
  final String? authorization;
  final String? contentType;
  final int bodyLength;
  final Duration? sendTimeout;
  final Duration? receiveTimeout;
}

final class _RecordingAdapter implements HttpClientAdapter {
  final List<_RecordedRequest> requests = <_RecordedRequest>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    int bodyLength = 0;
    if (requestStream != null) {
      await for (final Uint8List chunk in requestStream) {
        bodyLength += chunk.length;
      }
    }
    requests.add(
      _RecordedRequest(
        path: options.path,
        authorization: options.headers['Authorization']?.toString(),
        contentType: options.headers[Headers.contentTypeHeader]?.toString(),
        bodyLength: bodyLength,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
      ),
    );
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'ok': true}),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final class _TimeoutAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.sendTimeout,
      message: 'send timed out',
    );
  }

  @override
  void close({bool force = false}) {}
}

final class _RefreshThenSuccessHttp extends IHttp {
  static const String refreshedAccessToken =
      'eyJhbGciOiJub25lIn0.eyJzdWIiOiIxIn0.';

  int uploadAttempts = 0;
  final List<int> uploadWireLengths = <int>[];
  final List<String?> uploadTokens = <String?>[];

  @override
  Future<Response<dynamic>> post({
    String? url,
    dynamic data,
    Map? query,
    String? token,
  }) async {
    final RequestOptions options = RequestOptions(path: url ?? '');
    if (url?.endsWith('/auth/refresh-token') ?? false) {
      return Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{
          'data': <String, dynamic>{
            'access_token': refreshedAccessToken,
            'refresh_token': 'new-refresh',
          },
        },
      );
    }

    uploadAttempts++;
    uploadTokens.add(token);
    int length = 0;
    await for (final List<int> chunk in (data as FormData).finalize()) {
      length += chunk.length;
    }
    uploadWireLengths.add(length);
    if (uploadAttempts == 1) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 401,
          data: <String, dynamic>{'message': 'expired'},
        ),
      );
    }
    return Response<dynamic>(
      requestOptions: options,
      statusCode: 200,
      data: <String, dynamic>{'ok': true},
    );
  }
}

final class _MemoryPreferences implements Preferences {
  final Map<String, Object> values = <String, Object>{};

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  double? getDouble(String key) => values[key] as double?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  List<String> getStringList(String key) =>
      (values[key] as List<String>?) ?? <String>[];

  @override
  Future<bool> remove(String key) async => values.remove(key) != null;

  @override
  Future<bool> setBool(String key, bool value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> permissions) async {
    values[key] = List<String>.from(permissions);
    return true;
  }
}
