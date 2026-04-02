import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

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
    // _NavItem(
    //   icon: Icons.bar_chart_outlined,
    //   activeIcon: Icons.bar_chart,
    //   label: 'Analytics',
    // ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaceColor = Color.alphaBlend(
      colorScheme.secondary.withValues(alpha: 0.03),
      colorScheme.surface,
    );
    final glowColor = colorScheme.secondary;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, -3),
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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

// ─────────────────────────────────────────────────────────────────────────────

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
  // Original scale controller — unchanged
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  // ✅ New ripple controller
  late final AnimationController _rippleController;
  late final Animation<double> _rippleRadius;
  late final Animation<double> _rippleOpacity;

  @override
  void initState() {
    super.initState();

    // Original — unchanged
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    // Ripple: expands from 0 → 1 (radius) while fading 0.35 → 0 (opacity)
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
    // Original scale pulse — unchanged
    _scaleController.forward().then((_) => _scaleController.reverse());
    // Fire ripple from zero each tap
    _rippleController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = colorScheme.secondary;
    final activeTextColor = colorScheme.secondary;
    final inactiveColor = LightColor.subTitleTextColor;
    final activeBackground = Color.alphaBlend(
      colorScheme.secondary.withValues(alpha: 0.08),
      colorScheme.secondary.withValues(alpha: 0.1),
    );

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (BuildContext context, Widget? child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        // ✅ ClipOval keeps the ripple from bleeding outside the item bounds
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: AnimatedBuilder(
            animation: _rippleController,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                painter: _RipplePainter(
                  color: activeColor,
                  radiusProgress: _rippleRadius.value,
                  opacity: _rippleOpacity.value,
                ),
                child: child,
              );
            },
            // ── Original AnimatedContainer — completely unchanged ──────────
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isActive ? 12 : 9,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: widget.isActive ? activeBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: widget.isActive
                    ? Border.all(color: activeColor.withValues(alpha: 0.16))
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
                      size: 20,
                      color: widget.isActive ? activeColor : inactiveColor,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: widget.isActive
                        ? Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              widget.item.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: activeTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
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

// ✅ Paints an expanding circle that fades out from the widget center
class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.color,
    required this.radiusProgress, // 0.0 → 1.0
    required this.opacity, // 0.35 → 0.0
  });

  final Color color;
  final double radiusProgress;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    // Max radius reaches the farthest corner of the widget
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

// ─────────────────────────────────────────────────────────────────────────────

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

// import 'package:flutter/material.dart';
// import 'package:hamro_footsall/core/theme/light_color.dart';

// class CustomBottomNavigationBar extends StatelessWidget {
//   const CustomBottomNavigationBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   static const List<_NavItem> _items = <_NavItem>[
//     _NavItem(
//       icon: Icons.home_outlined,
//       activeIcon: Icons.home_rounded,
//       label: 'Home',
//     ),

//     _NavItem(
//       icon: Icons.sports_soccer_outlined,
//       activeIcon: Icons.sports_soccer,
//       label: 'Courts',
//     ),

//     _NavItem(
//       icon: Icons.calendar_month_outlined,
//       activeIcon: Icons.calendar_month,
//       label: 'Bookings',
//     ),

//     _NavItem(
//       icon: Icons.chat_bubble_outline,
//       activeIcon: Icons.chat_bubble,
//       label: 'Chat',
//     ),

//     _NavItem(
//       icon: Icons.bar_chart_outlined,
//       activeIcon: Icons.bar_chart,
//       label: 'Analytics',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final surfaceColor = Color.alphaBlend(
//       colorScheme.secondary.withValues(alpha: 0.03),
//       colorScheme.surface,
//     );
//     final borderColor = colorScheme.outline.withValues(alpha: 0.85);
//     final glowColor = colorScheme.secondary;

//     return Container(
//       decoration: BoxDecoration(
//         color: surfaceColor,
//         border: Border(top: BorderSide(color: borderColor, width: 1)),
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//             color: glowColor.withValues(alpha: 0.12),
//             blurRadius: 20,
//             offset: const Offset(0, -6),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: List<Widget>.generate(_items.length, (int index) {
//               final item = _items[index];
//               final isActive = currentIndex == index;
//               return _NavBarItem(
//                 item: item,
//                 isActive: isActive,
//                 onTap: () => onTap(index),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NavBarItem extends StatefulWidget {
//   const _NavBarItem({
//     required this.item,
//     required this.isActive,
//     required this.onTap,
//   });

//   final _NavItem item;
//   final bool isActive;
//   final VoidCallback onTap;

//   @override
//   State<_NavBarItem> createState() => _NavBarItemState();
// }

// class _NavBarItemState extends State<_NavBarItem>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _scaleAnim;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _scaleAnim = Tween<double>(
//       begin: 1,
//       end: 0.88,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onTap() {
//     _controller.forward().then((_) => _controller.reverse());
//     widget.onTap();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final activeColor = colorScheme.secondary;
//     final activeTextColor = colorScheme.secondary;
//     final inactiveColor = LightColor.subTitleTextColor;
//     final activeBackground = Color.alphaBlend(
//       colorScheme.secondary.withValues(alpha: 0.08),
//       colorScheme.secondary.withValues(alpha: 0.1),
//     );

//     return GestureDetector(
//       onTap: _onTap,
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedBuilder(
//         animation: _scaleAnim,
//         builder: (BuildContext context, Widget? child) {
//           return Transform.scale(scale: _scaleAnim.value, child: child);
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 260),
//           curve: Curves.easeInOut,
//           padding: EdgeInsets.symmetric(
//             horizontal: widget.isActive ? 12 : 9,
//             vertical: 7,
//           ),
//           decoration: BoxDecoration(
//             color: widget.isActive ? activeBackground : Colors.transparent,
//             borderRadius: BorderRadius.circular(7),
//             border: widget.isActive
//                 ? Border.all(color: activeColor.withValues(alpha: 0.16))
//                 : null,
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 220),
//                 transitionBuilder: (Widget child, Animation<double> animation) {
//                   return ScaleTransition(scale: animation, child: child);
//                 },
//                 child: Icon(
//                   widget.isActive ? widget.item.activeIcon : widget.item.icon,
//                   key: ValueKey<bool>(widget.isActive),
//                   size: 20,
//                   color: widget.isActive ? activeColor : inactiveColor,
//                 ),
//               ),
//               AnimatedSize(
//                 duration: const Duration(milliseconds: 260),
//                 curve: Curves.easeInOut,
//                 child: widget.isActive
//                     ? Padding(
//                         padding: const EdgeInsets.only(left: 6),
//                         child: Text(
//                           widget.item.label,
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: activeTextColor,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 11,
//                           ),
//                         ),
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NavItem {
//   const _NavItem({
//     required this.icon,
//     required this.activeIcon,
//     required this.label,
//   });

//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
// }
