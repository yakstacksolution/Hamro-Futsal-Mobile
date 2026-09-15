import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

enum CheckboxLabelPosition { left, right }

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelWidget,
    this.labelPosition = CheckboxLabelPosition.right,
    this.textStyle,
    this.activeColor,
    this.inactiveColor,
    this.borderColor,
    this.checkColor,
    this.size = AppDimens.sizeX20,
    this.spacing = AppDimens.sizeX8,
    this.isExpanded = false,
    this.enabled = true,
  }) : assert(label != null || labelWidget != null);

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Widget? labelWidget;
  final CheckboxLabelPosition labelPosition;
  final TextStyle? textStyle;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? borderColor;
  final Color? checkColor;
  final double size;
  final double spacing;
  final bool isExpanded;
  final bool enabled;

  bool get _isInteractive => enabled && onChanged != null;

  void _handleToggle() {
    if (_isInteractive) {
      onChanged!.call(!value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color resolvedActive = activeColor ?? scheme.primary;
    final Color resolvedBorder = borderColor ?? context.appColors.border;
    final Color resolvedCheck = checkColor ?? scheme.onPrimary;
    final TextStyle resolvedStyle =
        textStyle ??
        FutsalTheme.getTextTheme(
          context,
        ).bodyTextSmall!.copyWith(color: LightColor.secondaryTextColor);

    final Widget labelContent =
        labelWidget ?? Text(label!, style: resolvedStyle);

    final Widget checkbox = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: value
            ? resolvedActive
            : inactiveColor ?? context.appColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusX4),
        border: Border.all(
          color: value ? resolvedActive : resolvedBorder,
          width: 1.2,
        ),
      ),
      child: value
          ? Icon(Icons.check_rounded, size: size * 0.72, color: resolvedCheck)
          : null,
    );

    return Semantics(
      checked: value,
      enabled: _isInteractive,
      inMutuallyExclusiveGroup: false,
      child: InkWell(
        onTap: _isInteractive ? _handleToggle : null,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Padding(
          padding: appUtils.getPadding(
            symmetricHorizontal: AppDimens.paddingX2,
            symmetricVertical: AppDimens.paddingX2,
          ),
          // Deliberately not a LayoutBuilder: it cannot answer an intrinsic
          // measurement, so any ancestor that asks for one — an
          // `IntrinsicHeight` row, an `IntrinsicWidth`, `AlertDialog`'s
          // `OverflowBar`, a scrollable `TabBar` — threw "LayoutBuilder does
          // not support returning intrinsic dimensions" mid-layout. The
          // aborted layout then left this `InkWell`'s ink box unsized, which
          // is the second crash: "RenderBox was not laid out:
          // _RenderInkFeatures". [_BoundedWidth] reports intrinsics straight
          // from its child and only substitutes a width when it is handed an
          // unbounded one.
          child: _BoundedWidth(
            child: Row(
              mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
              children: <Widget>[
                if (labelPosition == CheckboxLabelPosition.left) ...<Widget>[
                  Flexible(
                    fit: isExpanded ? FlexFit.tight : FlexFit.loose,
                    child: labelContent,
                  ),
                  SizedBox(width: spacing),
                ],
                checkbox,
                if (labelPosition == CheckboxLabelPosition.right) ...<Widget>[
                  SizedBox(width: spacing),
                  Flexible(
                    fit: isExpanded ? FlexFit.tight : FlexFit.loose,
                    child: labelContent,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hands its child a bounded width even when it is offered an unbounded one,
/// by substituting the child's own maximum intrinsic width.
///
/// The `Flexible` label above needs bounded constraints — a flex child under
/// an unbounded main axis throws — but the checkbox is also used inside
/// horizontally scrolling rows and unbounded `Row`s, where the width is
/// infinite. Deciding that with a `LayoutBuilder` made the whole subtree
/// unmeasurable for intrinsics; this decides it one level lower, in layout,
/// where intrinsics still pass through to the child.
class _BoundedWidth extends SingleChildRenderObjectWidget {
  const _BoundedWidth({required Widget super.child});

  @override
  _RenderBoundedWidth createRenderObject(BuildContext context) =>
      _RenderBoundedWidth();
}

class _RenderBoundedWidth extends RenderProxyBox {
  BoxConstraints _bound(BoxConstraints constraints) {
    if (constraints.hasBoundedWidth) return constraints;
    final RenderBox? child = this.child;
    if (child == null) return constraints;
    return constraints.copyWith(
      maxWidth: child.getMaxIntrinsicWidth(constraints.maxHeight),
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) return constraints.smallest;
    return constraints.constrain(child.getDryLayout(_bound(constraints)));
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_bound(constraints), parentUsesSize: true);
    size = constraints.constrain(child.size);
  }
}
