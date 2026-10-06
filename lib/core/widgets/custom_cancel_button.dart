import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';

class CustomCancelButton extends StatelessWidget {
  const CustomCancelButton({
    super.key,
    this.text = StringConstants.cancel,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.minHeight = AppDimens.sizeX42,
  });

  final String text;

  final VoidCallback? onPressed;

  final IconData? icon;

  final bool isLoading;

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
