import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

Future<bool> showDeleteDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Delete',
  String cancelText = 'Cancel',
  IconData icon = Icons.delete_outline_rounded,
  Color confirmColor = LightColor.redColor,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _DeleteDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      confirmColor: confirmColor,
    ),
  );
  return result ?? false;
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.icon,
    required this.confirmColor,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
      ),
      backgroundColor: LightColor.whiteColor,
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX20),
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: AppDimens.sizeX56,
              height: AppDimens.sizeX56,
              decoration: BoxDecoration(
                color: confirmColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusX14),
              ),
              child: Icon(
                icon,
                size: AppDimens.sizeX28,
                color: confirmColor,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppDimens.sizeX8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: AppDimens.sizeX24),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: cancelText,
                    isOutlined: true,
                    backgroundColor: Colors.white,
                    foregroundColor: LightColor.primaryTextColor,
                    borderColor: LightColor.greyBorderColor,
                    minHeight: AppDimens.sizeX46,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: CustomButton(
                    text: confirmText,
                    backgroundColor: confirmColor,
                    minHeight: AppDimens.sizeX46,
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
