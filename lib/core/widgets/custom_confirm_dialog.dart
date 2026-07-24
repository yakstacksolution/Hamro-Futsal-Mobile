import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
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
  Widget? iconWidget,
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
      iconWidget: iconWidget,
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
    this.iconWidget,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData? icon;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    final double dialogWidth = MediaQuery.sizeOf(context).width;
    final bool stackActions = dialogWidth < 360;

    return Dialog(
      insetPadding: appUtils.getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        symmetricVertical: AppDimens.paddingX24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
      ),
      backgroundColor: LightColor.whiteColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: appUtils.getPadding(all: AppDimens.paddingX20),
          decoration: BoxDecoration(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null || iconWidget != null) ...<Widget>[
                Container(
                  width: AppDimens.sizeX58,
                  height: AppDimens.sizeX58,
                  decoration: BoxDecoration(
                    color: confirmColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX16),
                  ),
                  alignment: Alignment.center,
                  child: iconWidget == null
                      ? Icon(icon, color: confirmColor, size: AppDimens.sizeX28)
                      : IconTheme(
                          data: IconThemeData(
                            color: confirmColor,
                            size: AppDimens.sizeX28,
                          ),
                          child: iconWidget!,
                        ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX24),
              if (stackActions)
                Column(
                  children: <Widget>[
                    CustomButton(
                      text: confirmText,
                      backgroundColor: confirmColor,
                      foregroundColor: LightColor.inverseTextColor,
                      minHeight: AppDimens.sizeX46,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    const SizedBox(height: AppDimens.sizeX10),
                    CustomButton(
                      text: cancelText,
                      isOutlined: true,
                      backgroundColor: LightColor.whiteColor,
                      foregroundColor: LightColor.primaryTextColor,
                      borderColor: LightColor.greyBorderColor,
                      minHeight: AppDimens.sizeX46,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                )
              else
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        text: cancelText,
                        isOutlined: true,
                        backgroundColor: LightColor.whiteColor,
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
                        foregroundColor: LightColor.inverseTextColor,
                        minHeight: AppDimens.sizeX46,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
