import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.labelText,
    required this.icon,
    this.hintText,
    this.suffixIcon,
    this.controller,
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
  });

  final String labelText;
  final IconData icon;
  final String? hintText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
      controller: controller,
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
      validator: validator,
      cursorColor: theme.colorScheme.primary,
      style:
          style ??
          theme.textTheme.bodyLarge?.copyWith(
            color: LightColor.titleTextColor,
            fontSize: 14.5,
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
  required IconData icon,
  String? hintText,
  Widget? suffixIcon,
}) {
  final ThemeData theme = Theme.of(context);
  final Color fillColor = LightColor.background.withValues(alpha: 0.9);

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.15),
    );
  }

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: Icon(icon, color: LightColor.darkgrey, size: 20),
    suffixIcon: suffixIcon != null
        ? Padding(
            padding: const EdgeInsets.only(right: 14),
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
      color: LightColor.darkgrey,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    hintStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.grey,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    enabledBorder: border(LightColor.lightGrey),
    focusedBorder: border(theme.colorScheme.primary),
    border: border(LightColor.lightGrey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
