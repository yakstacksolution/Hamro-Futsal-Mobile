import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';

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
    // The label and icon are painted with explicit colours below, which beat
    // the ButtonStyle's disabled resolution — so they are dimmed here too.
    final bool isDisabled = onPressed == null || isLoading;
    final Color resolvedBackground = isOutlined
        ? LightColor.transparentColor
        : (backgroundColor ?? scheme.primary);
    // Outlined buttons paint their label on the page, so they take the brand
    // colour; filled buttons take the on-primary foreground.
    final Color resolvedForeground =
        foregroundColor ?? (isOutlined ? scheme.primary : scheme.onPrimary);
    final Color? resolvedBorderColor =
        borderColor ?? (isOutlined ? resolvedForeground : null);
    final Color labelColor = isDisabled
        ? resolvedForeground.withValues(alpha: 0.55)
        : resolvedForeground;

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
                Icon(icon, size: AppDimens.sizeX18, color: labelColor),
                SizedBox(width: AppDimens.sizeX6),
              ],
              // A label wider than the button used to overflow the row (a
              // two-button dialog gives each side about half the width).
              // Flexible hands it the space that is actually left and
              // scaleDown shrinks it to fit, so a long label stays readable
              // instead of throwing or ellipsising.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    maxLines: 1,
                    softWrap: false,
                    style: FutsalTheme.getTextTheme(context).bodyTextSmall
                        ?.copyWith(
                          color: labelColor,
                          fontWeight: fontWeight,
                          fontSize: fontSize,
                        ),
                  ),
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
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) => resolvedBorderColor == null
                ? null
                : BorderSide(
                    color: states.contains(WidgetState.disabled)
                        ? resolvedBorderColor.withValues(alpha: 0.45)
                        : resolvedBorderColor,
                    width: 1.4,
                  ),
          ),

          // A disabled button has to *look* disabled. These were painted with
          // `all()`, so `onPressed: null` rendered identically to a live
          // button — the tap did nothing and the user had no way to tell why.
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? (isOutlined
                      ? LightColor.transparentColor
                      : resolvedBackground.withValues(alpha: 0.38))
                : resolvedBackground,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? resolvedForeground.withValues(alpha: 0.55)
                : resolvedForeground,
          ),
        ),
        // `double.infinity` fills the parent when the width is bounded, but is
        // an invalid constraint when it is not — a button placed straight into
        // a Row or a scrollable's cross axis got infinite width and brought the
        // whole subtree down. Sizing to the content there instead.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              Container(
                alignment: Alignment.center,
                width: widthFactor != null
                    ? MediaQuery.sizeOf(context).width * widthFactor!
                    : (constraints.hasBoundedWidth ? double.infinity : null),
                padding: appUtils.getPadding(
                  symmetricVertical: verticalPadding,
                  symmetricHorizontal: AppDimens.paddingX12,
                ),
                child: content,
              ),
        ),
      ),
    );
  }
}
