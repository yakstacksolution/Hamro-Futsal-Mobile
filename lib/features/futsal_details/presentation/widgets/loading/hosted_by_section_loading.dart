import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton that mirrors [CourtHostedBySection] exactly — same outer
/// padding, card padding, and inner layout — so the section doesn't jump when
/// the real data arrives.
class HostedBySectionLoading extends StatelessWidget {
  const HostedBySectionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX12,
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
      ),
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 'Hosted By' title.
              _Block(height: AppDimens.sizeX16, width: AppDimens.sizeX80),
              const SizedBox(height: AppDimens.sizeX14),
              Row(
                children: <Widget>[
                  // Avatar.
                  _Block(
                    height: AppDimens.sizeX56,
                    width: AppDimens.sizeX56,
                    radius: AppDimens.radiusX10,
                  ),
                  const SizedBox(width: AppDimens.sizeX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Host name + verified badge.
                        _Block(
                          height: AppDimens.sizeX16,
                          width: AppDimens.sizeX120,
                        ),
                        const SizedBox(height: AppDimens.sizeX6),
                        // 'Hosting since ...' line.
                        _Block(
                          height: AppDimens.sizeX12,
                          width: AppDimens.sizeX90,
                        ),
                      ],
                    ),
                  ),
                  // Chat icon box.
                  _Block(
                    height: AppDimens.sizeX42,
                    width: AppDimens.sizeX42,
                    radius: AppDimens.radiusX8,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX14),
              // Courts / Venues / Rating metric tiles.
              Row(
                children: const <Widget>[
                  _MetricTileSkeleton(),
                  SizedBox(width: AppDimens.sizeX10),
                  _MetricTileSkeleton(),
                  SizedBox(width: AppDimens.sizeX10),
                  _MetricTileSkeleton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTileSkeleton extends StatelessWidget {
  const _MetricTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppUtils().getPadding(
          horizontal: AppDimens.paddingX10,
          vertical: AppDimens.paddingX10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        ),
        child: Column(
          children: <Widget>[
            // Icon.
            _Block(
              height: AppDimens.sizeX18,
              width: AppDimens.sizeX18,
              radius: AppDimens.radiusX50,
            ),
            const SizedBox(height: AppDimens.sizeX4),
            // Value.
            _Block(height: AppDimens.sizeX14, width: AppDimens.sizeX30),
            const SizedBox(height: AppDimens.sizeX4),
            // Label.
            _Block(height: AppDimens.sizeX10, width: AppDimens.sizeX40),
          ],
        ),
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
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
