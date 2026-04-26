import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/vendor/data/model/vendor_onboarding_response_model.dart';
import 'package:hamro_footsall/features/vendor/domain/repository/vendor_onboarding_repository.dart';

final class VendorOnboardingUseCase {
  const VendorOnboardingUseCase(this._repository);

  final VendorOnboardingRepository _repository;

  Future<Either<AppException, VendorOnboardingResponseModel>>
  fetchVendorOnboardingFutsal(int futsalId) async =>
      await _repository.fetchVendorOnboardingFutsal(futsalId);

  Future<Either<AppException, VendorOnboardingResponseModel>> submitFutsal(
    Map<String, dynamic> body,
  ) async => await _repository.submitFutsal(body);

  Future<Either<AppException, VendorOnboardingResponseModel>> updateFutsal(
    Map<String, dynamic> body,
  ) async => await _repository.updateFutsal(body);
}
