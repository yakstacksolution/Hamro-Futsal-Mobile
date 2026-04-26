import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor = LightColor.secondaryColor,
    this.foregroundColor = LightColor.inverseTextColor,
    this.borderColor,
    this.isOutlined = false,
    this.widthFactor,
    this.minHeight = AppDimens.sizeX46,
    
    this.verticalPadding = AppDimens.paddingX4,
    this.borderRadius = AppDimens.radiusX8,
    this.fontSize = AppDimens.fontBodyTextSmall,
    this.fontWeight = FontWeight.w600,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool isOutlined;
  final double? widthFactor;
  final double minHeight;
  final double verticalPadding;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final resolvedBackground = isOutlined
        ? LightColor.transparentColor
        : backgroundColor;
    final resolvedBorderColor =
        borderColor ?? (isOutlined ? foregroundColor : null);

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.7,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size:AppDimens.sizeX18, color: foregroundColor),
                SizedBox(width: AppDimens.sizeX6),
              ],
              Text(
                text,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: foregroundColor,
                      fontWeight: fontWeight,
                      fontSize: fontSize,
                    ),
              ),
            ],
          );

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
        minimumSize: WidgetStateProperty.all<Size>(Size(0, minHeight)),
        overlayColor: WidgetStateProperty.all(
          foregroundColor.withValues(alpha: isOutlined ? 0.08 : 0.12),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          FutsalTheme.getTextTheme(context).bodyTextLarge!.copyWith(
            color: foregroundColor,
            fontWeight: fontWeight,
            fontSize: fontSize,
          ),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        side: WidgetStateProperty.all<BorderSide?>(
          resolvedBorderColor == null
              ? null
              : BorderSide(color: resolvedBorderColor, width: 1.4),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(resolvedBackground),
        foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),
      ),
      child: Container(
        alignment: Alignment.center,
        width: widthFactor != null
            ? MediaQuery.sizeOf(context).width * widthFactor!
            : double.infinity,
        padding: appUtils.getPadding(
          symmetricVertical: verticalPadding,
          symmetricHorizontal: AppDimens.paddingX12,
        ),
        child: content,
      ),
    );
  }
}
