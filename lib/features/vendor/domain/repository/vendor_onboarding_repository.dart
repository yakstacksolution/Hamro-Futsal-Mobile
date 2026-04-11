import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/vendor/data/model/vendor_onboarding_response_model.dart';

abstract class VendorOnboardingRepository {
  Future<Either<AppException, VendorOnboardingResponseModel>>
  fetchVendorOnboardingFutsal(int futsalId);

  Future<Either<AppException, Map<String, dynamic>>> submitFutsal(
    Map<String, dynamic> body,
  );
}
