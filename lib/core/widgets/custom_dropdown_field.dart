import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';

class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.labelText,
    required this.items,
    this.icon,
    this.hintText,
    this.initialValue,
    this.focusNode,
    this.autovalidateMode,
    this.validator,
    this.onChanged,
    this.dropdownColor,
    this.contentPadding,
    this.isExpanded = true,
    this.enabled = true,
    this.isRequired = false,
  });

  final String labelText;
  final IconData? icon;
  final String? hintText;
  final T? initialValue;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;
  final FormFieldValidator<T>? validator;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;
  final Color? dropdownColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool isExpanded;
  final bool enabled;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);

    final TextStyle valueStyle =
        textTheme.bodyTextLarge?.copyWith(
          color: LightColor.primaryTextColor,
          fontSize: AppDimens.fontBodyTextSmall,
          fontWeight: FontWeight.w400,
        ) ??
        const TextStyle();

    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      validator: validator,
      onChanged: enabled ? onChanged : null,
      isExpanded: isExpanded,
      dropdownColor: dropdownColor,
      style: valueStyle,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: LightColor.secondaryTextColor,
        size: AppDimens.sizeX18,
      ),
      decoration:
          customTextFieldDecoration(
            context: context,
            labelText: labelText,
            isRequired: isRequired,
            icon: icon,
          ).copyWith(
            contentPadding:
                contentPadding ??
                appUtils.getPadding(
                  symmetricHorizontal: AppDimens.paddingX12,
                  symmetricVertical: AppDimens.paddingX10,
                ),
          ),
      hint: hintText == null
          ? null
          : Text(
              hintText!,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
                fontSize: AppDimens.sizeX12,
                fontWeight: FontWeight.w400,
              ),
            ),
      items: items,
    );
  }
}
