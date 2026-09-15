import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/dashboard_nav_destinations.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static double heightOf(BuildContext context) {
    final double labelHeight =
        MediaQuery.textScalerOf(context).scale(AppDimens.fontBodyTextSmall) *
        1.4;
    final double itemHeight =
        math.max(AppDimens.sizeX20, labelHeight) + AppDimens.paddingX8 * 2;
    return itemHeight +
        AppDimens.paddingX8 * 2 +
        1 + // top divider
        MediaQuery.viewPaddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(
          top: BorderSide(color: LightColor.dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Loosely flexible, and the active destination gets the
              // larger share.
              //
              // Only the active one shows a label, so an equal split starved
              // it — each item was capped at a fifth of the bar and "Chat"
              // came out as "C…" with the rest of the bar empty. Weighting it
              // lets it take the room it needs while the icon-only items keep
              // theirs; loose fit means every item still stops at its natural
              // width, and only gives ground if the bar genuinely runs out —
              // which is what keeps a large text scale from overflowing.
              for (
                int index = 0;
                index < dashboardNavDestinations.length;
                index++
              )
                Flexible(
                  flex: currentIndex == index ? 4 : 1,
                  child: _NavBarItem(
                    item: dashboardNavDestinations[index],
                    isActive: currentIndex == index,
                    onTap: () => onTap(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final DashboardNavDestination item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(
      begin: 1,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTap() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (BuildContext context, Widget? child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isActive
                ? AppDimens.paddingX12
                : AppDimens.paddingX8,
            vertical: AppDimens.paddingX8,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? LightColor.secondaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomImageView(
                imagePath: widget.isActive
                    ? widget.item.activeIcon
                    : widget.item.icon,
                width: AppDimens.sizeX20,
                height: AppDimens.sizeX20,
                fit: BoxFit.contain,
                color: widget.isActive
                    ? LightColor.inverseTextColor
                    : LightColor.secondaryTextColor,
              ),
              // Flexible so the label gives way inside the pill once the pill
              // itself is squeezed; without it the shrinking happens one level
              // too high and this Row overflows instead.
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: widget.isActive
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: AppDimens.paddingX6,
                          ),
                          child: Text(
                            widget.item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FutsalTheme.getTextTheme(context)
                                .bodyTextSmall
                                ?.copyWith(
                                  color: LightColor.inverseTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
