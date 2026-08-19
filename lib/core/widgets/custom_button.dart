import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.isOutlined = false,
    this.widthFactor,
    this.minHeight = AppDimens.sizeX46,
    this.minWidth = AppDimens.sizeX100,
    this.verticalPadding = AppDimens.paddingX4,
    this.borderRadius = AppDimens.radiusX8,
    this.fontSize = AppDimens.fontBodyTextSmall,
    this.fontWeight = FontWeight.w600,
    this.margin,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool isOutlined;
  final double? widthFactor;
  final double minHeight;
  final double minWidth;
  final double verticalPadding;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color resolvedBackground = isOutlined
        ? LightColor.transparentColor
        : (backgroundColor ?? scheme.primary);
    // Outlined buttons paint their label on the page, so they take the brand
    // colour; filled buttons take the on-primary foreground.
    final Color resolvedForeground =
        foregroundColor ?? (isOutlined ? scheme.primary : scheme.onPrimary);
    final Color? resolvedBorderColor =
        borderColor ?? (isOutlined ? resolvedForeground : null);

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: LoadingWidget(isButtonLoading: true),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                // `resolvedForeground`, never the raw nullable field: an
                // explicit style wins over the ButtonStyle, so passing null
                // here silently fell back to the text theme's primaryText —
                // dark-on-green in light mode.
                Icon(icon, size: AppDimens.sizeX18, color: resolvedForeground),
                SizedBox(width: AppDimens.sizeX6),
              ],
              Text(
                text,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: resolvedForeground,
                      fontWeight: fontWeight,
                      fontSize: fontSize,
                    ),
              ),
            ],
          );

    return SizedBox(
      child: TextButton(
        onPressed: isLoading ? null : onPressed,

        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          minimumSize: WidgetStateProperty.all<Size>(Size(minWidth, minHeight)),
          overlayColor: WidgetStateProperty.all(
            resolvedForeground.withValues(alpha: isOutlined ? 0.08 : 0.12),
          ),
          textStyle: WidgetStateProperty.all<TextStyle>(
            FutsalTheme.getTextTheme(context).bodyTextLarge!.copyWith(
              color: resolvedForeground,
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
          foregroundColor: WidgetStateProperty.all<Color>(resolvedForeground),
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
      ),
    );
  }
}
