import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton for the rewards page while the wallet loads for the first time.
class RewardsLoadingView extends StatelessWidget {
  const RewardsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppDimens.paddingX20,
        AppDimens.paddingX16,
        AppDimens.paddingX20,
        AppDimens.paddingX50,
      ),
      child: RewardShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Block(height: 190, radius: AppDimens.radiusX16),
            SizedBox(height: AppDimens.paddingX12),
            Row(
              children: <Widget>[
                Expanded(child: _Block(height: 92)),
                SizedBox(width: AppDimens.paddingX10),
                Expanded(child: _Block(height: 92)),
              ],
            ),
            SizedBox(height: AppDimens.paddingX20),
            _Block(height: 18, width: 140, radius: AppDimens.radiusX4),
            SizedBox(height: AppDimens.paddingX10),
            RewardHistoryLoadingList(itemCount: 4),
          ],
        ),
      ),
    );
  }
}

/// Skeleton rows for the history list.
class RewardHistoryLoadingList extends StatelessWidget {
  const RewardHistoryLoadingList({
    super.key,
    this.itemCount = 6,
    this.wrapWithShimmer = false,
  });

  final int itemCount;

  /// Set when used outside [RewardsLoadingView], which already shimmers.
  final bool wrapWithShimmer;

  @override
  Widget build(BuildContext context) {
    final Widget list = Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < itemCount; i++)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX14,
                vertical: AppDimens.paddingX12,
              ),
              child: Row(
                children: <Widget>[
                  _Block(
                    height: AppDimens.sizeX36,
                    width: AppDimens.sizeX36,
                    radius: AppDimens.radiusX10,
                  ),
                  SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Block(height: 12, radius: AppDimens.radiusX4),
                        SizedBox(height: AppDimens.paddingX6),
                        _Block(
                          height: 10,
                          width: 120,
                          radius: AppDimens.radiusX4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppDimens.paddingX12),
                  _Block(height: 12, width: 44, radius: AppDimens.radiusX4),
                ],
              ),
            ),
        ],
      ),
    );

    return wrapWithShimmer ? RewardShimmer(child: list) : list;
  }
}

/// Shared shimmer wrapper, so every reward skeleton animates identically.
class RewardShimmer extends StatelessWidget {
  const RewardShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: LightColor.dividerColor,
      highlightColor: LightColor.background,
      child: child,
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.height,
    this.width,
    this.radius = AppDimens.radiusX12,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
