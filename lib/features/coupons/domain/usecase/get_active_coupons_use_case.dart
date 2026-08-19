import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/coupons/data/model/active_coupons_model.dart';
import 'package:hamro_footsall/features/coupons/domain/repository/coupon_repository.dart';

final class GetActiveCouponsUseCase {
  const GetActiveCouponsUseCase(this.repository);

  final CouponRepository repository;

  Future<Either<AppException, ActiveCouponsModel>> getActiveCoupons() async =>
      await repository.getActiveCoupons();
}
