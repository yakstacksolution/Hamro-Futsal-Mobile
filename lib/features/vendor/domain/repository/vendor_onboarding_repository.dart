import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';

abstract class VendorOnboardingRepository {
  Future<Either<AppException, Map<String, dynamic>>> submitFutsal(
    Map<String, dynamic> body,
  );
}

