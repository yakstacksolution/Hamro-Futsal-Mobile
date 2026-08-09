import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

/// Rounded label + count pill for the messages filter row.
class MessageFilterChip extends StatelessWidget {
  const MessageFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isSelected
                      ? LightColor.inverseTextColor
                      : LightColor.secondaryTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: AppDimens.paddingX6),
                Text(
                  count.toString(),
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: isSelected
                        ? LightColor.inverseTextColor.withValues(alpha: 0.7)
                        : LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
