import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/vendor/data/data_source/vendor_onboarding_data_source.dart';
import 'package:hamro_footsall/features/vendor/data/model/vendor_onboarding_response_model.dart';
import 'package:hamro_footsall/features/vendor/domain/repository/vendor_onboarding_repository.dart';

final class VendorOnboardingRepositoryImpl
    implements VendorOnboardingRepository {
  VendorOnboardingRepositoryImpl({
    VendorOnboardingRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? VendorOnboardingRemoteDataSourceImpl();

  final VendorOnboardingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, VendorOnboardingResponseModel>>
  fetchVendorOnboardingFutsal(int futsalId) async {
    final response = await _remoteDataSource.fetchVendorOnboardingFutsal(
      futsalId,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final dynamic value = response.getValue();
    final Map<String, dynamic> data = _extractResponseData(value);
    return right(VendorOnboardingResponseModel.fromJson(data));
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> submitFutsal(
    Map<String, dynamic> body,
  ) async {
    final response = await _remoteDataSource.submitFutsal(body);
    if (response.isError()) {
      return left(ResponseHelper.error(response.getErrorMsg()));
    }

    final dynamic value = response.getValue();
    final Map<String, dynamic> data = _extractResponseData(value);
    return right(data);
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
      errorMessage: 'Invalid create futsal response from server.',
      statusCode: 0,
    );
  }
}
