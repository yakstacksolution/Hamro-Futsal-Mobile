import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/app_update/domain/entities/app_update_check.dart';

/// "Installed 1.2.0 → Latest 1.4.2" summary, plus the download size when the
/// manifest supplies one.
///
/// Renders nothing when the source could not tell us a version name (a
/// Play-only check knows a version *code* but not a version string), rather
/// than showing a misleading "1.0.0 → 1.0.0".
class UpdateVersionSummary extends StatelessWidget {
  const UpdateVersionSummary({super.key, required this.check});

  final AppUpdateCheck check;

  @override
  Widget build(BuildContext context) {
    final String latest = check.latestVersionLabel;
    final String current = check.currentVersionLabel;
    final bool hasComparableVersion = latest.isNotEmpty && latest != current;
    final String? size = check.manifest?.downloadSize;

    if (!hasComparableVersion && size == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX14,
        vertical: AppDimens.paddingX12,
      ),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      // Every cell is flexible and its value ellipsises: a long version name or
      // a verbose size string shrinks the row instead of overflowing it.
      child: Row(
        children: <Widget>[
          if (hasComparableVersion) ...<Widget>[
            Flexible(
              child: _VersionCell(
                label: StringConstants.installedVersion,
                value: current,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX10),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.iconGrey,
              ),
            ),
            Flexible(
              child: _VersionCell(
                label: StringConstants.latestVersion,
                value: latest,
                highlight: true,
              ),
            ),
          ],
          if (size != null) ...<Widget>[
            // Keeps the size at the trailing edge when there is slack, and
            // collapses to nothing when the version cells need the room.
            const Spacer(),
            Flexible(
              child: _VersionCell(
                label: StringConstants.downloadSize,
                value: size,
                alignEnd: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VersionCell extends StatelessWidget {
  const _VersionCell({
    required this.label,
    required this.value,
    this.highlight = false,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: LightColor.secondaryTextColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppDimens.paddingX2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyTextSmall?.copyWith(
            color: highlight
                ? LightColor.secondaryColor
                : LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
