import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';

/// One line of the sheet's detail block: an icon and the text beside it.
typedef AcknowledgeLine = ({IconData icon, String text});

/// Reports something that has already happened and waits to be acknowledged.
///
/// Deliberately unclosable — no swipe, no barrier tap, no back gesture. The
/// caller has work to do once the user has actually seen this (attaching a
/// booking, moving the flow on), so "dismissed" and "read" must not be the same
/// outcome. The future completes only after the button is pressed.
///
/// ```dart
/// await showAcknowledgeSheet(
///   context: context,
///   title: 'Your booking is completed',
///   message: 'This court is now held for your match.',
///   details: <AcknowledgeLine>[(icon: Icons.stadium_outlined, text: venue)],
/// );
/// ```
Future<void> showAcknowledgeSheet({
  required BuildContext context,
  required String title,
  String? message,
  List<AcknowledgeLine> details = const <AcknowledgeLine>[],
  String confirmText = StringConstants.okay,
  IconData icon = Icons.check_circle_rounded,
  Color? accent,
}) {
  return showModalBottomSheet<void>(
    context: context,
    // The three ways out of a sheet, all closed: the button is the only exit.
    isDismissible: false,
    enableDrag: false,
    backgroundColor: LightColor.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.radiusX20),
      ),
    ),
    builder: (BuildContext sheetContext) => PopScope(
      // Also blocks the Android back button and the iOS back swipe.
      canPop: false,
      child: _AcknowledgeSheet(
        title: title,
        message: message,
        details: details,
        confirmText: confirmText,
        icon: icon,
        accent: accent ?? LightColor.secondaryColor,
      ),
    ),
  );
}

class _AcknowledgeSheet extends StatelessWidget {
  const _AcknowledgeSheet({
    required this.title,
    required this.message,
    required this.details,
    required this.confirmText,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String? message;
  final List<AcknowledgeLine> details;
  final String confirmText;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
          top: AppDimens.paddingX24,
          bottom: AppDimens.paddingX20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // No grab handle: it advertises a drag-to-dismiss this sheet does
            // not have.
            Center(
              child: Container(
                width: AppDimens.sizeX54,
                height: AppDimens.sizeX54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: AppDimens.sizeX28),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null && message!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDimens.paddingX6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  height: 1.45,
                ),
              ),
            ],
            if (details.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDimens.paddingX16),
              Container(
                padding: AppUtils().getPadding(all: AppDimens.paddingX14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  border: Border.all(color: accent.withValues(alpha: 0.30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int i = 0; i < details.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          top: i == 0 ? 0 : AppDimens.paddingX8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              details[i].icon,
                              size: AppDimens.sizeX16,
                              color: LightColor.secondaryTextColor,
                            ),
                            const SizedBox(width: AppDimens.paddingX8),
                            Expanded(
                              child: Text(
                                details[i].text,
                                style: textTheme.bodyTextSmall?.copyWith(
                                  color: LightColor.primaryTextColor,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppDimens.paddingX20),
            CustomButton(
              text: confirmText,
              icon: Icons.arrow_forward_rounded,
              backgroundColor: accent,
              minHeight: AppDimens.sizeX50,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
