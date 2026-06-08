import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showCourts = true,
    this.showWishlist = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Courts is a vendor-only tab — hidden for candidates. Tab indices stay
  /// stable so the dashboard's index → page mapping is unaffected.
  final bool showCourts;

  /// Wishlist is a candidate-only tab — hidden for vendors.
  final bool showWishlist;

  /// Indices of the role-dependent entries in [_items].
  static const int _courtsIndex = 1;
  static const int _wishlistIndex = 4;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.sports_soccer_outlined,
      activeIcon: Icons.sports_soccer,
      label: 'Courts',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Bookings',
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chat',
    ),
    _NavItem(
      icon: Icons.favorite_outline_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Wishlist',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: LightColor.whiteColor,
        border: Border(
          top: BorderSide(color: LightColor.dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX12,
            symmetricVertical: AppDimens.paddingX8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (int index = 0; index < _items.length; index++)
                if ((showCourts || index != _courtsIndex) &&
                    (showWishlist || index != _wishlistIndex))
                  _NavBarItem(
                    item: _items[index],
                    isActive: currentIndex == index,
                    onTap: () => onTap(index),
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

  final _NavItem item;
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
          padding: AppUtils().getPadding(
            symmetricHorizontal: widget.isActive
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
              Icon(
                widget.isActive ? widget.item.activeIcon : widget.item.icon,
                size: AppDimens.sizeX20,
                color: widget.isActive
                    ? LightColor.whiteColor
                    : LightColor.secondaryTextColor,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: widget.isActive
                    ? Padding(
                        padding: AppUtils().getPadding(
                          left: AppDimens.paddingX6,
                        ),
                        child: Text(
                          widget.item.label,
                          style: FutsalTheme.getTextTheme(context).bodyTextSmall
                              ?.copyWith(
                                color: LightColor.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
