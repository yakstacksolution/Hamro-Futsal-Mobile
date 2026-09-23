import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:shimmer/shimmer.dart';

/// The whole "Your Venues" screen while its first load is in flight.
///
/// The header's figures and the search box are drawn as placeholders too: the
/// real header would otherwise report a portfolio of four zeros for as long as
/// the request takes, which reads as an answer rather than as waiting.
class VenueCourtsPageLoading extends StatelessWidget {
  const VenueCourtsPageLoading({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _HeaderSkeleton(),
          const SizedBox(height: AppDimens.paddingX10),
          const _SearchFieldSkeleton(),
          const SizedBox(height: AppDimens.paddingX6),
          Expanded(child: _VenueCardListSkeleton(itemCount: itemCount)),
        ],
      ),
    );
  }
}

/// The venue list alone, for the case where the header and search box are
/// already on screen — traces the real card: cover, name and contact lines,
/// the figures row with its badge, the courts toggle and two court rows.
class VenueListLoading extends StatelessWidget {
  const VenueListLoading({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) =>
      _Shimmer(child: _VenueCardListSkeleton(itemCount: itemCount));
}

/// One shimmer sweep for everything beneath it, so the whole screen pulses
/// together instead of each card running its own animation.
class _Shimmer extends StatelessWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: LightColor.skeletonBaseColor,
      highlightColor: LightColor.skeletonHighlightColor,
      child: child,
    );
  }
}

class _VenueCardListSkeleton extends StatelessWidget {
  const _VenueCardListSkeleton({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX16,
        top: AppDimens.paddingX6,
        right: AppDimens.paddingX16,
        bottom: AppDimens.paddingX24,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.sizeX10),
      // The first card stands open with two court rows and the rest closed —
      // the same mix the list usually lands in, so the page settles instead of
      // collapsing three expanded cards at once.
      itemBuilder: (_, int index) => _VenueCardSkeleton(expanded: index == 0),
    );
  }
}

/// `_TopDashboardHeader`: title, subtitle, the "New futsal" pill, then the
/// four-figure portfolio strip in its [DataCard].
class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX16,
        right: AppDimens.paddingX16,
        top: AppDimens.paddingX14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _Block(
                      width: AppDimens.sizeX150,
                      height: AppDimens.sizeX16,
                    ),
                    SizedBox(height: AppDimens.paddingX6),
                    _Block(
                      width: AppDimens.sizeX180,
                      height: AppDimens.sizeX10,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimens.paddingX10),
              _Block(
                width: AppDimens.sizeX90,
                height: AppDimens.sizeX32,
                radius: AppDimens.radiusX6,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX14),
          DataCard(
            child: Row(
              children: const <Widget>[
                _MetricSkeleton(),
                _SeparatorSkeleton(),
                _MetricSkeleton(),
                _SeparatorSkeleton(),
                _MetricSkeleton(),
                _SeparatorSkeleton(),
                _MetricSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One figure in the portfolio strip: the number above, its name beneath,
/// both centred like `_PortfolioMetric`.
class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Block(width: AppDimens.sizeX20, height: AppDimens.sizeX16),
          SizedBox(height: AppDimens.sizeX4),
          _Block(width: AppDimens.sizeX40, height: AppDimens.sizeX8),
        ],
      ),
    );
  }
}

/// `_VenueSearchField`: a 44-high filled box with a leading glyph.
class _SearchFieldSkeleton extends StatelessWidget {
  const _SearchFieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX16),
      child: Container(
        height: AppDimens.sizeX44,
        decoration: BoxDecoration(
          color: LightColor.skeletonBaseColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
          border: Border.all(color: LightColor.dividerColor, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
        child: Row(
          children: const <Widget>[
            _Block(
              width: AppDimens.sizeX18,
              height: AppDimens.sizeX18,
              radius: AppDimens.radiusX4,
            ),
            SizedBox(width: AppDimens.marginX6),
            _Block(width: AppDimens.sizeX180, height: AppDimens.sizeX10),
          ],
        ),
      ),
    );
  }
}

/// `_VenueCardV2`, block for block.
class _VenueCardSkeleton extends StatelessWidget {
  const _VenueCardSkeleton({this.expanded = true});

