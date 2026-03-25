import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  Color confirmColor = LightColor.red,
  IconData? icon,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => CustomConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
      icon: icon,
    ),
  );
  return result ?? false;
}

class CustomConfirmDialog extends StatelessWidget {
  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor = LightColor.red,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: LightColor.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: confirmColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: confirmColor, size: 28),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LightColor.titleText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LightColor.subtitleText,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: cancelText,
                    isOutlined: true,
                    backgroundColor: Colors.white,
                    foregroundColor: LightColor.subtitleText,
                    borderColor: LightColor.border,
                    minHeight: 44,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: confirmText,
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
                    minHeight: 44,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
