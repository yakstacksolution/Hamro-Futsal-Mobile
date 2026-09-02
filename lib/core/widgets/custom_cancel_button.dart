import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';

/// A reusable outlined cancel/dismiss button.
///
/// Wraps [CustomButton] with cancel-appropriate defaults (outlined, neutral
/// text colour). By default it pops the current route, so it can be dropped
/// straight into a bottom sheet's action row.
class CustomCancelButton extends StatelessWidget {
  const CustomCancelButton({
    super.key,
    this.text = StringConstants.cancel,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.minHeight = AppDimens.sizeX42,
  });

  /// Label shown on the button. Defaults to the localized "Cancel".
  final String text;

  /// Called when tapped. When null the button simply pops the current route.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Shows a spinner and disables interaction while true.
  final bool isLoading;

  /// Minimum button height.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      icon: icon,
      isLoading: isLoading,
      isOutlined: true,
      foregroundColor: LightColor.secondaryTextColor,
      borderColor: LightColor.secondaryTextColor,
      minHeight: minHeight,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
