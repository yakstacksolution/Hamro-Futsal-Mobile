import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/api_call_wrapper.dart';
import 'package:hamro_futsal/core/api/api_client/ihttp.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/api_client/session_gate.dart';
import 'package:hamro_futsal/core/api/client.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/features/auth/data/model/token_model.dart';

/// A replayed request that fails again used to throw out of
/// `retryApiCallWithDelay`. That method is awaited from inside `makeRequest`'s
/// own `catch`, so the DioException escaped the wrapper and reached the zone
/// as an unhandled async error — Crashlytics logged it as a fatal
/// `DioException [bad response] … status code of 401`, killing the app on a
/// background presence ping.
void main() {
  setUpAll(() async {
    dotenv.loadFromString(
      envString:
          'API_URL=https://example.test\nCHAT_URL=https://chat.example.test\nCHAT_X_ORIGIN=test',
    );
    // AppSettings holds its preferences in a `late final`, so it can only be
    // initialised once per test process.
    if (!AppSettings().isInitialized) {
      await AppSettings().init(_MemoryPreferences());
    }
  });

  setUp(() {
    AppSettings().token = const TokenModel(
      accessToken: 'fresh-access',
      refreshToken: 'fresh-refresh',
    );
    ApiCallWrapper.isTokenFreshApiCalling = false;
    ApiCallWrapper.numberOfRetry = 0;
    ApiCallWrapper.isTokenPrinted = true;
    SessionGate.open();
  });

  test(
    'a replay that 401s again returns a Result instead of throwing',
    () async {
      final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(
        _AlwaysFailsHttp(401),
      );

      final Result result = await wrapper.retryApiCallWithDelay(
        'https://example.test/auth/set-presence',
        HttpVerb.post,
        <String, dynamic>{'online': false},
        null,
      );

      expect(result.isError(), isTrue);
      // The session is gone, so authenticated traffic is stopped rather than
      // retried in a loop.
      expect(
        SessionGate.blocks('https://example.test/auth/set-presence'),
        isTrue,
      );
    },
  );

  test(
    'a replay that fails for any other reason also returns a Result',
    () async {
      final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(
        _AlwaysFailsHttp(500),
      );

      final Result result = await wrapper.retryApiCallWithDelay(
        'https://example.test/auth/set-presence',
        HttpVerb.post,
        null,
        null,
      );

      expect(result.isError(), isTrue);
      // A server error says nothing about the session — it stays open.
      expect(
        SessionGate.blocks('https://example.test/auth/set-presence'),
        isFalse,
      );
    },
  );

  test('the wishlist path reports a 401 instead of crashing the app', () async {
    // The reported crash: GET /auth/wishlist 401s while a refresh is in
    // flight, so `makeRequest` goes through the retry, the replay 401s too,
    // and the DioException escaped as a fatal error on the wishlist page.
    ApiCallWrapper.isTokenFreshApiCalling = true;
    final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(
      _AlwaysFailsHttp(401),
    );

    final Result result = await wrapper.makeRequest(
      url: 'https://example.test/auth/wishlist',
      token: 'stale-access',
    );

    expect(result.isError(), isTrue);
  });

  test('a sign-out hook that throws does not escape the wrapper', () async {
    // `Client.revokeAuth` is the app's own logout: it navigates and tears
    // down sockets. It runs from inside error handling, so a throw there
    // would leave the wrapper exactly the way the 401 did.
    Client.revokeAuth = () async => throw StateError('navigator is gone');
    addTearDown(() => Client.revokeAuth = null);

    final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(
      _AlwaysFailsHttp(401),
    );

    final Result result = await wrapper.retryApiCallWithDelay(
      'https://example.test/auth/wishlist',
      HttpVerb.get,
      null,
      null,
    );

    expect(result.isError(), isTrue);
    // The session is still closed, even though the hook failed.
    expect(SessionGate.blocks('https://example.test/auth/wishlist'), isTrue);
  });

  test('giving up after the retry budget reports a session error', () async {
    ApiCallWrapper.isTokenFreshApiCalling = true;
    ApiCallWrapper.numberOfRetry = ApiCallWrapper.maxNumberOfRetry;
    final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(
      _AlwaysFailsHttp(401),
    );

    final Result result = await wrapper.retryApiCallWithDelay(
      'https://example.test/auth/set-presence',
      HttpVerb.get,
      null,
      null,
    );

    expect(result.isError(), isTrue);
    expect(ApiCallWrapper.numberOfRetry, 0);
    expect(ApiCallWrapper.isTokenFreshApiCalling, isFalse);
  });
}

final class _AlwaysFailsHttp implements IHttp {
  _AlwaysFailsHttp(this.statusCode);

  final int statusCode;

  Never _fail(String url) {
    final RequestOptions options = RequestOptions(path: url);
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: statusCode,
      ),
    );
  }

  @override
  Future<dynamic> get({
    String? url,
    String? token,
    Map<dynamic, dynamic>? query,
    dynamic data,
  }) async => _fail(url ?? '');

  @override
  Future<dynamic> post({
    String? url,
    String? token,
    dynamic data,
    Map<dynamic, dynamic>? query,
  }) async => _fail(url ?? '');

  @override
  Future<dynamic> put({
    String? url,
    String? token,
    dynamic data,
    Map<dynamic, dynamic>? query,
  }) async => _fail(url ?? '');

  @override
  Future<dynamic> patch({
    String? url,
    String? token,
    dynamic data,
    Map<dynamic, dynamic>? query,
  }) async => _fail(url ?? '');

  @override
  Future<dynamic> delete({String? url, String? token, dynamic data}) async =>
      _fail(url ?? '');
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
