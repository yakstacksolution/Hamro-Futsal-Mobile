import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/vendor/data/model/court_onboarding_response_model.dart';
import 'package:hamro_futsal/features/vendor/data/model/vendor_onboarding_response_model.dart';
import 'package:hamro_futsal/features/vendor/domain/repository/vendor_onboarding_repository.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

final class VendorOnboardingUseCase {
  const VendorOnboardingUseCase(this._repository);

  final VendorOnboardingRepository _repository;

  Future<Either<AppException, VendorOnboardingResponseModel>>
  fetchVendorOnboardingFutsal(int venueId) async =>
      await _repository.fetchVendorOnboardingFutsal(venueId);

  Future<Either<AppException, VendorOnboardingResponseModel>> submitFutsal(
    Map<String, dynamic> body,
  ) async => await _repository.submitFutsal(body);

  Future<Either<AppException, VendorOnboardingResponseModel>> updateFutsal(
    Map<String, dynamic> body,
  ) async => await _repository.updateFutsal(body);

  Future<Either<AppException, CourtOnboardingResponseModel>> submitCourt(
    Map<String, dynamic> body,
  ) async => await _repository.submitCourt(body);

  Future<Either<AppException, CourtOnboardingResponseModel>> updateCourt(
    Map<String, dynamic> body,
  ) async => await _repository.updateCourt(body);

  Future<Either<AppException, void>> deleteCourt(int courtId) async =>
      await _repository.deleteCourt(courtId);

  Future<Either<AppException, List<CourtDraft>>> fetchCourtsByVenueId(
    int venueId,
  ) async => await _repository.fetchCourtsByVenueId(venueId);
}
