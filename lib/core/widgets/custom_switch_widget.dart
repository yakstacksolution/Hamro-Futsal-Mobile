import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';

class CustomSwitchWidget extends StatelessWidget {
  const CustomSwitchWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.width = 40,
    this.height = 24,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double width;
  final double height;
  final bool enabled;

  bool get _isInteractive => enabled && onChanged != null;

  void _handleToggle() {
    if (_isInteractive) onChanged!.call(!value);
  }

  @override
  Widget build(BuildContext context) {
    final double thumbSize = height - 4;
    final double trackRadius = height / 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: width,
        height: height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value
              ? activeColor ?? Theme.of(context).colorScheme.primary
              : inactiveColor ?? context.appColors.divider,
          borderRadius: BorderRadius.circular(trackRadius),
        ),
        child: Stack(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color:
                    thumbColor ??
                    (value
                        ? Theme.of(context).colorScheme.onPrimary
                        : context.appColors.surfaceElevated),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: LightColor.shadowColor,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
