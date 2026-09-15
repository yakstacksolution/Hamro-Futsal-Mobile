import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:shimmer/shimmer.dart';

class AccountLoadingView extends StatelessWidget {
  const AccountLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppDimens.paddingX20,
        AppDimens.paddingX16,
        AppDimens.paddingX20,
        AppDimens.paddingX50,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _AccountShimmer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _BalanceCardSkeleton(),
                SizedBox(height: AppDimens.paddingX12),
                _StatsSkeleton(),
                SizedBox(height: AppDimens.paddingX16),
                _ShortcutCardSkeleton(),
                SizedBox(height: AppDimens.paddingX20),
                _LineBlock(width: 136, height: 18, radius: AppDimens.radiusX4),
              ],
            ),
          ),
          SizedBox(height: AppDimens.paddingX10),
          // The activity cards shimmer their own contents, so they sit
          // outside the sweep above rather than being painted over whole.
          AccountListLoading(itemCount: 3),
        ],
      ),
    );
  }
}

/// Placeholder for the recent-activity list.
///
/// Shaped as the cards it stands in for — same panel, same header, same
/// divider, same field rows — so the list does not visibly re-flow when the
/// real entries arrive. Only the content shimmers: the card's own surface and
/// hairline are drawn for real, outside the sweep, because a card that is
/// already there reads as loading rather than as missing.
class AccountListLoading extends StatelessWidget {
  const AccountListLoading({
    super.key,
    this.itemCount = 5,
    this.showDayHeader = false,
  });

  final int itemCount;

  /// Includes the day heading the full list groups under. The account
  /// screen's short preview has none, so it leaves this off.
  final bool showDayHeader;

  @override
  Widget build(BuildContext context) {
    final Widget run = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showDayHeader) ...<Widget>[
          const _DayHeaderSkeleton(),
          const SizedBox(height: AppDimens.paddingX10),
        ],
        for (int i = 0; i < itemCount; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppDimens.paddingX12),
          _EntryCardSkeleton(shortAmount: i.isOdd),
        ],
      ],
    );

    // These cards are as tall as the real ones, so a full run of them is
    // taller than a short phone's viewport. Given a bounded height, the run
    // extends past the bottom inside a scroll view instead of overflowing;
    // given an unbounded one — inside a ListView or another scroll view — it
    // is returned as-is, so the two never nest.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedHeight) return run;
        return SingleChildScrollView(
          // It does not scroll: there is nothing below the placeholder to
          // reach until the real rows arrive.
          physics: const NeverScrollableScrollPhysics(),
          child: run,
        );
      },
    );
  }
}

/// The `TODAY · 12 SEP 2026` heading a run of cards sits under.
class _DayHeaderSkeleton extends StatelessWidget {
  const _DayHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _AccountShimmer(
          child: _LineBlock(width: 116, height: 10, radius: AppDimens.radiusX4),
        ),
        const SizedBox(width: AppDimens.paddingX10),
        Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
        ),
      ],
    );
  }
}

/// One ledger entry card, unfilled.
class _EntryCardSkeleton extends StatelessWidget {
  const _EntryCardSkeleton({this.shortAmount = false});

  /// Varies the amount's width between rows — a column of identical bars
  /// reads as a pattern rather than as content on its way.
  final bool shortAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header: glyph, title over reference, figure over chip.
          _AccountShimmer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _LineBlock(
                  width: 34,
                  height: 34,
                  radius: AppDimens.radiusX10,
                ),
                const SizedBox(width: AppDimens.paddingX10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _LineBlock(
                        width: 132,
                        height: 14,
                        radius: AppDimens.radiusX4,
                      ),
                      SizedBox(height: AppDimens.paddingX6),
                      _LineBlock(
                        width: 86,
                        height: 12,
                        radius: AppDimens.radiusX4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _LineBlock(
                      width: shortAmount ? 58 : 78,
                      height: 12,
                      radius: AppDimens.radiusX4,
                    ),
                    const SizedBox(height: AppDimens.paddingX6),
                    const _LineBlock(
                      width: 46,
                      height: 12,
                      radius: AppDimens.radiusX6,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // The card's own hairline, drawn for real.
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.paddingX10,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: LightColor.dividerColor,
            ),
          ),
          const _AccountShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _FieldRowSkeleton(valueWidth: 148),
                SizedBox(height: AppDimens.paddingX12),
                _FieldRowSkeleton(valueWidth: 172),
                SizedBox(height: AppDimens.paddingX12),
                _FieldRowSkeleton(valueWidth: 160),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A `label  value` line inside a card.
class _FieldRowSkeleton extends StatelessWidget {
  const _FieldRowSkeleton({required this.valueWidth});

  final double valueWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Matches the card's fixed label column, so the placeholder values
        // start exactly where the real ones will.
        const SizedBox(
          width: kDataCardLabelWidth,
          child: _LineBlock(width: 64, height: 12, radius: AppDimens.radiusX4),
        ),
        _LineBlock(width: valueWidth, height: 12, radius: AppDimens.radiusX4),
      ],
    );
  }
}

