import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class CourtHostedBySection extends StatelessWidget {
  const CourtHostedBySection({
    super.key,
    required this.hostName,
    required this.hostSince,
    required this.hostedCourts,
    required this.responseRate,
    required this.rating,
  });

  final String hostName;
  final String hostSince;
  final int hostedCourts;
  final double responseRate;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final initial = _initial(hostName);
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX12,
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
      ),
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF7FBFF)],
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
              'Hosted By',
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX14),
            Row(
              children: [
                Container(
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
                ),
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
                            padding: AppUtils().getPadding(
                              all: AppDimens.paddingX4,
                            ),
                            decoration: const BoxDecoration(
                              color: LightColor.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
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
                Container(
                  width: AppDimens.sizeX42,
                  height: AppDimens.sizeX42,
                  decoration: BoxDecoration(
                    color: LightColor.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: LightColor.secondaryColor,
                    size: AppDimens.sizeX20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX14),
            Row(
              children: [
                _HostMetricTile(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Courts',
                  value: hostedCourts.toString(),
                ),
                const SizedBox(width: AppDimens.sizeX10),
                _HostMetricTile(
                  icon: Icons.flash_on_rounded,
                  label: 'Response',
                  value: '${responseRate.toInt()}%',
                ),
                const SizedBox(width: AppDimens.sizeX10),
                _HostMetricTile(
                  icon: Icons.star_rounded,
                  label: 'Rating',
                  value: rating.toStringAsFixed(1),
                ),
              ],
            ),
          ],
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
        padding: AppUtils().getPadding(
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
