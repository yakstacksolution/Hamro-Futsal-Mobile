import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

class VenueCourtsListShimmer extends StatelessWidget {
  const VenueCourtsListShimmer({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6E8EB),
      highlightColor: const Color(0xFFF5F6F7),
      period: const Duration(milliseconds: 1200),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: AppUtils().getPadding(
          left: AppDimens.paddingX16,
          top: AppDimens.paddingX6,
          right: AppDimens.paddingX16,
          bottom: AppDimens.paddingX24,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimens.sizeX10),
        itemBuilder: (_, __) => const _VenueCardSkeleton(),
      ),
    );
  }
}

class _VenueCardSkeleton extends StatelessWidget {
  const _VenueCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: appUtils.getPadding(
                  left: AppDimens.paddingX14,
                  top: AppDimens.paddingX14,
                  right: AppDimens.paddingX14,
                  bottom: AppDimens.paddingX10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _ShimmerBox(
                          width: AppDimens.sizeX50,
                          height: AppDimens.sizeX50,
                          radius: AppDimens.radiusX10,
                        ),
                        const SizedBox(width: AppDimens.paddingX12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: AppDimens.paddingX4,
                              right: AppDimens.paddingX24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                _ShimmerBox(
                                  width: 150,
                                  height: 14,
                                  radius: 4,
                                ),
                                SizedBox(height: AppDimens.sizeX8),
                                Row(
                                  children: <Widget>[
                                    _ShimmerBox(
                                      width: AppDimens.sizeX14,
                                      height: AppDimens.sizeX14,
                                      radius: 3,
                                    ),
                                    SizedBox(width: AppDimens.sizeX4),
                                    Expanded(
                                      child: _ShimmerBox(
                                        width: double.infinity,
                                        height: 10,
                                        radius: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.sizeX14),
                    Row(
                      children: const <Widget>[
                        _ShimmerBox(width: 76, height: 22, radius: 4),
                        SizedBox(width: AppDimens.sizeX8),
                        _ShimmerBox(width: 64, height: 22, radius: 4),
                        SizedBox(width: AppDimens.sizeX8),
                        _ShimmerBox(width: 96, height: 22, radius: 4),
                      ],
                    ),
                    const SizedBox(height: AppDimens.sizeX14),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: LightColor.dividerColor,
              ),
              Padding(
                padding: appUtils.getPadding(
                  symmetricHorizontal: AppDimens.paddingX16,
                  symmetricVertical: AppDimens.paddingX12,
                ),
                child: Row(
                  children: const <Widget>[
                    _ShimmerBox(
                      width: AppDimens.sizeX20,
                      height: AppDimens.sizeX20,
                      radius: 5,
                    ),
                    SizedBox(width: AppDimens.sizeX6),
                    _ShimmerBox(width: 150, height: 12, radius: 4),
                    Spacer(),
                    _ShimmerBox(width: 26, height: 26, radius: 4),
                  ],
                ),
              ),
              Padding(
                padding: appUtils.getPadding(
                  left: AppDimens.paddingX16,
                  right: AppDimens.paddingX16,
                  bottom: AppDimens.paddingX16,
                ),
                child: Column(
                  children: const <Widget>[
                    _CourtRowSkeleton(),
                    SizedBox(height: AppDimens.paddingX10),
                    _CourtRowSkeleton(),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: _ApprovalBadgeSkeleton(),
          ),
        ],
      ),
    );
  }
}

class _ApprovalBadgeSkeleton extends StatelessWidget {
  const _ApprovalBadgeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX10,
        symmetricVertical: AppDimens.paddingX4,
      ),
      decoration: const BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.radiusX14),
          topRight: Radius.circular(AppDimens.radiusX14),
        ),
      ),
      child: const _ShimmerBox(width: 52, height: 12, radius: 3),
    );
  }
}

class _CourtRowSkeleton extends StatelessWidget {
  const _CourtRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    return Container(
      padding: appUtils.getPadding(
        symmetricHorizontal: AppDimens.paddingX10,
        symmetricVertical: AppDimens.paddingX10,
      ),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const _ShimmerBox(
            width: AppDimens.sizeX72,
            height: AppDimens.sizeX72,
            radius: AppDimens.radiusX8,
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _ShimmerBox(width: 110, height: 12, radius: 4),
                          SizedBox(height: AppDimens.sizeX4),
                          _ShimmerBox(width: 70, height: 10, radius: 3),
                        ],
                      ),
                    ),
                    SizedBox(width: AppDimens.sizeX8),
                    _ShimmerBox(
                      width: AppDimens.sizeX22,
                      height: AppDimens.sizeX22,
                      radius: 4,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sizeX8),
                Row(
                  children: const <Widget>[
                    _ShimmerBox(
                      width: 52,
                      height: AppDimens.sizeX24,
                      radius: 4,
                    ),
                    SizedBox(width: AppDimens.sizeX6),
                    _ShimmerBox(
                      width: 64,
                      height: AppDimens.sizeX24,
                      radius: 4,
                    ),
                    SizedBox(width: AppDimens.sizeX6),
                    _ShimmerBox(
                      width: 46,
                      height: AppDimens.sizeX24,
                      radius: 4,
                    ),
                    SizedBox(width: AppDimens.sizeX6),
                    _ShimmerBox(
                      width: 40,
                      height: AppDimens.sizeX24,
                      radius: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 4,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
