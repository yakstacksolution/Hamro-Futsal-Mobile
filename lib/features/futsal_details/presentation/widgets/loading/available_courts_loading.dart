import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

class AvailableCourtsLoading extends StatelessWidget {
  const AvailableCourtsLoading({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: LightColor.skeletonBaseColor,
      highlightColor: LightColor.skeletonHighlightColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return const _CourtSlotCardSkeleton();
        },
      ),
    );
  }
}

class _CourtSlotCardSkeleton extends StatelessWidget {
  const _CourtSlotCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: AppUtils().getMargin(bottom: AppDimens.marginX10),
      padding: AppUtils().getPadding(all: AppDimens.paddingX10),
      decoration: BoxDecoration(
        color: LightColor.elevatedCardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: <Widget>[
          const _Block(
            width: AppDimens.sizeX52,
            height: AppDimens.sizeX52,
            radius: AppDimens.radiusX10,
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                _Block(width: AppDimens.sizeX110, height: AppDimens.sizeX12),
                SizedBox(height: AppDimens.sizeX8),
                Row(
                  children: <Widget>[
                    _Block(
                      width: AppDimens.sizeX60,
                      height: AppDimens.sizeX16,
                      radius: AppDimens.radiusX50,
                    ),
                    SizedBox(width: AppDimens.sizeX6),
                    _Block(
                      width: AppDimens.sizeX40,
                      height: AppDimens.sizeX16,
                      radius: AppDimens.radiusX50,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sizeX8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              _Block(width: AppDimens.sizeX58, height: AppDimens.sizeX12),
              SizedBox(height: AppDimens.sizeX4),
              _Block(width: AppDimens.sizeX34, height: AppDimens.sizeX10),
            ],
          ),
          const SizedBox(width: AppDimens.sizeX8),
          const _Block(
            width: AppDimens.sizeX22,
            height: AppDimens.sizeX22,
            radius: AppDimens.radiusX50,
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.height,
    this.width,
    this.radius = AppDimens.radiusX8,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: LightColor.skeletonBaseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
