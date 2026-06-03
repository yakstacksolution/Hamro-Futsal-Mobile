import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

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
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _chipWidths.length,
          itemBuilder: (BuildContext context, int i) {
            return Container(
              width: _chipWidths[i],
              margin: AppUtils().getMargin(right: AppDimens.marginX10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              ),
            );
          },
        ),
      ),
    );
  }
}
