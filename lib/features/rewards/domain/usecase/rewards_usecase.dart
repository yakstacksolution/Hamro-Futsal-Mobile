import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_footsall/features/rewards/domain/repository/rewards_repository.dart';

final class RewardsUseCase {
  const RewardsUseCase(this.repository);

  final RewardsRepository repository;

  Future<Either<AppException, RewardsSummaryModel>> getRewards() =>
      repository.getRewards();

  Future<Either<AppException, RewardHistoryPageModel>> getRewardHistory({
    int page = 1,
    int perPage = 20,
  }) => repository.getRewardHistory(page: page, perPage: perPage);

  Future<Either<AppException, GeneratedRewardCouponModel>> generateCoupon({
    int? points,
  }) => repository.generateCoupon(points: points);
}
