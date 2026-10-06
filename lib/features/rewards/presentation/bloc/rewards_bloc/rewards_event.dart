part of 'rewards_bloc.dart';

sealed class RewardsEvent extends Equatable {
  const RewardsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadRewardsEvent extends RewardsEvent {
  const LoadRewardsEvent({this.isRefresh = false});

  final bool isRefresh;

  @override
  List<Object?> get props => <Object?>[isRefresh];
}

class LoadRewardHistoryEvent extends RewardsEvent {
  const LoadRewardHistoryEvent();
}

class LoadMoreRewardHistoryEvent extends RewardsEvent {
  const LoadMoreRewardHistoryEvent();
}

class GenerateRewardCouponEvent extends RewardsEvent {
  const GenerateRewardCouponEvent({this.points});

  final int? points;

  @override
  List<Object?> get props => <Object?>[points];
}

class ClearGeneratedRewardCouponEvent extends RewardsEvent {
  const ClearGeneratedRewardCouponEvent();
}
