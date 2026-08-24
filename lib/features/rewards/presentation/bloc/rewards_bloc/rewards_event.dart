part of 'rewards_bloc.dart';

sealed class RewardsEvent extends Equatable {
  const RewardsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the reward wallet (`GET /customer/rewards`).
///
/// [isRefresh] keeps the current balance on screen while refetching, so a
/// pull-to-refresh does not flash the skeleton.
class LoadRewardsEvent extends RewardsEvent {
  const LoadRewardsEvent({this.isRefresh = false});

  final bool isRefresh;

  @override
  List<Object?> get props => <Object?>[isRefresh];
}

/// Loads the first page of history (`GET /customer/rewards/history`).
class LoadRewardHistoryEvent extends RewardsEvent {
  const LoadRewardHistoryEvent();
}

/// Appends the next history page.
class LoadMoreRewardHistoryEvent extends RewardsEvent {
  const LoadMoreRewardHistoryEvent();
}

/// Converts points into a coupon (`POST /customer/rewards/generate-coupon`).
///
/// [points] is forwarded only when redeeming a specific amount; null lets the
/// server apply its default conversion.
class GenerateRewardCouponEvent extends RewardsEvent {
  const GenerateRewardCouponEvent({this.points});

  final int? points;

  @override
  List<Object?> get props => <Object?>[points];
}

/// Dismisses the generated-coupon result.
class ClearGeneratedRewardCouponEvent extends RewardsEvent {
  const ClearGeneratedRewardCouponEvent();
}
