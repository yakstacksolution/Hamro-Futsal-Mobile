import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_footsall/features/rewards/domain/usecase/rewards_usecase.dart';

part 'rewards_event.dart';
part 'rewards_state.dart';

/// Owns the reward wallet, its paginated history and coupon generation.
///
/// Summary and history are tracked with separate statuses so a failing history
/// page never blanks out a balance that loaded fine.
class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  RewardsBloc(this._useCase, {int perPage = 20})
    : _perPage = perPage,
      super(const RewardsState()) {
    on<LoadRewardsEvent>(_onLoadRewards);
    on<LoadRewardHistoryEvent>(_onLoadHistory);
    on<LoadMoreRewardHistoryEvent>(_onLoadMoreHistory);
    on<GenerateRewardCouponEvent>(_onGenerateCoupon);
    on<ClearGeneratedRewardCouponEvent>(_onClearGeneratedCoupon);
  }

  final RewardsUseCase _useCase;
  final int _perPage;

  Future<void> _onLoadRewards(
    LoadRewardsEvent event,
    Emitter<RewardsState> emit,
  ) async {
    emit(
      state.copyWith(
        summaryStatus: state.summary == null || !event.isRefresh
            ? RewardsStatus.loading
            : state.summaryStatus,
        isRefreshing: event.isRefresh,
        clearError: true,
      ),
    );

    final Either<AppException, RewardsSummaryModel> response = await _useCase
        .getRewards();
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          summaryStatus: RewardsStatus.failure,
          isRefreshing: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (RewardsSummaryModel summary) => emit(
        state.copyWith(
          summaryStatus: RewardsStatus.success,
          summary: summary,
          isRefreshing: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadHistory(
    LoadRewardHistoryEvent event,
    Emitter<RewardsState> emit,
  ) async {
    emit(
      state.copyWith(
        historyStatus: RewardsStatus.loading,
        clearHistoryError: true,
      ),
    );

    final Either<AppException, RewardHistoryPageModel> response = await _useCase
        .getRewardHistory(page: 1, perPage: _perPage);
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          historyStatus: RewardsStatus.failure,
          historyErrorMessage: failure.errorMessage,
        ),
      ),
      (RewardHistoryPageModel page) => emit(
        state.copyWith(
          historyStatus: RewardsStatus.success,
          history: page.entries,
          historyPage: page.page,
          historyTotal: page.total,
          hasReachedMax: !page.hasMore,
          clearHistoryError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreRewardHistoryEvent event,
    Emitter<RewardsState> emit,
  ) async {
    // Ignore concurrent requests and end-of-list.
    if (state.isLoadingMoreHistory ||
        state.hasReachedMax ||
        state.historyStatus != RewardsStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMoreHistory: true, clearHistoryError: true));

    final Either<AppException, RewardHistoryPageModel> response = await _useCase
        .getRewardHistory(page: state.historyPage + 1, perPage: _perPage);
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          isLoadingMoreHistory: false,
          historyErrorMessage: failure.errorMessage,
        ),
      ),
      (RewardHistoryPageModel page) => emit(
        state.copyWith(
          history: <RewardHistoryEntryModel>[...state.history, ...page.entries],
          historyPage: page.page,
          historyTotal: page.total,
          hasReachedMax: !page.hasMore || page.entries.isEmpty,
          isLoadingMoreHistory: false,
          clearHistoryError: true,
        ),
      ),
    );
  }

  Future<void> _onGenerateCoupon(
    GenerateRewardCouponEvent event,
    Emitter<RewardsState> emit,
  ) async {
    if (state.isGenerating) return;

    emit(
      state.copyWith(
        isGenerating: true,
        generateStatus: RewardsStatus.loading,
        clearGeneratedCoupon: true,
        clearGenerateError: true,
      ),
    );

    final Either<AppException, GeneratedRewardCouponModel> response =
        await _useCase.generateCoupon(points: event.points);
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          isGenerating: false,
          generateStatus: RewardsStatus.failure,
          generateErrorMessage: failure.errorMessage,
        ),
      ),
      (GeneratedRewardCouponModel coupon) {
        // Redeeming changes the balance and adds a history row; reflect the new
        // balance immediately from the response when the server reports it, then
        // resync both from the server.
        final RewardsSummaryModel? summary = state.summary;
        emit(
          state.copyWith(
            isGenerating: false,
            generateStatus: RewardsStatus.success,
            generatedCoupon: coupon,
            summary: (summary != null && coupon.remainingPoints != null)
                ? RewardsSummaryModel(
                    availablePoints: coupon.remainingPoints!,
                    totalEarnedPoints: summary.totalEarnedPoints,
                    totalRedeemedPoints:
                        summary.totalRedeemedPoints + coupon.pointsUsed,
                    pointsPerCoupon: summary.pointsPerCoupon,
                    couponValue: summary.couponValue,
                    tier: summary.tier,
                    currency: summary.currency,
                    expiringPoints: summary.expiringPoints,
                    expiresAt: summary.expiresAt,
                    canGenerateCoupon: null,
                    note: summary.note,
                  )
                : summary,
            clearGenerateError: true,
          ),
        );
        add(const LoadRewardsEvent(isRefresh: true));
        add(const LoadRewardHistoryEvent());
      },
    );
  }

  void _onClearGeneratedCoupon(
    ClearGeneratedRewardCouponEvent event,
    Emitter<RewardsState> emit,
  ) {
    emit(
      state.copyWith(
        clearGeneratedCoupon: true,
        clearGenerateError: true,
        generateStatus: RewardsStatus.idle,
      ),
    );
  }
}
