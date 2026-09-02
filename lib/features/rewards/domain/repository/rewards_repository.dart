import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/rewards/data/model/rewards_model.dart';

abstract class RewardsRepository {
  /// `GET /customer/rewards` — the reward wallet.
  Future<Either<AppException, RewardsSummaryModel>> getRewards();

  /// `GET /customer/rewards/history` — one page of point movements.
  Future<Either<AppException, RewardHistoryPageModel>> getRewardHistory({
    int page,
    int perPage,
  });

  /// `POST /customer/rewards/generate-coupon` — converts points into a coupon.
  ///
  /// [points] is sent only when the caller redeems a specific amount; when it is
  /// null the server applies its own default conversion.
  Future<Either<AppException, GeneratedRewardCouponModel>> generateCoupon({
    int? points,
  });
}
