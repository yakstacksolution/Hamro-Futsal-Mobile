import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

class AvailableCourtsLoading extends StatelessWidget {
  const AvailableCourtsLoading({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
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
      margin: AppUtils().getMargin(bottom: AppDimens.marginX12),
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: <Widget>[
          const _Block(
            width: AppDimens.sizeX68,
            height: AppDimens.sizeX68,
            radius: AppDimens.radiusX10,
          ),
          const SizedBox(width: AppDimens.sizeX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                _Block(width: AppDimens.sizeX120, height: AppDimens.sizeX14),
                SizedBox(height: AppDimens.sizeX8),
                Row(
                  children: <Widget>[
                    _Block(
                      width: AppDimens.sizeX60,
                      height: AppDimens.sizeX20,
                      radius: AppDimens.radiusX50,
                    ),
                    SizedBox(width: AppDimens.sizeX6),
                    _Block(
                      width: AppDimens.sizeX70,
                      height: AppDimens.sizeX20,
                      radius: AppDimens.radiusX50,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              _Block(
                width: AppDimens.sizeX22,
                height: AppDimens.sizeX22,
                radius: AppDimens.radiusX50,
              ),
              SizedBox(height: AppDimens.sizeX10),
              _Block(width: AppDimens.sizeX58, height: AppDimens.sizeX14),
              SizedBox(height: AppDimens.sizeX4),
              _Block(width: AppDimens.sizeX34, height: AppDimens.sizeX10),
            ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
