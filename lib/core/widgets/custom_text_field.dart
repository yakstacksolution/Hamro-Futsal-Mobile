import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.labelText,
    this.icon,
    this.hintText,
    this.suffixIcon,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.style,
    this.validator,
    this.minLines,
    this.initialValue,
    this.onSubmitted,
    this.isRequired = true,
  });

  final String labelText;
  final IconData? icon;
  final String? hintText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLines;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextStyle? style;
  final FormFieldValidator<String>? validator;
  final int? minLines;
  final String? initialValue;
  final ValueChanged<String>? onSubmitted;
  final bool? isRequired;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      initialValue: controller == null ? initialValue : null,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      cursorColor: LightColor.primaryTextColor,
      cursorHeight: AppDimens.sizeX16,
      cursorWidth: 1.2,
      style:
          style ??
          textTheme.bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontSize: AppDimens.fontBodyTextSmall,
            fontWeight: FontWeight.w400,
          ),
      decoration: customTextFieldDecoration(
        context: context,
        labelText: labelText,
        isRequired: isRequired ?? true,
        hintText: hintText,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

InputDecoration customTextFieldDecoration({
  required BuildContext context,
  required String labelText,
  bool isRequired = false,
  IconData? icon,
  String? hintText,
  Widget? suffixIcon,
}) {
  final textTheme = FutsalTheme.getTextTheme(context);
  final AppUtils appUtils = AppUtils();
  final Color fillColor = LightColor.cardColor;

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  OutlineInputBorder errorBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      borderSide: BorderSide(color: color, width: 0.7),
    );
  }

  return InputDecoration(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            labelText,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.redColor,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    ),
    hintText: hintText,
    prefixIcon: icon != null
        ? Icon(
            icon,
            color: LightColor.secondaryTextColor,
            size: AppDimens.sizeX20,
          )
        : null,
    suffixIcon: suffixIcon != null
        ? Padding(
            padding: appUtils.getPadding(right: AppDimens.paddingX2),
            child: Align(
              alignment: Alignment.centerRight,
              widthFactor: 1,
              heightFactor: 1,
              child: suffixIcon,
            ),
          )
        : null,
    suffixIconConstraints: BoxConstraints(
      minWidth: 0,
      minHeight: AppDimens.sizeX48,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: fillColor,
    labelStyle: textTheme.bodyTextSmall?.copyWith(
      color: LightColor.primaryTextColor,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: textTheme.bodyTextMedium?.copyWith(
      color: LightColor.secondaryTextColor,
      fontSize: AppDimens.fontBodyTextSmall,
      fontWeight: FontWeight.w400,
    ),
    enabledBorder: border(LightColor.borderColor),
    focusedBorder: border(LightColor.inputFocusBorderColor),
    border: border(LightColor.borderColor),
    errorBorder: errorBorder(LightColor.redColor),
    focusedErrorBorder: errorBorder(LightColor.redColor),
    contentPadding: appUtils.getPadding(
      symmetricHorizontal: AppDimens.paddingX16,
      symmetricVertical: AppDimens.paddingX16,
    ),
  );
}
