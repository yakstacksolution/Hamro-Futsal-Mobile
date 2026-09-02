import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';

class SelectionTimeLoading extends StatelessWidget {
  const SelectionTimeLoading({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: LightColor.skeletonBaseColor,
      highlightColor: LightColor.skeletonHighlightColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppDimens.sizeX6,
          crossAxisSpacing: AppDimens.sizeX4,
          mainAxisExtent: AppDimens.sizeX30,
        ),
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: AppUtils().getPadding(horizontal: AppDimens.paddingX8),
            decoration: BoxDecoration(
              color: LightColor.skeletonBaseColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX50),
            ),
          );
        },
      ),
    );
  }
}
