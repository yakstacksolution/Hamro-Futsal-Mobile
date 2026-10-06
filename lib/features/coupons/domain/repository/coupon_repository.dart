import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/coupons/data/model/active_coupons_model.dart';
import 'package:hamro_futsal/features/coupons/data/model/applied_coupon_model.dart';

abstract class CouponRepository {
  Future<Either<AppException, ActiveCouponsModel>> getActiveCoupons();

  Future<Either<AppException, AppliedCouponModel>> applyCoupon({
    required String couponCode,
    required int? venueId,
    required int? courtId,
    required String bookingDate,
    required String startTime,
    String? endTime,
    int? repeatWeeks,

    String? holdToken,

    required double amount,
  });
}
