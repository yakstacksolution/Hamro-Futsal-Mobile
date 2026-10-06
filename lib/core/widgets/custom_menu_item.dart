import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

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
