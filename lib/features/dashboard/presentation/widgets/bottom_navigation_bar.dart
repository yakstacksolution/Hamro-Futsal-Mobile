import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/image_constants.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
 
  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(
      icon: ImageConstants.navHome,
      activeIcon: ImageConstants.navHomeFill,
      label: 'Home',
    ),
    _NavItem(
      icon: ImageConstants.navBooking,
      activeIcon: ImageConstants.navBookingFill,
      label: 'Bookings',
    ),
    _NavItem(
      icon: ImageConstants.navMessage,
      activeIcon: ImageConstants.navMessageFill,
      label: 'Chat',
    ),
    _NavItem(
      icon: ImageConstants.navHeart,
      activeIcon: ImageConstants.navHeartFill,
      label: 'Wishlist',
    ),
    _NavItem(
      icon: ImageConstants.navProfile,
      activeIcon: ImageConstants.navProfileFill,
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
              CustomImageView(
                imagePath : widget.isActive
                    ? widget.item.activeIcon
                    : widget.item.icon,
                width: AppDimens.sizeX20,
                height: AppDimens.sizeX20,
                fit: BoxFit.contain,
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

  /// Asset path for the inactive (outline) icon.
  final String icon;

  /// Asset path for the active (filled) icon.
  final String activeIcon;
  final String label;
}
