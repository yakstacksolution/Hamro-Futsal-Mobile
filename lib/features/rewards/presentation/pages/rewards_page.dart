import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/app_message_view.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_futsal/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:hamro_futsal/features/rewards/domain/usecase/rewards_usecase.dart';
import 'package:hamro_futsal/features/rewards/presentation/bloc/rewards_bloc/rewards_bloc.dart';
import 'package:hamro_futsal/features/rewards/presentation/pages/reward_history_page.dart';
import 'package:hamro_futsal/features/rewards/presentation/widgets/generated_coupon_sheet.dart';
import 'package:hamro_futsal/features/rewards/presentation/widgets/rewards_loading_widgets.dart';
import 'package:hamro_futsal/features/rewards/presentation/widgets/rewards_widgets.dart';

/// How many history rows the rewards page previews before "View all activity".
const int _kRecentHistoryCount = 4;

/// Reward wallet screen: balance, lifetime stats, redemption and a preview of
/// the latest point movements.
class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RewardsBloc>(
      create: (_) => RewardsBloc(RewardsUseCase(RewardsRepositoryImpl()))
        ..add(const LoadRewardsEvent())
        ..add(const LoadRewardHistoryEvent()),
      child: const RewardsView(),
    );
  }
}

/// The rewards body, split out so it can be rendered against an injected
/// [RewardsBloc] (the screen itself fetches on create).
@visibleForTesting
class RewardsView extends StatelessWidget {
  const RewardsView({super.key});

  Future<void> _refresh(BuildContext context) async {
    final RewardsBloc bloc = context.read<RewardsBloc>();
    bloc
      ..add(const LoadRewardsEvent(isRefresh: true))
      ..add(const LoadRewardHistoryEvent());
    // Let the indicator settle with the request rather than snapping back.
    await bloc.stream.firstWhere((RewardsState state) => !state.isRefreshing);
  }

  void _openHistory(BuildContext context) {
    final RewardsBloc bloc = context.read<RewardsBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<RewardsBloc>.value(
          value: bloc,
          child: const RewardHistoryPage(),
        ),
      ),
    );
  }

  Future<void> _showGeneratedCoupon(
    BuildContext context,
    GeneratedRewardCouponModel coupon,
  ) async {
    await showAppBottomSheet<void>(
      context: context,
      builder: (_) => GeneratedCouponSheet(coupon: coupon),
    );
    if (!context.mounted) return;
    context.read<RewardsBloc>().add(const ClearGeneratedRewardCouponEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.rewards),
      body: SafeArea(
        top: false,
        child: BlocConsumer<RewardsBloc, RewardsState>(
          listenWhen: (RewardsState previous, RewardsState current) =>
              previous.generateStatus != current.generateStatus,
          listener: (BuildContext context, RewardsState state) {
            if (state.generateStatus == RewardsStatus.success &&
                state.generatedCoupon != null) {
              _showGeneratedCoupon(context, state.generatedCoupon!);
            } else if (state.generateStatus == RewardsStatus.failure) {
              AppUtils().showSnackBar(
                context,
                MsgType.error,
                state.generateErrorMessage ??
                    StringConstants.couldNotGenerateRewardCoupon,
              );
            }
          },
          builder: (BuildContext context, RewardsState state) {
            if (state.isInitialLoading) return const RewardsLoadingView();

            if (state.isSummaryFailure) {
              return AppMessageView(
                icon: Icons.workspace_premium_outlined,
                title: StringConstants.couldNotLoadRewards,
                message:
                    state.errorMessage ?? StringConstants.couldNotLoadRewards,
                actionLabel: StringConstants.retry,
                onAction: () =>
                    context.read<RewardsBloc>().add(const LoadRewardsEvent()),
              );
            }

            final RewardsSummaryModel summary = state.wallet;
            final List<RewardHistoryEntryModel> recent = state.history
                .take(_kRecentHistoryCount)
                .toList(growable: false);

            final double horizontal = context.responsive<double>(
              mobile: AppDimens.paddingX20,
              tablet: AppDimens.paddingX32,
            );

            return RefreshIndicator(
              color: LightColor.secondaryColor,
              onRefresh: () => _refresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppDimens.paddingX16,
                  horizontal,
                  AppDimens.paddingX40,
                ),
                children: <Widget>[
                  RewardBalanceCard(
                    summary: summary,
                    isRedeeming: state.isGenerating,
                    onRedeem: () => context.read<RewardsBloc>().add(
                      const GenerateRewardCouponEvent(),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX12),
                  RewardStatsRow(summary: summary),
                  const SizedBox(height: AppDimens.paddingX12),
                  RewardExpiryNotice(summary: summary),
                  const SizedBox(height: AppDimens.paddingX4),
                  RewardHowItWorksCard(summary: summary),
                  const SizedBox(height: AppDimens.paddingX20),
                  RewardSectionHeader(
                    title: StringConstants.recentRewardActivity,
                    actionLabel: state.history.length > recent.length
                        ? StringConstants.viewAllRewardHistory
                        : null,
                    onAction: () => _openHistory(context),
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  _RecentHistory(state: state, entries: recent),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The history preview: skeleton, empty state, error retry or the list itself.
class _RecentHistory extends StatelessWidget {
  const _RecentHistory({required this.state, required this.entries});

  final RewardsState state;
  final List<RewardHistoryEntryModel> entries;

  @override
  Widget build(BuildContext context) {
    if (state.isHistoryInitialLoading) {
      return const RewardHistoryLoadingList(
        itemCount: _kRecentHistoryCount,
        wrapWithShimmer: true,
      );
    }

    if (entries.isEmpty) {
      return _HistoryPlaceholder(
        icon: state.historyStatus == RewardsStatus.failure
            ? Icons.wifi_off_rounded
            : Icons.history_rounded,
        title: state.historyStatus == RewardsStatus.failure
            ? StringConstants.couldNotLoadRewardHistory
            : StringConstants.noRewardHistory,
        message:
            state.historyErrorMessage ?? StringConstants.noRewardHistoryMessage,
        onRetry: state.historyStatus == RewardsStatus.failure
            ? () => context.read<RewardsBloc>().add(
                const LoadRewardHistoryEvent(),
              )
            : null,
      );
    }

    return RewardHistoryCard(entries: entries);
  }
}

class _HistoryPlaceholder extends StatelessWidget {
  const _HistoryPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: AppMessageView(
        icon: icon,
        title: title,
        message: message,
        actionLabel: onRetry == null ? null : StringConstants.retry,
        onAction: onRetry,
      ),
    );
  }
}
