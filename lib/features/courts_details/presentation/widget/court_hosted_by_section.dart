import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class CourtHostedBySection extends StatelessWidget {
  const CourtHostedBySection({
    super.key,
    required this.hostName,
    required this.hostSince,
    required this.hostedCourts,
    required this.rating,
    this.reviewCount = 0,
    this.avatarUrl,
    this.hostedVenues,
    this.responseRate,
    this.onMessage,
    this.inPanel = false,
  });

  final String hostName;
  final String hostSince;
  final int hostedCourts;
  final double rating;
  final int reviewCount;
  final String? avatarUrl;
  final int? hostedVenues;
  final double? responseRate;
  final VoidCallback? onMessage;

  /// Laid out for the desktop booking panel: flat (the panel is already the
  /// card), the name given room to wrap, the figures as a plain row and the
  /// chat as a full-width button — instead of the phone's card, which nested
  /// a card in a card and clipped the name and labels at that width.
  final bool inPanel;

  @override
  Widget build(BuildContext context) {
    final initial = _initial(hostName);
    final textTheme = FutsalTheme.getTextTheme(context);
    if (inPanel) return _buildPanel(context, textTheme, initial);

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
                  detail: reviewCount == 1
                      ? '1 review'
                      : '$reviewCount reviews',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(
    BuildContext context,
    FutsalTextTheme textTheme,
    String initial,
  ) {
    final String reviews = reviewCount == 1
        ? '1 review'
        : '$reviewCount reviews';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          StringConstants.hostedBy.toUpperCase(),
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: LightColor.hintTextColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX12),
        Row(
          children: <Widget>[
            _buildAvatar(textTheme, initial, size: AppDimens.sizeX44),
            const SizedBox(width: AppDimens.sizeX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(text: hostName),
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(left: AppDimens.sizeX6),
                            child: Icon(
                              Icons.verified_rounded,
                              size: AppDimens.sizeX16,
                              color: LightColor.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimens.sizeX2),
                  Text(
                    'Hosting since $hostSince',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySubTitle?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sizeX16),
        IntrinsicHeight(
          child: Row(
            children: <Widget>[
              _PanelStat(value: '$hostedCourts', label: StringConstants.courts),
              _panelDivider(),
              if (hostedVenues != null)
                _PanelStat(
                  value: '$hostedVenues',
                  label: StringConstants.venues,
                )
              else
                _PanelStat(
                  value: '${(responseRate ?? 0).toInt()}%',
                  label: StringConstants.response,
                ),
              _panelDivider(),
              _PanelStat(
                value: rating.toStringAsFixed(1),
                label: reviews,
                leading: Icons.star_rounded,
              ),
            ],
          ),
        ),
        if (onMessage != null) ...<Widget>[
          const SizedBox(height: AppDimens.sizeX16),
          OutlinedButton.icon(
            onPressed: onMessage,
            icon: const Icon(CupertinoIcons.chat_bubble_text, size: 18),
            label: const Text(StringConstants.chatWithHost),
            style: OutlinedButton.styleFrom(
              foregroundColor: LightColor.secondaryColor,
              side: BorderSide(
                color: LightColor.secondaryColor.withValues(alpha: 0.45),
              ),
              minimumSize: const Size.fromHeight(AppDimens.sizeX44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              textStyle: textTheme.bodyTextSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _panelDivider() => VerticalDivider(
    width: AppDimens.sizeX16,
    thickness: 1,
    indent: AppDimens.sizeX4,
    endIndent: AppDimens.sizeX4,
    color: LightColor.dividerColor,
  );

  Widget _buildAvatar(
    FutsalTextTheme textTheme,
    String initial, {
    double size = AppDimens.sizeX56,
  }) {
    final String url = (avatarUrl ?? '').trim();
    if (url.isNotEmpty) {
      return CustomImageView(
        url: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        radius: BorderRadius.circular(AppDimens.radiusX10),
      );
    }

    return Container(
      width: size,
      height: size,
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

/// One figure in the panel's stats row: the value over its label, centred,
/// with no tile behind it.
class _PanelStat extends StatelessWidget {
  const _PanelStat({required this.value, required this.label, this.leading});

  final String value;
  final String label;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (leading != null) ...<Widget>[
                Icon(
                  leading,
                  size: AppDimens.sizeX16,
                  color: LightColor.warningColor,
                ),
                const SizedBox(width: AppDimens.sizeX2),
              ],
              Text(
                value,
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySubTitle?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HostMetricTile extends StatelessWidget {
  const _HostMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (detail case final String detailText) ...<Widget>[
              const SizedBox(height: AppDimens.sizeX1),
              Text(
                detailText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                    ?.copyWith(
                      color: LightColor.hintTextColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
