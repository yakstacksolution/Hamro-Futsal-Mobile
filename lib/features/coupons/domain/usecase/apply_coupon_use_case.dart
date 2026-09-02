import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/coupons/data/model/applied_coupon_model.dart';
import 'package:hamro_futsal/features/coupons/domain/repository/coupon_repository.dart';

final class ApplyCouponUseCase {
  const ApplyCouponUseCase(this.repository);

  final CouponRepository repository;

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
  }) async => await repository.applyCoupon(
    couponCode: couponCode,
    venueId: venueId,
    courtId: courtId,
    bookingDate: bookingDate,
    startTime: startTime,
    endTime: endTime,
    repeatWeeks: repeatWeeks,
    holdToken: holdToken,
    amount: amount,
  );
}
