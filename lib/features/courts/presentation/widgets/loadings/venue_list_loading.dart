import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

class VenueListLoading extends StatelessWidget {
  const VenueListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: LightColor.skeletonBaseColor,
        highlightColor: LightColor.skeletonHighlightColor,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: AppUtils().getPadding(
            left: AppDimens.paddingX16,
            top: AppDimens.paddingX6,
            right: AppDimens.paddingX16,
            bottom: AppDimens.paddingX24,
          ),
          itemCount: 4,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimens.sizeX14),
          itemBuilder: (_, __) => const _VenueCardSkeleton(),
        ),
      ),
    );
  }
}

class _VenueCardSkeleton extends StatelessWidget {
  const _VenueCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor, width: 1.5),
      ),
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _Block(
                width: AppDimens.sizeX50,
                height: AppDimens.sizeX50,
                radius: AppDimens.radiusX10,
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  _Block(width: AppDimens.sizeX150, height: AppDimens.sizeX14),
                  SizedBox(height: AppDimens.sizeX8),
                  _Block(width: AppDimens.sizeX100, height: AppDimens.sizeX12),
                ],
              ),
              const Spacer(),
              const _Block(
                width: AppDimens.sizeX18,
                height: AppDimens.sizeX18,
                radius: AppDimens.radiusX6,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX14),
          const _CourtRowSkeleton(),
          const SizedBox(height: AppDimens.sizeX10),
          const _CourtRowSkeleton(),
        ],
      ),
    );
  }
}

class _CourtRowSkeleton extends StatelessWidget {
  const _CourtRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        _Block(
          width: AppDimens.sizeX36,
          height: AppDimens.sizeX36,
          radius: AppDimens.radiusX8,
        ),
        SizedBox(width: AppDimens.paddingX10),
        Expanded(child: _Block(height: AppDimens.sizeX12)),
        SizedBox(width: AppDimens.paddingX10),
        _Block(
          width: AppDimens.sizeX60,
          height: AppDimens.sizeX20,
          radius: AppDimens.radiusX8,
        ),
      ],
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
