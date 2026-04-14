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
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

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
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Analytics',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusX16),
          topRight: Radius.circular(AppDimens.radiusX16),
        ),
        boxShadow: [
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.06),
            blurRadius: AppDimens.radiusX16,
            spreadRadius: 1,
            offset: const Offset(0, -3),
          ),
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.03),
            blurRadius: AppDimens.radiusX6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX8,
            vertical: AppDimens.paddingX6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(_items.length, (int index) {
              final item = _items[index];
              final isActive = currentIndex == index;
              return _NavBarItem(
                item: item,
                isActive: isActive,
                onTap: () => onTap(index),
              );
            }),
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
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  late final AnimationController _rippleController;
  late final Animation<double> _rippleRadius;
  late final Animation<double> _rippleOpacity;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _rippleRadius = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween<double>(
      begin: 0.35,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _rippleController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onTap() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    _rippleController.forward(from: 0.0);
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: AnimatedBuilder(
            animation: _rippleController,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                painter: _RipplePainter(
                  color: LightColor.secondaryLight,
                  radiusProgress: _rippleRadius.value,
                  opacity: _rippleOpacity.value,
                ),
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
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
                borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                border: widget.isActive
                    ? Border.all(
                        color: LightColor.secondaryColor.withValues(
                          alpha: 0.16,
                        ),
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) =>
                            ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      widget.isActive
                          ? widget.item.activeIcon
                          : widget.item.icon,
                      key: ValueKey<bool>(widget.isActive),
                      size: AppDimens.sizeX20,
                      color: widget.isActive
                          ? LightColor.whiteColor
                          : LightColor.secondaryTextColor,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: widget.isActive
                        ? Padding(
                            padding: AppUtils().getPadding(
                              left: AppDimens.paddingX6,
                            ),
                            child: Text(
                              widget.item.label,

                              style: FutsalTheme.getTextTheme(context)
                                  .bodyTextSmall
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
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.color,
    required this.radiusProgress,
    required this.opacity,
  });

  final Color color;
  final double radiusProgress;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (Offset(size.width, size.height) - center).distance * 1.1;
    final radius = maxRadius * radiusProgress;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.radiusProgress != radiusProgress || old.opacity != opacity;
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
