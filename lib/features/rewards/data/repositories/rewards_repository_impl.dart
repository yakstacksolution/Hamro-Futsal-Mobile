import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/rewards/data/data_source/rewards_remote_data_source.dart';
import 'package:hamro_futsal/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_futsal/features/rewards/domain/repository/rewards_repository.dart';

final class RewardsRepositoryImpl extends RewardsRepository {
  RewardsRepositoryImpl({RewardsRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? RewardsRemoteDataSourceImpl();

  final RewardsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, RewardsSummaryModel>> getRewards() async {
    final Result response = await _remoteDataSource.getRewards();
    if (response.isError()) return left(ResponseHelper.error(response));

    try {
      return right(RewardsSummaryModel.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotLoadRewards,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, RewardHistoryPageModel>> getRewardHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    final Result response = await _remoteDataSource.getRewardHistory(
      page: page,
      perPage: perPage,
    );
    if (response.isError()) return left(ResponseHelper.error(response));

    try {
      return right(RewardHistoryPageModel.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotLoadRewardHistory,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, GeneratedRewardCouponModel>> generateCoupon({
    int? points,
  }) async {
    final Result response = await _remoteDataSource.generateRewardCoupon(
      data: points == null ? null : <String, dynamic>{'points': points},
    );
    if (response.isError()) return left(ResponseHelper.error(response));

    try {
      final GeneratedRewardCouponModel coupon =
          GeneratedRewardCouponModel.fromResponse(response.getValue());

      // A 200 without a code means nothing usable was issued — surface it as a
      // failure so the UI never shows an empty coupon sheet.
      if (!coupon.hasCode) {
        return left(
          DefaultException(
            errorMessage: coupon.message.isNotEmpty
                ? coupon.message
                : StringConstants.couldNotGenerateRewardCoupon,
            statusCode: 0,
          ),
        );
      }
      return right(coupon);
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotGenerateRewardCoupon,
          statusCode: 0,
        ),
      );
    }
  }
}
