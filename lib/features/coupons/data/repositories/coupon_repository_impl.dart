import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/coupons/data/data_source/coupon_remote_data_source.dart';
import 'package:hamro_footsall/features/coupons/data/model/active_coupons_model.dart';
import 'package:hamro_footsall/features/coupons/data/model/applied_coupon_model.dart';
import 'package:hamro_footsall/features/coupons/domain/repository/coupon_repository.dart';

final class CouponRepositoryImpl extends CouponRepository {
  CouponRepositoryImpl({CouponRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? CouponRemoteDataSourceImpl();

  final CouponRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, ActiveCouponsModel>> getActiveCoupons() async {
    final response = await _remoteDataSource.getActiveCoupons();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(ActiveCouponsModel.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse coupons from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
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
  }) async {
    final response = await _remoteDataSource.applyCoupon(
      data: <String, dynamic>{
        'venue_id': venueId,
        'court_id': courtId,
        'booking_date': bookingDate,
        'start_time': startTime,
        'end_time': endTime,
        'coupon_code': couponCode,
        'repeat_weeks': repeatWeeks,
        'hold_token': holdToken,
      },
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(
        AppliedCouponModel.fromResponse(
          response.getValue(),
          fallbackCode: couponCode,
          fallbackOriginal: amount,
        ),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not apply the coupon. Please try again.',
          statusCode: 0,
        ),
      );
    }
  }
}
