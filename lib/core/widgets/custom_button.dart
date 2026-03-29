import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor = LightColor.secondary,
    this.foregroundColor = Colors.white,
    this.borderColor,
    this.isOutlined = false,
    this.widthFactor,
    this.minHeight = 50,
    this.verticalPadding = 4,
    this.borderRadius = 10,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool isOutlined;
  final double? widthFactor;
  final double minHeight;
  final double verticalPadding;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground = isOutlined
        ? Colors.transparent
        : backgroundColor;
    final resolvedBorderColor =
        borderColor ?? (isOutlined ? foregroundColor : null);

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.7,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: foregroundColor),
                const SizedBox(width: 6),
              ],
              Text(
                text,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                ),
              ),
            ],
          );

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
        minimumSize: WidgetStateProperty.all<Size>(Size(0, minHeight)),
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
        foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),
      ),
      child: Container(
        alignment: Alignment.center,
        width: widthFactor != null
            ? MediaQuery.sizeOf(context).width * widthFactor!
            : double.infinity,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: content,
      ),
    );
  }
}
