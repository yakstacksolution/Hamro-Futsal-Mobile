import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:shimmer/shimmer.dart';

class HomeBodyLoading extends StatelessWidget {
  const HomeBodyLoading({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) { 
    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: AppDimens.sizeX22),
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: AppUtils().getPadding(bottom: AppDimens.sizeX20),
              child: const _CourtCardSkeleton(),
            );
          },
        ),
      ),
    );
  }
}

class _CourtCardSkeleton extends StatelessWidget {
  const _CourtCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Cover image.
        _Block(height: AppDimens.sizeX200, radius: AppDimens.radiusX18),
        Padding(
          padding: AppUtils().getPadding(all: AppDimens.sizeX14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title + rating pill.
              Row(
                children: <Widget>[
                  const Expanded(child: _Block(height: AppDimens.sizeX16)),
                  const SizedBox(width: AppDimens.sizeX8),
                  _Block(height: AppDimens.sizeX16, width: AppDimens.sizeX60),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX10),
              // Location line.
              _Block(height: AppDimens.sizeX12, width: AppDimens.sizeX150),
              const SizedBox(height: AppDimens.sizeX12),
              // Price + status pill.
              Row(
                children: <Widget>[
                  _Block(height: AppDimens.sizeX18, width: AppDimens.sizeX100),
                  const Spacer(),
                  _Block(height: AppDimens.sizeX18, width: AppDimens.sizeX80),
                ],
              ),
            ],
          ),
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
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
