import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class CourtHostedBySection extends StatelessWidget {
  const CourtHostedBySection({
    super.key,
    required this.hostName,
    required this.hostSince,
    required this.hostedCourts,
    required this.rating,
    this.avatarUrl,
    this.hostedVenues,
    this.responseRate,
    this.onMessage,
  });

  final String hostName;
  final String hostSince;
  final int hostedCourts;
  final double rating;
  final String? avatarUrl;
  final int? hostedVenues;
  final double? responseRate;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final initial = _initial(hostName);
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX16,
        top: AppDimens.paddingX12,
        right: AppDimens.paddingX16,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingX16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[LightColor.elevatedCardColor, LightColor.cardColor],
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.06),
              blurRadius: AppDimens.sizeX18,
              offset: const Offset(0, AppDimens.sizeX8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConstants.hostedBy,
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX14),
            Row(
              children: [
                _buildAvatar(textTheme, initial),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              hostName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextLarge?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sizeX6),
                          Container(
                            padding: const EdgeInsets.all(AppDimens.paddingX4),
                            decoration: const BoxDecoration(
                              color: LightColor.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: LightColor.inverseTextColor,
                              size: AppDimens.sizeX10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.sizeX4),
                      Text(
                        'Hosting since $hostSince',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: StringConstants.chatWithHost,
                  child: Material(
                    color: onMessage == null
                        ? LightColor.dividerColor.withValues(alpha: 0.5)
                        : LightColor.secondaryColor.withValues(alpha: 0.10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                      side: BorderSide(
                        color: onMessage == null
                            ? LightColor.dividerColor
                            : LightColor.secondaryColor.withValues(alpha: 0.18),
                      ),
                    ),
                    elevation: onMessage == null ? 0 : 1,
                    shadowColor: LightColor.secondaryColor.withValues(
                      alpha: 0.18,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                      onTap: onMessage,
                      child: SizedBox(
                        width: AppDimens.sizeX44,
                        height: AppDimens.sizeX44,
                        child: Icon(
                          // Icons.messan,
                          CupertinoIcons.chat_bubble_text,
                          color: onMessage == null
                              ? LightColor.hintTextColor
                              : LightColor.secondaryColor,
                          size: AppDimens.sizeX20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX14),
            Row(
              children: [
                _HostMetricTile(
                  icon: Icons.sports_soccer_rounded,
                  label: StringConstants.courts,
                  value: hostedCourts.toString(),
                ),
                const SizedBox(width: AppDimens.sizeX10),
                if (hostedVenues != null)
                  _HostMetricTile(
                    icon: Icons.stadium_rounded,
                    label: StringConstants.venues,
                    value: hostedVenues.toString(),
                  )
                else
                  _HostMetricTile(
                    icon: Icons.flash_on_rounded,
                    label: StringConstants.response,
                    value: '${(responseRate ?? 0).toInt()}%',
                  ),
                const SizedBox(width: AppDimens.sizeX10),
                _HostMetricTile(
                  icon: Icons.star_rounded,
                  label: StringConstants.rating,
                  value: rating.toStringAsFixed(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(FutsalTextTheme textTheme, String initial) {
    final String url = (avatarUrl ?? '').trim();
    if (url.isNotEmpty) {
      return CustomImageView(
        url: url,
        width: AppDimens.sizeX56,
        height: AppDimens.sizeX56,
        fit: BoxFit.cover,
        radius: BorderRadius.circular(AppDimens.radiusX10),
      );
    }

    return Container(
      width: AppDimens.sizeX56,
      height: AppDimens.sizeX56,
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Center(
        child: Text(
          initial,
          style: textTheme.headingXSmall?.copyWith(
            color: LightColor.inverseTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _HostMetricTile extends StatelessWidget {
  const _HostMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX10,
          vertical: AppDimens.paddingX10,
        ),
        decoration: BoxDecoration(
          color: LightColor.secondaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppDimens.sizeX18,
              color: LightColor.secondaryColor,
            ),
            const SizedBox(height: AppDimens.sizeX4),
            Text(
              value,
              style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX1),
            Text(
              label,
              style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