/// Placeholder for the settlements list.
///
/// Shaped as the cards it stands in for — the same panel, the amount over its
/// caption, a status pill, the identity and date lines, and the footer rule —
/// so the list does not visibly re-flow when the real settlements arrive. Only
/// the content shimmers: the card's own surface and hairline are drawn for
/// real, because a card that is already there reads as loading rather than as
/// missing.
class AccountSettlementListLoading extends StatelessWidget {
  const AccountSettlementListLoading({
    super.key,
    this.itemCount = 5,
    this.showSummary = false,
  });

  final int itemCount;

  /// Includes the four status tiles the loaded list shows above the rows.
  final bool showSummary;

  @override
  Widget build(BuildContext context) {
    final Widget run = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showSummary) ...<Widget>[
          const _SummaryRowSkeleton(),
          const SizedBox(height: AppDimens.paddingX12),
        ],
        for (int i = 0; i < itemCount; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppDimens.paddingX12),
          _SettlementCardSkeleton(withFooter: i.isEven),
        ],
      ],
    );

    // A full run of these is taller than a short phone's viewport. Given a
    // bounded height the run extends past the bottom inside a scroll view
    // instead of overflowing; given an unbounded one — inside a ListView or
    // another scroll view — it is returned as-is, so the two never nest.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedHeight) return run;
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: run,
        );
      },
    );
  }
}

/// Placeholder for the futsal breakdown.
///
/// Shaped as the venue cards it stands in for — name over location, the
/// commission and its caption opposite, the hairline, the figure rows and the
/// pay button — so the list does not visibly re-flow when the real futsals
/// arrive. Only the content shimmers; the card's surface and hairlines are
/// drawn for real.
class AccountVenueListLoading extends StatelessWidget {
  const AccountVenueListLoading({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final Widget run = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < itemCount; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppDimens.paddingX12),
          // Not every futsal can be settled, so not every card carries the
          // button — the run would read as a pattern otherwise.
          _VenueCardSkeleton(withAction: i.isEven),
        ],
      ],
    );

    // Given a bounded height the run extends past the bottom inside a scroll
    // view instead of overflowing; given an unbounded one it is returned as
    // is, so the two never nest.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedHeight) return run;
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: run,
        );
      },
    );
  }
}

/// One futsal card, unfilled.
class _VenueCardSkeleton extends StatelessWidget {
  const _VenueCardSkeleton({this.withAction = true});

