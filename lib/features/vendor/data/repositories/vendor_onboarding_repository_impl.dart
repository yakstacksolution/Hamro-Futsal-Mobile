import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/vendor/data/data_source/vendor_onboarding_data_source.dart';
import 'package:hamro_footsall/features/vendor/data/model/court_onboarding_response_model.dart';
import 'package:hamro_footsall/features/vendor/data/model/vendor_onboarding_response_model.dart';
import 'package:hamro_footsall/features/vendor/domain/repository/vendor_onboarding_repository.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

final class VendorOnboardingRepositoryImpl
    implements VendorOnboardingRepository {
  VendorOnboardingRepositoryImpl({
    VendorOnboardingRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? VendorOnboardingRemoteDataSourceImpl();

  final VendorOnboardingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, VendorOnboardingResponseModel>>
  fetchVendorOnboardingFutsal(int venueId) async {
    final response = await _remoteDataSource.fetchVendorOnboardingFutsal(
      venueId,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final dynamic value = response.getValue();
    final Map<String, dynamic> data = _extractResponseData(value);
    return right(VendorOnboardingResponseModel.fromJson(data));
  }

  @override
  Future<Either<AppException, VendorOnboardingResponseModel>> submitFutsal(
    Map<String, dynamic> body,
  ) async {
    final response = await _remoteDataSource.submitFutsal(body);
    if (response.isError()) {
      return left(ResponseHelper.error(response.getErrorMsg()));
    }

    final dynamic value = response.getValue();
    final data = VendorOnboardingResponseModel.fromJson(
      _extractResponseData(value),
    );
    // final Map<String, dynamic> data = _extractResponseData(value);
    return right(data);
  }

  @override
  Future<Either<AppException, VendorOnboardingResponseModel>> updateFutsal(
    Map<String, dynamic> body,
  ) async {
    final response = await _remoteDataSource.updateFutsal(body);
    if (response.isError()) {
      return left(ResponseHelper.error(response.getErrorMsg()));
    }

    final dynamic value = response.getValue();
    final data = VendorOnboardingResponseModel.fromJson(
      _extractResponseData(value),
    );
    return right(data);
  }

  @override
  Future<Either<AppException, CourtOnboardingResponseModel>> submitCourt(
    Map<String, dynamic> body,
  ) async {
    final response = await _remoteDataSource.submitCourt(body);
    if (response.isError()) {
      return left(ResponseHelper.error(response.getErrorMsg()));
    }

    final dynamic value = response.getValue();
    final data = CourtOnboardingResponseModel.fromJson(
      _extractResponseData(value),
    );
    return right(data);
  }

  @override
  Future<Either<AppException, CourtOnboardingResponseModel>> updateCourt(
    Map<String, dynamic> body,
  ) async {
    final response = await _remoteDataSource.updateCourt(body);
    if (response.isError()) {
      return left(ResponseHelper.error(response.getErrorMsg()));
    }

    final dynamic value = response.getValue();
    final data = CourtOnboardingResponseModel.fromJson(
      _extractResponseData(value),
    );
    return right(data);
  }

  @override
  Future<Either<AppException, void>> deleteCourt(int courtId) async {
    final response = await _remoteDataSource.deleteCourt(courtId);
    if (response.isError()) {
      return left(ResponseHelper.error(response.getErrorMsg()));
    }
    return right(null);
  }

  @override
  Future<Either<AppException, List<CourtDraft>>> fetchCourtsByVenueId(
    int venueId,
  ) async {
    final response = await _remoteDataSource.fetchCourtsByVenueId(venueId);
    if (response.isError()) {
      return left(ResponseHelper.error(response.getErrorMsg()));
    }
    final List<CourtDraft> courts = VenueCourtModel.courtsFromResponse(
      response.getValue(),
    );
    return right(courts);
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
      errorMessage: StringConstants.invalidCreateFutsalResponseFromServer,
      statusCode: 0,
    );
  }
}
