import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

/// A reusable popup-menu entry styled to match the app's UI.
///
/// Renders a leading [icon] and a [label] with app typography/colours. Use it
/// as the `child` of a [PopupMenuItem] so every menu across the app shares the
/// same look:
///
/// ```dart
/// PopupMenuItem<T>(
///   value: value,
///   child: const CustomMenuItem(icon: Icons.done_rounded, label: 'Mark read'),
/// )
/// ```
class CustomMenuItem extends StatelessWidget {
  const CustomMenuItem({
    super.key,
    this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
    this.fontSize = 12,
    this.isDestructive = false,
  });

  final IconData? icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final double fontSize;

  /// Tints the item in the app's error colour for delete/remove style actions.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color resolvedColor = isDestructive
        ? LightColor.redColor
        : (labelColor ?? LightColor.primaryTextColor);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(
            icon,
            size: AppDimens.sizeX18,
            color: iconColor ?? resolvedColor,
          ),
          const SizedBox(width: AppDimens.sizeX10),
        ],
        Text(
          label,
          style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