  final bool withAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Name over location, with the commission and its caption opposite.
          const _AccountShimmer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _LineBlock(
                        width: 146,
                        height: 14,
                        radius: AppDimens.radiusX4,
                      ),
                      SizedBox(height: 4),
                      _LineBlock(
                        width: 104,
                        height: 11,
                        radius: AppDimens.radiusX4,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppDimens.paddingX8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _LineBlock(
                      width: 88,
                      height: 16,
                      radius: AppDimens.radiusX4,
                    ),
                    SizedBox(height: 3),
                    _LineBlock(
                      width: 68,
                      height: 9,
                      radius: AppDimens.radiusX4,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.paddingX8),
          const _AccountShimmer(
            child: Column(
              children: <Widget>[
                _VenueFigureRowSkeleton(labelWidth: 84, valueWidth: 74),
                SizedBox(height: AppDimens.paddingX4),
                _VenueFigureRowSkeleton(labelWidth: 104, valueWidth: 66),
              ],
            ),
          ),
          if (withAction) ...<Widget>[
            const SizedBox(height: AppDimens.paddingX10),
            const _AccountShimmer(
              child: _LineBlock(
                height: AppDimens.sizeX36,
                radius: AppDimens.radiusX8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A `label … amount` line in a venue card.
class _VenueFigureRowSkeleton extends StatelessWidget {
  const _VenueFigureRowSkeleton({
    required this.labelWidth,
    required this.valueWidth,
  });

  final double labelWidth;
  final double valueWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _LineBlock(width: labelWidth, height: 11, radius: AppDimens.radiusX4),
        const Spacer(),
        _LineBlock(width: valueWidth, height: 11, radius: AppDimens.radiusX4),
      ],
    );
  }
}

/// The status tiles above the list — Pending, Approved, Rejected.
class _SummaryRowSkeleton extends StatelessWidget {
  const _SummaryRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < 3; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.paddingX8,
                horizontal: AppDimens.paddingX6,
              ),
              decoration: BoxDecoration(
                color: LightColor.whiteColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                border: Border.all(color: LightColor.dividerColor),
              ),
              child: const _AccountShimmer(
                child: Column(
                  children: <Widget>[
                    _LineBlock(width: 22, height: 14, radius: AppDimens.radiusX4),
                    SizedBox(height: 4),
                    _LineBlock(width: 44, height: 10, radius: AppDimens.radiusX4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// One settlement card, unfilled.
class _SettlementCardSkeleton extends StatelessWidget {
  const _SettlementCardSkeleton({this.withFooter = true});

  /// The real card only shows its footer rule when it has a transaction
  /// reference or a proof, so not every placeholder carries one either.
  final bool withFooter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The amount leads, with its caption under it and the status pill
          // opposite — the same shape the card opens with.
          _AccountShimmer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _LineBlock(
                        width: 124,
                        height: 22,
                        radius: AppDimens.radiusX4,
                      ),
                      SizedBox(height: 4),
                      _LineBlock(
                        width: 92,
                        height: 13,
                        radius: AppDimens.radiusX4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX8),
                _LineBlock(
                  width: 74,
                  height: 22,
                  radius: AppDimens.radiusX20,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          const _AccountShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _LineBlock(width: 188, height: 13, radius: AppDimens.radiusX4),
                SizedBox(height: 4),
                _LineBlock(width: 146, height: 13, radius: AppDimens.radiusX4),
              ],
            ),
          ),
          if (withFooter) ...<Widget>[
            const SizedBox(height: AppDimens.paddingX10),
            // The card's own hairline, drawn for real.
            Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
            const SizedBox(height: AppDimens.paddingX6),
            const _AccountShimmer(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _LineBlock(
                      width: 132,
                      height: 10,
                      radius: AppDimens.radiusX4,
                    ),
                  ),
                  SizedBox(width: AppDimens.paddingX8),
                  _LineBlock(width: 64, height: 14, radius: AppDimens.radiusX4),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountShimmer extends StatelessWidget {
  const _AccountShimmer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: LightColor.iconGrey.withValues(alpha: 0.18),
      highlightColor: LightColor.skeletonHighlightColor.withValues(alpha: 0.85),
      period: const Duration(milliseconds: 1250),
      child: child,
    );
  }
}

class _BalanceCardSkeleton extends StatelessWidget {
  const _BalanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX20),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _CircleBlock(size: AppDimens.sizeX16),
              SizedBox(width: AppDimens.paddingX6),
              _LineBlock(width: 116, height: 13, radius: AppDimens.radiusX4),
            ],
          ),
          SizedBox(height: AppDimens.paddingX12),
          _LineBlock(width: 188, height: 34, radius: AppDimens.radiusX8),
          SizedBox(height: AppDimens.paddingX8),
          _LineBlock(width: 148, height: 12, radius: AppDimens.radiusX4),
          SizedBox(height: AppDimens.paddingX18),
          _LineBlock(height: AppDimens.sizeX40, radius: AppDimens.radiusX10),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(child: _StatSkeleton()),
        SizedBox(width: AppDimens.paddingX8),
        Expanded(child: _StatSkeleton()),
        SizedBox(width: AppDimens.paddingX8),
        Expanded(child: _StatSkeleton()),
      ],
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CircleBlock(size: AppDimens.sizeX16),
          SizedBox(height: AppDimens.paddingX8),
          _LineBlock(height: 14, radius: AppDimens.radiusX4),
          SizedBox(height: AppDimens.paddingX6),
          _LineBlock(width: 54, height: 10, radius: AppDimens.radiusX4),
        ],
      ),
    );
  }
}

class _ShortcutCardSkeleton extends StatelessWidget {
  const _ShortcutCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      ),
      child: Column(
        children: <Widget>[
          _ShortcutRowSkeleton(),
          Divider(height: 1, thickness: 0.5, color: LightColor.dividerColor),
          _ShortcutRowSkeleton(),
        ],
      ),
    );
  }
}

class _ShortcutRowSkeleton extends StatelessWidget {
  const _ShortcutRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX14,
        vertical: AppDimens.paddingX12,
      ),
      child: Row(
        children: <Widget>[
          _LineBlock(width: 36, height: 36, radius: AppDimens.radiusX10),
          SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _LineBlock(height: 13, radius: AppDimens.radiusX4),
                SizedBox(height: AppDimens.paddingX6),
                _LineBlock(width: 104, height: 10, radius: AppDimens.radiusX4),
              ],
            ),
          ),
          SizedBox(width: AppDimens.paddingX12),
          _CircleBlock(size: AppDimens.sizeX18),
        ],
      ),
    );
  }
}

class _LineBlock extends StatelessWidget {
  const _LineBlock({
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
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _CircleBlock extends StatelessWidget {
  const _CircleBlock({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
