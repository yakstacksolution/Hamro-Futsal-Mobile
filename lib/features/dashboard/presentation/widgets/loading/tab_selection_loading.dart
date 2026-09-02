import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';

class TabSelectionLoading extends StatelessWidget {
  const TabSelectionLoading({super.key});

  static const List<double> _chipWidths = <double>[
    AppDimens.sizeX80,
    AppDimens.sizeX90,
    AppDimens.sizeX80,
    AppDimens.sizeX90,
    AppDimens.sizeX90,
    AppDimens.sizeX80,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX40,
      child: Shimmer.fromColors(
        baseColor: LightColor.skeletonBaseColor,
        highlightColor: LightColor.skeletonHighlightColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _chipWidths.length,
          itemBuilder: (BuildContext context, int i) {
            return Container(
              width: _chipWidths[i],
              margin: const EdgeInsets.only(right: AppDimens.marginX10),
              decoration: BoxDecoration(
                color: LightColor.skeletonBaseColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              ),
            );
          },
        ),
      ),
    );
  }
}
