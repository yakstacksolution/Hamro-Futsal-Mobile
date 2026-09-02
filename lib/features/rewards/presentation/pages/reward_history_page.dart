import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/app_message_view.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:hamro_futsal/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_futsal/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:hamro_futsal/features/rewards/domain/usecase/rewards_usecase.dart';
import 'package:hamro_futsal/features/rewards/presentation/bloc/rewards_bloc/rewards_bloc.dart';
import 'package:hamro_futsal/features/rewards/presentation/widgets/rewards_loading_widgets.dart';
import 'package:hamro_futsal/features/rewards/presentation/widgets/rewards_widgets.dart';

/// Full, infinitely scrolling reward history (`per_page=20`).
///
/// Reuses the [RewardsBloc] pushed from the rewards page when one is available;
/// [RewardHistoryPage.standalone] creates its own for deep links.
class RewardHistoryPage extends StatefulWidget {
  const RewardHistoryPage({super.key});

  /// Self-contained variant that owns its bloc and fetches the first page.
  static Widget standalone() => BlocProvider<RewardsBloc>(
    create: (_) =>
        RewardsBloc(RewardsUseCase(RewardsRepositoryImpl()))
          ..add(const LoadRewardHistoryEvent()),
    child: const RewardHistoryPage(),
  );

  @override
  State<RewardHistoryPage> createState() => _RewardHistoryPageState();
}

class _RewardHistoryPageState extends State<RewardHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  /// Distance from the bottom at which the next page is requested.
  static const double _loadMoreThreshold = 240;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Deep-linked or first-time entry: make sure a first page is in flight.
    final RewardsBloc bloc = context.read<RewardsBloc>();
    if (bloc.state.history.isEmpty &&
        bloc.state.historyStatus != RewardsStatus.loading) {
      bloc.add(const LoadRewardHistoryEvent());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double remaining =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining <= _loadMoreThreshold) {
      // The bloc ignores the event while a page is in flight or the list ended.
      context.read<RewardsBloc>().add(const LoadMoreRewardHistoryEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double horizontal = context.responsive<double>(
      mobile: AppDimens.paddingX20,
      tablet: AppDimens.paddingX32,
    );

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.rewardHistory),
      body: SafeArea(
        top: false,
        child: BlocBuilder<RewardsBloc, RewardsState>(
          builder: (BuildContext context, RewardsState state) {
            if (state.isHistoryInitialLoading) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppDimens.paddingX16,
                  horizontal,
                  0,
                ),
                child: const RewardHistoryLoadingList(wrapWithShimmer: true),
              );
            }

            if (state.history.isEmpty) {
              final bool failed = state.historyStatus == RewardsStatus.failure;
              return AppMessageView(
                icon: failed ? Icons.wifi_off_rounded : Icons.history_rounded,
                title: failed
                    ? StringConstants.couldNotLoadRewardHistory
                    : StringConstants.noRewardHistory,
                message: failed
                    ? (state.historyErrorMessage ??
                          StringConstants.couldNotLoadRewardHistory)
                    : StringConstants.noRewardHistoryMessage,
                actionLabel: failed ? StringConstants.retry : null,
                onAction: failed
                    ? () => context.read<RewardsBloc>().add(
                        const LoadRewardHistoryEvent(),
                      )
                    : null,
              );
            }

            return RefreshIndicator(
              color: LightColor.secondaryColor,
              onRefresh: () async {
                final RewardsBloc bloc = context.read<RewardsBloc>();
                bloc.add(const LoadRewardHistoryEvent());
                await bloc.stream.firstWhere(
                  (RewardsState next) =>
                      next.historyStatus != RewardsStatus.loading,
                );
              },
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppDimens.paddingX16,
                  horizontal,
                  AppDimens.paddingX32,
                ),
                itemCount: state.history.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppDimens.paddingX10),
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.history.length) {
                    return _ListFooter(state: state);
                  }
                  final RewardHistoryEntryModel entry = state.history[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: LightColor.cardColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                      border: Border.all(color: LightColor.dividerColor),
                    ),
                    child: RewardHistoryTile(entry: entry),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Pagination footer: spinner while loading, an error retry, or the end marker.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final RewardsState state;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    if (state.isLoadingMoreHistory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
        child: Center(
          child: SizedBox(
            width: AppDimens.sizeX24,
            height: AppDimens.sizeX24,
            child: CustomLoading(
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX24,
              strokeWidth: 2.5,
              secondCircleColor: LightColor.secondaryLight,
              thirdCircleColor: LightColor.secondaryLightMedium,
            ),
          ),
        ),
      );
    }

    if (state.historyErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
        child: Center(
          child: TextButton.icon(
            onPressed: () => context.read<RewardsBloc>().add(
              const LoadMoreRewardHistoryEvent(),
            ),
            icon: const Icon(
              Icons.refresh_rounded,
              size: AppDimens.sizeX16,
              color: LightColor.secondaryColor,
            ),
            label: Text(
              StringConstants.retry,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    if (state.hasReachedMax && state.history.length > 6) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
        child: Center(
          child: Text(
            'That’s all your reward activity',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: AppDimens.paddingX8);
  }
}
