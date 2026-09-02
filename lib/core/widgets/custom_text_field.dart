import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.labelText,
    this.icon,
    this.iconColor,
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
    this.autovalidateMode,
    this.minLines,
    this.initialValue,
    this.onSubmitted,
    this.isRequired = true,
    this.ensureVisibleOnFocus = false,
    this.inputFormatters,
  });

  final String labelText;
  final IconData? icon;

  /// Overrides the prefix icon tint. Defaults to [LightColor.secondaryTextColor].
  final Color? iconColor;
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
  final AutovalidateMode? autovalidateMode;
  final int? minLines;
  final String? initialValue;
  final ValueChanged<String>? onSubmitted;
  final bool? isRequired;
  final List<TextInputFormatter>? inputFormatters;

  /// When true, the field scrolls itself into view inside the nearest
  /// [Scrollable] as soon as it gains focus (so it stays above the keyboard).
  final bool ensureVisibleOnFocus;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode? _internalNode;

  /// The node we attach to the underlying [TextFormField]. We only need a
  /// concrete node when auto-scroll is requested; otherwise we keep the prior
  /// behaviour and let the field manage its own (or the caller-provided) node.
  FocusNode? get _effectiveNode {
    if (widget.focusNode != null) return widget.focusNode;
    if (!widget.ensureVisibleOnFocus) return null;
    return _internalNode ??= FocusNode();
  }

  @override
  void initState() {
    super.initState();
    if (widget.ensureVisibleOnFocus) {
      _effectiveNode?.addListener(_handleFocusChange);
    }
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode ||
        oldWidget.ensureVisibleOnFocus != widget.ensureVisibleOnFocus) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      _internalNode?.removeListener(_handleFocusChange);
      if (widget.ensureVisibleOnFocus) {
        _effectiveNode?.addListener(_handleFocusChange);
      }
    }
  }

  void _handleFocusChange() {
    if (!(_effectiveNode?.hasFocus ?? false)) return;
    // Wait for the keyboard to start animating in before measuring.
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted || !(_effectiveNode?.hasFocus ?? false)) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.15,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _internalNode?.removeListener(_handleFocusChange);
    _internalNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return TextFormField(
      controller: widget.controller,
      focusNode: _effectiveNode,
      initialValue: widget.controller == null ? widget.initialValue : null,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      textInputAction: widget.textInputAction,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      inputFormatters: widget.inputFormatters,
      cursorColor: LightColor.primaryTextColor,
      cursorHeight: AppDimens.sizeX16,
      cursorWidth: 1.2,
      style:
          widget.style ??
          textTheme.bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontSize: AppDimens.fontBodyTextSmall,
            fontWeight: FontWeight.w400,
          ),
      decoration: customTextFieldDecoration(
        context: context,
        labelText: widget.labelText,
        isRequired: widget.isRequired ?? true,
        hintText: widget.hintText,
        icon: widget.icon,
        iconColor: widget.iconColor,
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}

InputDecoration customTextFieldDecoration({
  required BuildContext context,
  required String labelText,
  bool isRequired = false,
  IconData? icon,
  Color? iconColor,
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
            color: iconColor ?? LightColor.secondaryTextColor,
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
