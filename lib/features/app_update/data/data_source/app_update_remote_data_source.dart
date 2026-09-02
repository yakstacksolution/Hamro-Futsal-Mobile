import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';

abstract class AppUpdateRemoteDataSource {
  /// The app's own release manifest, served by our backend.
  Future<Result> getAppVersion({required Map<String, dynamic> query});

  /// App Store fallback for iOS — the public iTunes Lookup API. Returns the
  /// raw lookup payload.
  Future<Result> lookupAppStore({required String bundleId, String? country});
}

final class AppUpdateRemoteDataSourceImpl extends AppUpdateRemoteDataSource {
  AppUpdateRemoteDataSourceImpl({Dio? storeClient})
    : _storeClient =
          storeClient ??
          Dio(
            BaseOptions(
              // The update check must never delay app launch noticeably: fail
              // fast and fall through to the next source.
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 6),
              responseType: ResponseType.json,
            ),
          );

  final Dio _storeClient;

  static const String _appStoreLookupUrl = 'https://itunes.apple.com/lookup';

  @override
  Future<Result> getAppVersion({required Map<String, dynamic> query}) async =>
      await Client.instance().getAuthManager().getAppVersion(query);

  @override
  Future<Result> lookupAppStore({
    required String bundleId,
    String? country,
  }) async {
    try {
      final Response<dynamic> response = await _storeClient.get<dynamic>(
        _appStoreLookupUrl,
        queryParameters: <String, dynamic>{
          'bundleId': bundleId,
          if (country != null && country.trim().isNotEmpty)
            'country': country.trim(),
          'nocache': DateTime.now().millisecondsSinceEpoch,
        },
      );
      if (response.data == null) {
        return Result.error(
          DataError('Empty App Store lookup response', 0, null),
        );
      }
      return Result.success(response.data);
    } on DioException catch (error) {
      return Result.error(
        DataError(
          error.message ?? 'App Store lookup failed',
          error.response?.statusCode ?? 0,
          error.response?.data,
        ),
      );
    } catch (error) {
      return Result.error(
        DataError(
          error is SocketException ? 'No internet connection' : '$error',
          0,
          null,
        ),
      );
    }
  }
}
