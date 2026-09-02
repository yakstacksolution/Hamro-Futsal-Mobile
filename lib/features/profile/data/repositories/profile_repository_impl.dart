import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/security/biometric_session_store.dart';
import 'package:hamro_futsal/core/socket/reverb_connection.dart';
import 'package:hamro_futsal/features/profile/data/data_source/profile_data_source.dart';
import 'package:hamro_futsal/features/profile/data/model/profile_model.dart';
import 'package:hamro_futsal/features/profile/domain/repository/profile_repository.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

final class ProfileRepositoryImpl extends ProfileRepository {
  ProfileRepositoryImpl({ProfileRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ProfileDataSourceImpl();

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, ProfileModel>> getProfile() async {
    final response = await _remoteDataSource.getProfile();
    return _toProfileResult(response);
  }

  @override
  Future<Either<AppException, String>> requestVendorUpgrade(
    Map<String, dynamic> data,
  ) async {
    final Result response = await _remoteDataSource.requestVendorUpgrade(data);
    if (response.isError()) return left(ResponseHelper.error(response));

    final dynamic payload = response.getValue();
    final String message = payload is Map
        ? payload['message']?.toString().trim() ?? ''
        : '';
    return right(
      message.isNotEmpty ? message : StringConstants.vendorRequestSubmitted,
    );
  }

  @override
  Future<Either<AppException, ProfileModel>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updateProfile(data);
    return _toProfileResult(response);
  }

  @override
  Future<Either<AppException, bool>> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final response = await _remoteDataSource.updateNotificationPreferences(
      preferences.toJson(),
    );
    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      // A 204 No Content reply still means the preferences were saved.
      if (error.statusCode != 204) return left(error);
    }
    return right(true);
  }

  @override
  Future<Either<AppException, bool>> deleteAccount({
    required String reason,
  }) async {
    final Result response = await _remoteDataSource.deleteAccount(
      <String, dynamic>{'reason': reason.trim()},
    );
    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      // 204 No Content is a successful delete with nothing to return.
      if (error.statusCode != 204) return left(error);
    }

    // The account is gone: drop the token, the biometric session that could
    // sign back in with it, and the socket bound to the old identity.
    AppSettings().logout();
    await BiometricSessionStore().clear();
    AppSettings().biometricLogin = false;
    await ReverbConnection.instance.reset();
    return right(true);
  }

  Either<AppException, ProfileModel> _toProfileResult(Result response) {
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final dynamic payload = response.getValue();
    final Map<String, dynamic> data = _extractResponseData(payload);
    return right(ProfileModel.fromJson(data));
  }

  Map<String, dynamic> _extractResponseData(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      return map;
    }

    throw DefaultException(
      errorMessage: StringConstants.invalidProfileResponseFromServer,
      statusCode: 0,
    );
  }
}
