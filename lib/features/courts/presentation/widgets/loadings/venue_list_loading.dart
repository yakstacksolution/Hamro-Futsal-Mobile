import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

/// The venue list while it loads. Traces the real card — cover banner, name,
/// contact line, the three figures and two court rows — so nothing jumps when
/// the data lands.
class VenueListLoading extends StatelessWidget {
  const VenueListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
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
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimens.sizeX10),
        itemBuilder: (_, __) => const _VenueCardSkeleton(),
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
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingX12,
              AppDimens.paddingX12,
              AppDimens.paddingX12,
              AppDimens.paddingX12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    _Block(
                      width: AppDimens.sizeX60,
                      height: AppDimens.sizeX60,
                      radius: AppDimens.radiusX10,
                    ),
                    SizedBox(width: AppDimens.paddingX12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _Block(height: 14),
                          SizedBox(height: AppDimens.sizeX8),
                          _Block(
                            width: AppDimens.sizeX150,
                            height: AppDimens.sizeX10,
                          ),
                          SizedBox(height: AppDimens.sizeX6),
                          _Block(
                            width: AppDimens.sizeX100,
                            height: AppDimens.sizeX10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppDimens.paddingX8),
                    _Block(
                      width: AppDimens.sizeX14,
                      height: AppDimens.sizeX14,
                      radius: AppDimens.radiusX4,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingX14),
                Row(
                  children: const <Widget>[
                    _StatSkeleton(),
                    SizedBox(width: AppDimens.paddingX12),
                    _StatSkeleton(),
                    SizedBox(width: AppDimens.paddingX12),
                    _StatSkeleton(),
                    _SeparatorSkeleton(),
                    _Block(
                      width: AppDimens.sizeX52,
                      height: AppDimens.sizeX14,
                      radius: AppDimens.radiusX6,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX12,
              vertical: AppDimens.paddingX10,
            ),
            child: Row(
              children: <Widget>[
                _Block(
                  width: AppDimens.sizeX16,
                  height: AppDimens.sizeX16,
                  radius: AppDimens.radiusX4,
                ),
                SizedBox(width: AppDimens.sizeX6),
                _Block(width: AppDimens.sizeX72, height: AppDimens.sizeX12),
                Spacer(),
                _Block(width: AppDimens.sizeX40, height: AppDimens.sizeX12),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.paddingX12,
              0,
              AppDimens.paddingX12,
              AppDimens.paddingX12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CourtLineSkeleton(),
                SizedBox(height: AppDimens.paddingX10),
                _CourtLineSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeparatorSkeleton extends StatelessWidget {
  const _SeparatorSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: AppDimens.sizeX32,
    margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX6),
    color: LightColor.dividerColor,
  );
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          _Block(width: AppDimens.sizeX40, height: AppDimens.sizeX8),
          SizedBox(height: AppDimens.sizeX6),
          _Block(width: AppDimens.sizeX60, height: AppDimens.sizeX12),
        ],
      ),
    );
  }
}

class _CourtLineSkeleton extends StatelessWidget {
  const _CourtLineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: const <Widget>[
              _Block(
                width: AppDimens.sizeX52,
                height: AppDimens.sizeX52,
                radius: AppDimens.radiusX8,
              ),
              SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _Block(height: AppDimens.sizeX12),
                    SizedBox(height: AppDimens.sizeX6),
                    _Block(
                      width: AppDimens.sizeX100,
                      height: AppDimens.sizeX10,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimens.paddingX8),
              _Block(
                width: AppDimens.sizeX14,
                height: AppDimens.sizeX14,
                radius: AppDimens.radiusX4,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX10),
          Row(
            children: const <Widget>[
              _Block(width: AppDimens.sizeX100, height: AppDimens.sizeX14),
              Spacer(),
              _Block(
                width: AppDimens.sizeX60,
                height: AppDimens.sizeX20,
                radius: AppDimens.radiusX6,
              ),
              SizedBox(width: AppDimens.sizeX6),
              _Block(
                width: AppDimens.sizeX72,
                height: AppDimens.sizeX20,
                radius: AppDimens.radiusX6,
              ),
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
        color: LightColor.skeletonBaseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
