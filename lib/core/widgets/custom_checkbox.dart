import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

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
    this.activeColor = LightColor.secondaryColor,
    this.inactiveColor = LightColor.cardColor,
    this.borderColor = LightColor.borderColor,
    this.checkColor = LightColor.inverseTextColor,
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
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;
  final Color checkColor;
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
        color: value ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX4),
        border: Border.all(
          color: value ? activeColor : borderColor,
          width: 1.2,
        ),
      ),
      child: value
          ? Icon(Icons.check_rounded, size: size * 0.72, color: checkColor)
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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool canUseFlexibleLabel = constraints.hasBoundedWidth;
              final bool shouldFillRow =
                  isExpanded && constraints.hasBoundedWidth;

              Widget buildLabel() {
                if (!canUseFlexibleLabel) {
                  return labelContent;
                }

                return Flexible(
                  fit: isExpanded ? FlexFit.tight : FlexFit.loose,
                  child: labelContent,
                );
              }

              final List<Widget> children = <Widget>[
                if (labelPosition == CheckboxLabelPosition.left) buildLabel(),
                if (labelPosition == CheckboxLabelPosition.left)
                  SizedBox(width: spacing),
                checkbox,
                if (labelPosition == CheckboxLabelPosition.right)
                  SizedBox(width: spacing),
                if (labelPosition == CheckboxLabelPosition.right) buildLabel(),
              ];

              return Row(
                mainAxisSize: shouldFillRow
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: children,
              );
            },
          ),
        ),
      ),
    );
  }
}
