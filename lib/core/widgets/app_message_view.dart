import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';

/// Centred icon + title + message, with an optional action button.
///
/// The shared full-surface state used for empty lists and load failures. It
/// started life inside the wishlist page; every list that reports "nothing
/// here" or "could not load" uses this one so the states look identical
/// wherever they appear.
class AppMessageView extends StatelessWidget {
  const AppMessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.refresh_rounded,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Label for the action button. The button is omitted when null.
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: LightColor.secondaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: AppDimens.paddingX18),
              CustomButton(
                text: actionLabel!,
                icon: actionIcon,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
