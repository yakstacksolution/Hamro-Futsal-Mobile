import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/vendor/data/model/court_onboarding_response_model.dart';
import 'package:hamro_futsal/features/vendor/data/model/vendor_onboarding_response_model.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

abstract class VendorOnboardingRepository {
  Future<Either<AppException, VendorOnboardingResponseModel>>
  fetchVendorOnboardingFutsal(int futsalId);

  Future<Either<AppException, List<CourtDraft>>> fetchCourtsByVenueId(
    int venueId,
  );

  Future<Either<AppException, VendorOnboardingResponseModel>> submitFutsal(
    Map<String, dynamic> body,
  );

  Future<Either<AppException, VendorOnboardingResponseModel>> updateFutsal(
    Map<String, dynamic> body,
  );

  Future<Either<AppException, CourtOnboardingResponseModel>> submitCourt(
    Map<String, dynamic> body,
  );

  Future<Either<AppException, CourtOnboardingResponseModel>> updateCourt(
    Map<String, dynamic> body,
  );

  Future<Either<AppException, void>> deleteCourt(int courtId);
}
