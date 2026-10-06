import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/rewards/data/model/rewards_model.dart';

abstract class RewardsRepository {
  Future<Either<AppException, RewardsSummaryModel>> getRewards();

  Future<Either<AppException, RewardHistoryPageModel>> getRewardHistory({
    int page,
    int perPage,
  });

  Future<Either<AppException, GeneratedRewardCouponModel>> generateCoupon({
    int? points,
  });
}
