import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton for the transaction-history page's first load: summary card, filter
/// row and a handful of rows.
class TransactionHistoryLoadingView extends StatelessWidget {
  const TransactionHistoryLoadingView({super.key, this.horizontal});

  final double? horizontal;

  @override
  Widget build(BuildContext context) {
    final double pad = horizontal ?? AppDimens.paddingX20;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        pad,
        AppDimens.paddingX16,
        pad,
        AppDimens.paddingX50,
      ),
      child: Shimmer.fromColors(
        baseColor: LightColor.dividerColor,
        highlightColor: LightColor.background,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Block(height: 122, radius: AppDimens.radiusX12),
            SizedBox(height: AppDimens.paddingX12),
            _Block(height: AppDimens.sizeX44, radius: AppDimens.radiusX10),
            SizedBox(height: AppDimens.paddingX12),
            Row(
              children: <Widget>[
                _Block(
                  height: AppDimens.sizeX32,
                  width: 72,
                  radius: AppDimens.radiusX8,
                ),
                SizedBox(width: AppDimens.paddingX6),
                _Block(
                  height: AppDimens.sizeX32,
                  width: 64,
                  radius: AppDimens.radiusX8,
                ),
                SizedBox(width: AppDimens.paddingX6),
                SizedBox(width: AppDimens.paddingX6),
                _Block(
                  height: AppDimens.sizeX32,
                  width: 88,
                  radius: AppDimens.radiusX8,
                ),
              ],
            ),
            SizedBox(height: AppDimens.paddingX20),
            TransactionRowsSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Skeleton rows, shaped like [TransactionTile].
class TransactionRowsSkeleton extends StatelessWidget {
  const TransactionRowsSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int index = 0; index < itemCount; index++)
          Container(
            margin: const EdgeInsets.only(bottom: AppDimens.paddingX10),
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            decoration: BoxDecoration(
              color: LightColor.cardColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX14),
              border: Border.all(color: LightColor.dividerColor),
            ),
            child: const Row(
              children: <Widget>[
                _Block(
                  height: AppDimens.sizeX44,
                  width: AppDimens.sizeX44,
                  radius: AppDimens.radiusX24,
                ),
                SizedBox(width: AppDimens.paddingX14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _Block(height: 12, radius: AppDimens.radiusX4),
                      SizedBox(height: AppDimens.paddingX6),
                      _Block(
                        height: 10,
                        width: 140,
                        radius: AppDimens.radiusX4,
                      ),
                      SizedBox(height: AppDimens.paddingX8),
                      _Block(height: 10, width: 90, radius: AppDimens.radiusX4),
                    ],
                  ),
                ),
                SizedBox(width: AppDimens.paddingX12),
                _Block(height: 12, width: 56, radius: AppDimens.radiusX4),
              ],
            ),
          ),
      ],
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
