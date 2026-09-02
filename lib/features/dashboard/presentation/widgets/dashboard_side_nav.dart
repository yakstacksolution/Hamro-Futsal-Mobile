import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/dashboard_nav_destinations.dart';

/// Side navigation shown instead of the bottom bar on tablet and desktop.
///
/// Renders the same [dashboardNavDestinations] as [CustomBottomNavigationBar]
/// and takes the same `currentIndex` / `onTap` contract, so the shell can swap
/// one for the other without any other change.
///
/// * [extended] `false` — icon-only rail, [AppDimens.dashboardRailWidth] wide,
///   labels surfaced through tooltips (tablet, 600-900).
/// * [extended] `true` — icons plus labels, [AppDimens.dashboardRailExtendedWidth]
///   wide (desktop, >=900).
class DashboardSideNav extends StatelessWidget {
  const DashboardSideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: extended
          ? AppDimens.dashboardRailExtendedWidth
          : AppDimens.dashboardRailWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border(
            right: BorderSide(color: LightColor.dividerColor, width: 1),
          ),
        ),
        child: SafeArea(
          right: false,
          // Short windows can still reach the last destination.
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX10,
                vertical: AppDimens.paddingX16,
              ),
              // Destinations sit at the top-left of the pane: the column
              // shrink-wraps to the top and each item aligns to the left edge.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (
                    int index = 0;
                    index < dashboardNavDestinations.length;
                    index++
                  ) ...<Widget>[
                    if (index > 0) const SizedBox(height: AppDimens.sizeX8),
                    _SideNavItem(
                      destination: dashboardNavDestinations[index],
                      isActive: currentIndex == index,
                      extended: extended,
                      onTap: () => onTap(index),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.destination,
    required this.isActive,
    required this.extended,
    required this.onTap,
  });

  final DashboardNavDestination destination;
  final bool isActive;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Same active treatment as the bottom bar's item: secondary-colour pill,
    // filled icon, white content.
    final Color foreground = isActive
        ? LightColor.inverseTextColor
        : LightColor.secondaryTextColor;

    final Widget icon = CustomImageView(
      imagePath: isActive ? destination.activeIcon : destination.icon,
      width: AppDimens.sizeX20,
      height: AppDimens.sizeX20,
      fit: BoxFit.contain,
      color: foreground,
    );

    final Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: extended ? AppDimens.paddingX14 : AppDimens.paddingX10,
        vertical: AppDimens.paddingX12,
      ),
      decoration: BoxDecoration(
        color: isActive ? LightColor.secondaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      ),
      child: extended
          ? Row(
              children: <Widget>[
                icon,
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: Text(
                    destination.label,
                    overflow: TextOverflow.ellipsis,
                    style: FutsalTheme.getTextTheme(context).bodyTextSmall
                        ?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: AppDimens.fontBodyTextMedium,
                        ),
                  ),
                ),
              ],
            )
          : Align(alignment: Alignment.centerLeft, child: icon),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: SizedBox(
          width: double.infinity,
          // The label is only visible when extended, so the collapsed rail
          // needs the tooltip to stay usable.
          child: extended
              ? content
              : Tooltip(message: destination.label, child: content),
        ),
      ),
    );
  }
}
