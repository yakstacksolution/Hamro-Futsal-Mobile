import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/socket/reverb_connection.dart';
import 'package:hamro_footsall/core/security/biometric_session_store.dart';
import 'package:hamro_footsall/features/auth/data/data_source/authentication_data_source.dart';
import 'package:hamro_footsall/features/auth/data/model/token_model.dart';
import 'package:hamro_footsall/features/auth/domain/repository/authentication_repository.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

final class AuthenticationRepositoryImpl extends AuthRepository {
  AuthenticationRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AuthenticationDataSourceImpl();

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, bool>> changePassword(data) async {
    final response = await _remoteDataSource.changePassword(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(true);
  }

  @override
  Future<bool> clearTokenDetails() async {
    AppSettings().logout();
    await ReverbConnection.instance.reset();
    return true;
  }

  @override
  Future<Either<AppException, bool>> forgotPassword(data) async {
    final response = await _remoteDataSource.forgotPassword(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(true);
  }

  @override
  Future<Either<AppException, TokenModel>> getTokenDetails() async {
    try {
      return right(AppSettings().tokenModel);
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotLoadSavedAuthenticationDetails,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, TokenModel>> signIn(data) async {
    final response = await _remoteDataSource.signIn(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final TokenModel tokenModel = _parseTokenModel(response.getValue());
    AppSettings().token = tokenModel;
    if (AppSettings().biometricLogin) {
      await BiometricSessionStore().save(tokenModel);
    }
    return right(tokenModel);
  }

  @override
  Future<Either<AppException, TokenModel>> signInWithGoogle(data) async {
    final response = await _remoteDataSource.signInWithGoogle(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final TokenModel tokenModel = _parseTokenModel(response.getValue());
    AppSettings().token = tokenModel;
    if (AppSettings().biometricLogin) {
      await BiometricSessionStore().save(tokenModel);
    }
    return right(tokenModel);
  }

  @override
  Future<Either<AppException, TokenModel>> signUp(data) async {
    final response = await _remoteDataSource.signUp(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final Map<String, dynamic> responseData = _extractResponseData(
      response.getValue(),
    );
    final TokenModel tokenModel = _parseTokenModel(response.getValue());
    if (_containsTokenData(responseData)) {
      AppSettings().token = tokenModel;
    }
    return right(tokenModel);
  }

  TokenModel _parseTokenModel(dynamic payload) {
    final Map<String, dynamic> data = _extractResponseData(payload);
    return TokenModel(
      tokenType: data['token_type'] as String?,
      expiredIn: (data['expires_in'] ?? data['expired_in']) is int
          ? (data['expires_in'] ?? data['expired_in']) as int?
          : int.tryParse(
              (data['expires_in'] ?? data['expired_in'])?.toString() ?? '',
            ),
      accessToken: (data['access_token'] ?? data['token']) as String?,
      refreshToken: data['refresh_token'] as String?,
    );
  }

  Map<String, dynamic> _extractResponseData(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final dynamic data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return payload;
    }

    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      final dynamic data = map['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return map;
    }

    throw DefaultException(
      errorMessage: StringConstants.invalidAuthenticationResponseFromServer,
      statusCode: 0,
    );
  }

  bool _containsTokenData(Map<String, dynamic> data) {
    return (data['access_token'] ?? data['token']) != null;
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>>? verifyOtp(data) async {
    final response = await _remoteDataSource.verifyOtp(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final Map<String, dynamic> responseData = _extractResponseData(
      response.getValue(),
    );
    if (_containsTokenData(responseData)) {
      AppSettings().token = _parseTokenModel(response.getValue());
    }
    return right(responseData);
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>>? resendOtp(data) async {
    final response = await _remoteDataSource.resendOtp(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final Map<String, dynamic> responseData = _extractResponseData(
      response.getValue(),
    );
    return right(responseData);
  }

  @override
  Future<Either<AppException, bool>>? logout() async {
    // Report offline while the token is still valid — screens that own the
    // presence lifecycle are disposed after the session is cleared, so their
    // trailing offline call would otherwise 401.
    await _markOffline();

    // With biometric login enabled, logout locks the local account instead of
    // revoking the encrypted session needed for the next biometric sign-in.
    // Disabling biometric login first performs a full server logout.
    if (AppSettings().biometricLogin &&
        await BiometricSessionStore().hasSession) {
      AppSettings().logout();
      await ReverbConnection.instance.reset();
      return right(true);
    }

    final response = await _remoteDataSource.logout();

    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      if (error.statusCode != 401 && error.statusCode != 403) {
        return left(error);
      }
    }

    AppSettings().logout();
    await ReverbConnection.instance.reset();
    return right(true);
  }

  /// Best-effort presence teardown; a failure here must not block logout.
  Future<void> _markOffline() async {
    try {
      await Client.instance().getAuthManager().setPresence(false);
    } catch (_) {
      // Ignored: logout proceeds regardless of the presence result.
    }
  }
}
