import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class RewardsRemoteDataSource {
  Future<Result> getRewards();

  Future<Result> getRewardHistory({required int page, required int perPage});

  Future<Result> generateRewardCoupon({Map<String, dynamic>? data});
}

final class RewardsRemoteDataSourceImpl extends RewardsRemoteDataSource {
  @override
  Future<Result> getRewards() async =>
      await Client.instance().getAuthManager().getRewards();

  @override
  Future<Result> getRewardHistory({
    required int page,
    required int perPage,
  }) async => await Client.instance().getAuthManager().getRewardHistory(
    page: page,
    perPage: perPage,
  );

  @override
  Future<Result> generateRewardCoupon({Map<String, dynamic>? data}) async =>
      await Client.instance().getAuthManager().generateRewardCoupon(data: data);
}
