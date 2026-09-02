import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// "What's new" bullet list. Renders nothing when the release ships no notes.
///
/// Long changelogs scroll inside a bounded box so the sheet can never grow past
/// the screen.
class UpdateReleaseNotes extends StatelessWidget {
  const UpdateReleaseNotes({super.key, required this.notes, this.maxHeight});

  final List<String> notes;

  /// Explicit ceiling. When omitted the box takes a share of the screen height,
  /// so a landscape phone gives the notes less room and a tablet more, instead
  /// of one fixed height crowding the actions on short screens.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final textTheme = FutsalTheme.getTextTheme(context);
    final double resolvedMaxHeight =
        maxHeight ??
        (MediaQuery.sizeOf(context).height * 0.24).clamp(
          AppDimens.updateNotesMinHeight,
          AppDimens.updateNotesMaxHeight,
        );

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            StringConstants.whatsNew,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX8),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: resolvedMaxHeight),
            // A visible thumb is the only cue that a long changelog continues
            // past the fold — the box has no border of its own.
            child: Scrollbar(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: notes
                      .map(
                        (String note) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimens.paddingX6,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(
                                  top: AppDimens.marginX6,
                                  right: AppDimens.marginX8,
                                ),
                                width: AppDimens.sizeX6,
                                height: AppDimens.sizeX6,
                                decoration: const BoxDecoration(
                                  color: LightColor.secondaryLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  note,
                                  style: textTheme.bodySubTitle?.copyWith(
                                    color: LightColor.secondaryTextColor,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
