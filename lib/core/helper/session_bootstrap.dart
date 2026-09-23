import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/api/api_client/api_constants.dart';
import 'package:hamro_futsal/core/api/api_client/dio_http.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/features/auth/data/model/token_model.dart';

/// Decides, before the first frame, whether the stored session is real.
///
/// A token sitting in preferences only means "somebody signed in on this
/// device once" — it says nothing about whether the server still honours it.
/// Trusting it opened the dashboard for people who were effectively signed
/// out: every authenticated request came back 401, the first one to be
/// answered triggered a refresh, the refresh failed, and the app bounced back
/// to login. This resolves that question once, while the native splash is
/// still covering the screen, so the first screen the user sees is the right
/// one.
class SessionBootstrap {
  SessionBootstrap._();

  /// How long a cold start may wait on the network before giving up on
  /// validation. Short enough not to feel like a hang on a slow connection.
  static const Duration _timeout = Duration(seconds: 4);

  /// True when the app should start on the dashboard.
  ///
  /// A token the server rejects is cleared here, so the rest of the app never
  /// sees it. A validation that fails for any other reason (offline, DNS,
  /// server down) keeps the stored session: being unreachable is not proof of
  /// being signed out, and forcing a login the user cannot complete offline
  /// would be worse than letting them in on cached data.
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

  /// The server's ways of saying "this session is gone". Anything else is a
  /// transport or server-side problem and must not sign the user out.
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
