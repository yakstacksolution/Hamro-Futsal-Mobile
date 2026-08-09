import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

/// Failure notice shared by the update wall and the update sheet.
///
/// A tinted block rather than bare red text: on the wall the message sits
/// between the release notes and the actions, where loose coloured type reads
/// as part of the copy instead of as a problem.
class UpdateErrorMessage extends StatelessWidget {
  const UpdateErrorMessage({
    super.key,
    required this.message,
    this.center = false,
  });

  final String message;

  /// The wall centres its copy; the sheet is left-aligned throughout.
  final bool center;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX12,
        vertical: AppDimens.paddingX10,
      ),
      decoration: BoxDecoration(
        color: LightColor.redColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.redColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisAlignment: center
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: AppDimens.sizeX18,
            color: LightColor.redColor,
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Flexible(
            child: Text(
              message,
              textAlign: center ? TextAlign.center : TextAlign.start,
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.redColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