  /// Whether the courts panel is drawn open, as an expanded card's is.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.paddingX12,
                AppDimens.paddingX12,
                AppDimens.paddingX8,
                AppDimens.paddingX12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // The cover.
                      _Block(
                        width: AppDimens.sizeX60,
                        height: AppDimens.sizeX60,
                        radius: AppDimens.radiusX10,
                      ),
                      SizedBox(width: AppDimens.paddingX12),
                      // Name, address, phone.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _Block(
                              width: AppDimens.sizeX150,
                              height: AppDimens.sizeX14,
                            ),
                            SizedBox(height: AppDimens.sizeX8),
                            _Block(height: AppDimens.sizeX10),
                            SizedBox(height: AppDimens.sizeX6),
                            _Block(
                              width: AppDimens.sizeX100,
                              height: AppDimens.sizeX10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppDimens.paddingX6),
                      // The overflow menu's glyph.
                      _Block(
                        width: AppDimens.sizeX20,
                        height: AppDimens.sizeX20,
                        radius: AppDimens.radiusX4,
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimens.paddingX12),
                  // Courts / Live / Pending, then the approval badge.
                  Padding(
                    padding: EdgeInsets.only(
                      right: AppDimens.paddingX8,
                      left: 2,
                    ),
                    child: Row(
                      children: <Widget>[
                        _VenueStatSkeleton(),
                        _SeparatorSkeleton(),
                        _VenueStatSkeleton(),
                        _SeparatorSkeleton(),
                        _VenueStatSkeleton(),
                        _SeparatorSkeleton(),
                        _Block(
                          width: AppDimens.sizeX72,
                          height: AppDimens.sizeX20,
                          radius: AppDimens.radiusX6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
            // The courts toggle strip.
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.paddingX12,
                AppDimens.paddingX10,
                AppDimens.paddingX12,
                AppDimens.paddingX10,
              ),
              child: Row(
                children: <Widget>[
                  _Block(
                    width: AppDimens.sizeX16,
                    height: AppDimens.sizeX16,
                    radius: AppDimens.radiusX4,
                  ),
                  SizedBox(width: AppDimens.sizeX6),
                  _Block(width: AppDimens.sizeX52, height: AppDimens.sizeX12),
                  SizedBox(width: AppDimens.sizeX6),
                  // The count badge is a circle at the real size.
                  _Block(
                    width: AppDimens.sizeX18,
                    height: AppDimens.sizeX18,
                    radius: AppDimens.sizeX18,
                  ),
                  Spacer(),
                  _Block(width: AppDimens.sizeX40, height: AppDimens.sizeX12),
                  SizedBox(width: 2),
                  _Block(
                    width: AppDimens.sizeX18,
                    height: AppDimens.sizeX18,
                    radius: AppDimens.radiusX4,
                  ),
                ],
              ),
            ),
            if (expanded)
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
                    _CourtRowSkeleton(),
                    SizedBox(height: AppDimens.paddingX10),
                    _CourtRowSkeleton(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The 1px rule between figures, as `_MetricSeparator` draws it.
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

/// `_VenueStat`: the label above, the value beneath, both left-aligned.
class _VenueStatSkeleton extends StatelessWidget {
  const _VenueStatSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Block(width: AppDimens.sizeX40, height: AppDimens.sizeX8),
          SizedBox(height: 2),
          _Block(width: AppDimens.sizeX26, height: AppDimens.sizeX12),
        ],
      ),
    );
  }
}

/// `_CourtRowV2`: thumb, name and meta, menu — then price and two chips.
class _CourtRowSkeleton extends StatelessWidget {
  const _CourtRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX10),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                    _Block(
                      width: AppDimens.sizeX120,
                      height: AppDimens.sizeX12,
                    ),
                    SizedBox(height: 3),
                    _Block(height: AppDimens.sizeX10),
                  ],
                ),
              ),
              SizedBox(width: AppDimens.paddingX6),
              _Block(
                width: AppDimens.sizeX20,
                height: AppDimens.sizeX20,
                radius: AppDimens.radiusX4,
              ),
            ],
          ),
          SizedBox(height: AppDimens.sizeX10),
          Row(
            children: <Widget>[
              _Block(width: AppDimens.sizeX80, height: AppDimens.sizeX16),
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

/// One grey placeholder. A null [width] fills the space it is given.
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
