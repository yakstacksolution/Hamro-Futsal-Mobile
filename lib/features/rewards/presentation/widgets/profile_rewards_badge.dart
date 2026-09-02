import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_futsal/features/rewards/domain/usecase/rewards_usecase.dart';
import 'package:hamro_futsal/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:hamro_futsal/features/rewards/presentation/bloc/rewards_bloc/rewards_bloc.dart';
import 'package:hamro_futsal/features/rewards/presentation/widgets/rewards_loading_widgets.dart';

/// The points pill that sits at the trailing edge of the profile heading.
///
/// Owns a short-lived [RewardsBloc] so the profile page keeps no reward state;
/// the full rewards screen refetches when opened.
class ProfileRewardsBadge extends StatelessWidget {
  const ProfileRewardsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RewardsBloc>(
      create: (_) =>
          RewardsBloc(RewardsUseCase(RewardsRepositoryImpl()))
            ..add(const LoadRewardsEvent()),
      child: const _ProfileRewardsBadgeBody(),
    );
  }
}

class _ProfileRewardsBadgeBody extends StatelessWidget {
  const _ProfileRewardsBadgeBody();

  /// Keeps the pill from growing past a couple of glyphs on a large balance.
  static String _formatPoints(int points) {
    if (points < 1000) return '$points';
    if (points < 100000) {
      final double thousands = points / 1000;
      final String value = thousands >= 10
          ? thousands.round().toString()
          : thousands.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
      return '${value}k';
    }
    return '${(points / 1000).round()}k';
  }

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    return BlocBuilder<RewardsBloc, RewardsState>(
      builder: (BuildContext context, RewardsState state) {
        // A failed wallet fetch leaves the heading clean — the rewards row in
        // the menu below still gets the user to the full screen.
        if (state.isSummaryFailure) return const SizedBox.shrink();

        if (state.isInitialLoading) {
          return const RewardShimmer(
            child: SizedBox(width: 84, height: 30, child: _PillSkeleton()),
          );
        }

        final RewardsSummaryModel wallet = state.wallet;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusX20),
          child: InkWell(
            onTap: () => context.pushNamed(AppRouterParams.rewards.name),
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX12,
                vertical: AppDimens.paddingX6,
              ),
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                border: Border.all(
                  color: LightColor.secondaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.stars_rounded,
                    size: AppDimens.sizeX16,
                    color: LightColor.secondaryColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX6),
                  Text(
                    _formatPoints(wallet.availablePoints),
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX4),
                  Text(
                    'pts',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: AppDimens.fontBodySubTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PillSkeleton extends StatelessWidget {
  const _PillSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
    );
  }
}
