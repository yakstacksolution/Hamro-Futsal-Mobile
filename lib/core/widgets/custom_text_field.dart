import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
      cursorColor: theme.colorScheme.primary,
      style:
          style ??
          theme.textTheme.bodyLarge?.copyWith(
            color: LightColor.titleText,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
      decoration: customTextFieldDecoration(
        context: context,
        labelText: labelText,
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
  IconData? icon,
  String? hintText,
  Widget? suffixIcon,
}) {
  final ThemeData theme = Theme.of(context);
  final Color fillColor = LightColor.surface;

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.15),
    );
  }

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: icon != null
        ? Icon(icon, color: LightColor.subtitleText, size: 20)
        : null,
    suffixIcon: suffixIcon != null
        ? Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              widthFactor: 1,
              heightFactor: 1,
              child: suffixIcon,
            ),
          )
        : null,
    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 48),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: fillColor,
    labelStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.subtitleText,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    hintStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.hintText,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    enabledBorder: border(LightColor.border),
    focusedBorder: border(theme.colorScheme.primary),
    border: border(LightColor.border),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
