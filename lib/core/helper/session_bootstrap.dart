import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/api/api_client/api_constants.dart';
import 'package:hamro_futsal/core/api/api_client/dio_http.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/features/auth/data/model/token_model.dart';

class SessionBootstrap {
  SessionBootstrap._();

  static const Duration _timeout = Duration(seconds: 4);

  static Future<bool> resolve() async {
    if (!AppSettings().hasSession) return false;

    final String refreshToken =
        AppSettings().tokenModel.refreshToken?.trim() ?? '';
    if (refreshToken.isEmpty) {
      // Nothing to renew with: the moment this access token is rejected there
      // is no way back, so treat it as expired now rather than on the
      // dashboard's first request.
      AppSettings().logout();
      return false;
    }

    try {
      final dynamic response = await DioHttp()
          .post(
            url: '${APIEndpoint.baseUrl}/auth/refresh-token',
            data: <String, dynamic>{'refresh_token': refreshToken},
          )
          .timeout(_timeout);

      final TokenModel refreshed = _parseRefreshedToken(
        await response.data,
        fallbackRefreshToken: refreshToken,
      );
      if ((refreshed.accessToken?.trim() ?? '').isEmpty) {
        AppSettings().logout();
        return false;
      }

      AppSettings().token = refreshed;
      return true;
    } on DioException catch (error) {
      final int status = error.response?.statusCode ?? 0;
      if (_isRejection(status)) {
        AppSettings().logout();
        return false;
      }
      debugPrint(
        'Session validation skipped (${error.type}): ${error.message}',
      );
      return true;
    } on TimeoutException {
      debugPrint('Session validation timed out — keeping the stored session.');
      return true;
    } catch (error, stack) {
      debugPrint('Session validation failed: $error\n$stack');
      return true;
    }
  }

  static bool _isRejection(int status) =>
      status == 400 || status == 401 || status == 403 || status == 422;

  static TokenModel _parseRefreshedToken(
    dynamic payload, {
    required String fallbackRefreshToken,
  }) {
    Map<String, dynamic> data = <String, dynamic>{};
    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      final dynamic inner = map['data'];
      data = inner is Map ? Map<String, dynamic>.from(inner) : map;
    }

    final dynamic expires = data['expires_in'] ?? data['expired_in'];
    final String? rotated = data['refresh_token'] as String?;
    return TokenModel(
      tokenType: data['token_type'] as String?,
      expiredIn: expires is int
          ? expires
          : int.tryParse(expires?.toString() ?? ''),
      accessToken: (data['access_token'] ?? data['token']) as String?,
      // Some responses only rotate the access token; dropping the refresh
      // token here would strand the next cold start.
      refreshToken: (rotated?.trim().isNotEmpty ?? false)
          ? rotated
          : fallbackRefreshToken,
    );
  }
}
