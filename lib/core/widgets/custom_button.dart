import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
    this.enableHapticFeedback = true,
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

  /// Whether a tap answers with the standard light haptic tick.
  ///
  /// Almost every button in the app is a [CustomButton], so the feedback is
  /// defined once here instead of at each call site. Turn it off for a button
  /// that fires repeatedly (a stepper's +/-) or whose action already buzzes.
  final bool enableHapticFeedback;

  /// The tap handler with the haptic tick attached.
  ///
  /// Null while loading or when no handler was given, which is also what
  /// disables the underlying [TextButton].
  VoidCallback? get _onTap {
    final VoidCallback? callback = onPressed;
    if (isLoading || callback == null) return null;
    if (!enableHapticFeedback) return callback;
    return () {
      HapticFeedback.lightImpact();
      callback();
    };
  }

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
        onPressed: _onTap,

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
        // Fills the parent when the width is bounded and hugs the label when
        // it is not — a `Row` decides that itself (`RenderFlex` falls back to
        // its children's width under unbounded constraints), where an explicit
        // `double.infinity` brought the whole subtree down.
        //
        // Deliberately not a LayoutBuilder: it cannot answer an intrinsic
        // measurement, and anything that asks for one — `AlertDialog`'s
        // actions go through an `OverflowBar`, an `IntrinsicWidth`, a
        // `DataTable` — threw "LayoutBuilder does not support returning
        // intrinsic dimensions". Every widget below reports intrinsics.
        child: Padding(
          padding: appUtils.getPadding(
            symmetricVertical: verticalPadding,
            symmetricHorizontal: AppDimens.paddingX12,
          ),
          child: widthFactor != null
              ? SizedBox(
                  width: MediaQuery.sizeOf(context).width * widthFactor!,
                  child: Center(child: content),
                )
              : _FillWidthIfBounded(child: content),
        ),
      ),
    );
  }
}

/// Fills the width it is offered when that width is bounded, and shrink-wraps
/// its child when it is not — a button in a `Row` without an `Expanded`, or in
/// a horizontal scrollable, is measured with unbounded width.
///
/// A `LayoutBuilder` used to make that decision here. It cannot answer an
/// intrinsic measurement, so every ancestor that asks for one — `AlertDialog`
/// lays its actions out in an `OverflowBar`, and `IntrinsicWidth` and
/// `DataTable` do the same — threw "LayoutBuilder does not support returning
/// intrinsic dimensions" instead of laying out. This reports intrinsics
/// straight from the child.
class _FillWidthIfBounded extends SingleChildRenderObjectWidget {
  const _FillWidthIfBounded({required Widget super.child});

  @override
  _RenderFillWidthIfBounded createRenderObject(BuildContext context) =>
      _RenderFillWidthIfBounded();
}

class _RenderFillWidthIfBounded extends RenderShiftedBox {
  _RenderFillWidthIfBounded() : super(null);

  @override
  double computeMinIntrinsicWidth(double height) =>
      child?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      child?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      child?.getMinIntrinsicHeight(width) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      child?.getMaxIntrinsicHeight(width) ?? 0;

  Size _sizeFor(BoxConstraints constraints, Size childSize) =>
      constraints.constrain(
        Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : childSize.width,
          childSize.height,
        ),
      );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) return constraints.smallest;
    return _sizeFor(constraints, child.getDryLayout(constraints.loosen()));
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    // Loosened, never tight: the label's FittedBox needs a real maximum to
    // scale down against, and the loading spinner must keep its own size.
    child.layout(constraints.loosen(), parentUsesSize: true);
    size = _sizeFor(constraints, child.size);
    (child.parentData! as BoxParentData).offset = Offset(
      (size.width - child.size.width) / 2,
      (size.height - child.size.height) / 2,
    );
  }
}
