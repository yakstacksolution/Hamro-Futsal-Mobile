import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

class ExpensesPageLoadingWidget extends StatelessWidget {
  const ExpensesPageLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX20,
                top: AppDimens.paddingX4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      _Box(width: 140, height: 12),
                      Spacer(),
                      _Box(width: 80, height: 12),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingX16),
                  const _ChipRow(widths: [58, 62, 66, 56, 72]),
                  const SizedBox(height: AppDimens.paddingX16),
                  const _ChipRow(widths: [44, 96, 88, 102]),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX28),

            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Box(width: 90, height: 14),
                  const SizedBox(height: AppDimens.paddingX18),
                  const _Box(
                    width: double.infinity,
                    height: 150,
                    radius: AppDimens.radiusX14,
                  ),
                  const SizedBox(height: AppDimens.paddingX18),
                  const _Box(width: 80, height: 14),
                  const SizedBox(height: AppDimens.paddingX8),
                  Row(
                    children: const [
                      Expanded(
                        child: _Box(height: 112, radius: AppDimens.radiusX14),
                      ),
                      SizedBox(width: AppDimens.paddingX10),
                      Expanded(
                        child: _Box(height: 112, radius: AppDimens.radiusX14),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  Row(
                    children: const [
                      Expanded(
                        child: _Box(height: 112, radius: AppDimens.radiusX14),
                      ),
                      SizedBox(width: AppDimens.paddingX10),
                      Expanded(
                        child: _Box(height: 112, radius: AppDimens.radiusX14),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingX20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plain rounded shimmer block.
class _Box extends StatelessWidget {
  const _Box({
    this.width,
    required this.height,
    this.radius = AppDimens.radiusX8,
  });

  final double? width;
  final double height;
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

/// One horizontal row of pill-shaped filter chips.
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.widths});

  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widths.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) => Container(
          width: widths[i],
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
          ),
        ),
      ),
    );
  }
}
