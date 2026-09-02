import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
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
      child: _AccountShimmer(
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
            SizedBox(height: AppDimens.paddingX10),
            _ListCardSkeleton(itemCount: 4),
          ],
        ),
      ),
    );
  }
}

class AccountListLoading extends StatelessWidget {
  const AccountListLoading({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return _AccountShimmer(
      child: _ListCardSkeleton(itemCount: itemCount, includeOuterCard: false),
    );
  }
}

class AccountSettlementListLoading extends StatelessWidget {
  const AccountSettlementListLoading({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return _AccountShimmer(
      child: Column(
        // Shimmer paints its gradient across the whole of its child's bounds.
        // A max-size Column fills the viewport, so the sweep ran over the entire
        // screen instead of the rows — mainAxisSize.min keeps it on the rows.
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < itemCount; i++) ...<Widget>[
            if (i > 0)
              Divider(
                height: AppDimens.paddingX24,
                thickness: 1,
                color: LightColor.dividerColor,
              ),
            const _SettlementRowSkeleton(),
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

class _ListCardSkeleton extends StatelessWidget {
  const _ListCardSkeleton({
    required this.itemCount,
    this.includeOuterCard = true,
  });

  final int itemCount;
  final bool includeOuterCard;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < itemCount; i++) ...<Widget>[
          if (i > 0)
            Divider(
              height: AppDimens.paddingX20,
              thickness: 1,
              color: LightColor.dividerColor,
            ),
          _ActivityRowSkeleton(shortAmount: i.isOdd),
        ],
      ],
    );

    if (!includeOuterCard) return child;
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      ),
      child: child,
    );
  }
}

class _ActivityRowSkeleton extends StatelessWidget {
  const _ActivityRowSkeleton({this.shortAmount = false});

  final bool shortAmount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _LineBlock(width: 40, height: 40, radius: AppDimens.radiusX10),
        const SizedBox(width: AppDimens.paddingX12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _LineBlock(height: 13, radius: AppDimens.radiusX4),
              SizedBox(height: AppDimens.paddingX6),
              _LineBlock(width: 132, height: 10, radius: AppDimens.radiusX4),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        _LineBlock(
          width: shortAmount ? 54 : 76,
          height: 13,
          radius: AppDimens.radiusX4,
        ),
      ],
    );
  }
}

class _SettlementRowSkeleton extends StatelessWidget {
  const _SettlementRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        _LineBlock(width: 40, height: 40, radius: AppDimens.radiusX10),
        SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _LineBlock(width: 112, height: 14, radius: AppDimens.radiusX4),
              SizedBox(height: AppDimens.paddingX6),
              _LineBlock(width: 156, height: 10, radius: AppDimens.radiusX4),
            ],
          ),
        ),
        SizedBox(width: AppDimens.paddingX12),
        _LineBlock(width: 72, height: 24, radius: AppDimens.radiusX20),
      ],
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
