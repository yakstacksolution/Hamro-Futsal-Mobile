import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  Color confirmColor = LightColor.secondaryColor,
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
    this.confirmColor = LightColor.redColor,
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
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      backgroundColor: LightColor.cardColor,
      child: Padding(
        padding: appUtils.getPadding(all: AppDimens.paddingX20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Container(
                width: AppDimens.sizeX56,
                height: AppDimens.sizeX56,
                decoration: BoxDecoration(
                  color: confirmColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: confirmColor, size: 28),
              ),
              SizedBox(height: AppDimens.sizeX16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headingXSmall?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimens.sizeX10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            SizedBox(height: AppDimens.sizeX22),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: cancelText,
                    isOutlined: true,
                    backgroundColor: LightColor.whiteColor,
                    foregroundColor: LightColor.secondaryTextColor,
                    borderColor: LightColor.borderColor,
                    minHeight: AppDimens.sizeX44,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: CustomButton(
                    text: confirmText,
                    backgroundColor: confirmColor,
                    foregroundColor: LightColor.inverseTextColor,
                    minHeight: AppDimens.sizeX44,
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
