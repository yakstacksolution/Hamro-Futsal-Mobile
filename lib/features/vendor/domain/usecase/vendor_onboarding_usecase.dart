import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/vendor/domain/repository/vendor_onboarding_repository.dart';

final class VendorOnboardingUseCase {
  const VendorOnboardingUseCase(this._repository);

  final VendorOnboardingRepository _repository;

  Future<Either<AppException, Map<String, dynamic>>> submitFutsal(
    Map<String, dynamic> body,
  ) async => await _repository.submitFutsal(body);
}

