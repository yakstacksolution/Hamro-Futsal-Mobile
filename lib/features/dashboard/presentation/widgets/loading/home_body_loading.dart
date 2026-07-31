import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:shimmer/shimmer.dart';

class HomeBodyLoading extends StatelessWidget {
  const HomeBodyLoading({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive<double>(
          mobile: AppDimens.paddingX20,
          tablet: AppDimens.paddingX32,
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Same helper as the real feed, so the two always agree.
          final int columns = venueGridColumns(context, constraints.maxWidth);
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: columns == 1
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: AppDimens.sizeX22),
                    itemCount: itemCount,
                    itemBuilder: (BuildContext context, int index) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: AppDimens.sizeX20),
                        child: _CourtCardSkeleton(),
                      );
                    },
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: AppDimens.sizeX22),
                    itemCount: itemCount * columns,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: AppDimens.sizeX20,
                      mainAxisSpacing: AppDimens.sizeX20,
                      mainAxisExtent: AppDimens.courtCardGridExtent,
                    ),
                    itemBuilder: (BuildContext context, int index) =>
                        const _CourtCardSkeleton(flexibleCover: true),
                  ),
          );
        },
      ),
    );
  }
}

class _CourtCardSkeleton extends StatelessWidget {
  const _CourtCardSkeleton({this.flexibleCover = false});

  /// Matches `CourtCard.flexibleCover`: fills the fixed grid cell height.
  final bool flexibleCover;

  @override
  Widget build(BuildContext context) {
    const Widget cover = _Block(
      height: double.infinity,
      radius: AppDimens.radiusX18,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Cover image.
        if (flexibleCover)
          const Expanded(child: cover)
        else
          _Block(height: AppDimens.sizeX200, radius: AppDimens.radiusX18),
        Padding(
          padding: const EdgeInsets.all(AppDimens.sizeX14),
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
