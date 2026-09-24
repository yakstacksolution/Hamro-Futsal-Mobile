import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/utils/booking_ui_utils.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// Per-venue revenue + occupancy table.
class BookingVenuePerformanceCard extends StatelessWidget {
  const BookingVenuePerformanceCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final rows = analytics.futsalLeaderboard;
    if (rows.isEmpty) {
      return const BookingEmptyMicro(text: StringConstants.noVenueActivity);
    }

    return BookingSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _VenueRow(row: rows[i]),
            if (i < rows.length - 1) const _RowDivider(),
          ],
        ],
      ),
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.row});

  final VenuePerformanceRow row;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    const double gap = AppDimens.paddingX10;
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeaderboardHeader(
            leading: const _LeadingBadge(
              child: Icon(
                Icons.stadium_outlined,
                color: LightColor.secondaryColor,
                size: 18,
              ),
            ),
            title: row.name,
            subtitle: row.area.isEmpty ? null : row.area,
            subtitleIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Row(
            children: [
              Expanded(
                child: _VenueMetric(
                  icon: Icons.payments_outlined,
                  label: StringConstants.revenue,
                  value: BookingFmt.npr(row.revenue),
                  emphasized: true,
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _VenueMetric(
                  icon: Icons.event_available_outlined,
                  label: 'Bookings',
                  value: '${row.bookings}',
                ),
              ),
            ],
          ),
          const SizedBox(height: gap),
          Row(
            children: [
              Expanded(
                child: _VenueMetric(
                  icon: Icons.timer_outlined,
                  label: 'Booked hours',
                  value: '${BookingFmt.hours(row.bookedHours)}h',
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _VenueMetric(
                  icon: Icons.grid_view_rounded,
                  label: row.courtCount == 1 ? 'Court' : 'Courts',
                  value: '${row.courtCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX14),
          Row(
            children: [
              Text(
                StringConstants.occupancy,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w600,
                  color: LightColor.secondaryTextColor,
                ),
              ),
              const Spacer(),
              Text(
                '${(row.occupancy * 100).round()}%',
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w700,
                  color: row.occupancy > 0
                      ? LightColor.secondaryColor
                      : LightColor.hintTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX6),
          _MiniBar(fraction: row.occupancy, color: LightColor.secondaryColor),
        ],
      ),
    );
  }
}

/// One tile in the venue card's 2×2 metric grid.
class _VenueMetric extends StatelessWidget {
  const _VenueMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Tints the tile with the accent color (used for revenue).
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: emphasized
            ? LightColor.secondaryColor.withValues(alpha: 0.08)
            : LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(
          color: emphasized
              ? LightColor.secondaryColor.withValues(alpha: 0.25)
              : LightColor.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: emphasized
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w600,
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX6),
          // Scale down rather than clip large revenue figures.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: textTheme.bodyTextLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: LightColor.primaryTextColor,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top 5 earning courts with relative revenue bars.
class BookingTopCourtsCard extends StatelessWidget {
  const BookingTopCourtsCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final rows = analytics.courtLeaderboard.take(5).toList();
    if (rows.isEmpty) {
      return const BookingEmptyMicro(text: StringConstants.noCourtActivity);
    }

    final maxV = rows.first.revenue.clamp(1, 1 << 30);
    final textTheme = FutsalTheme.getTextTheme(context);

    return BookingSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingX14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LeaderboardHeader(
                    leading: _LeadingBadge(
                      highlighted: i == 0,
                      child: Text(
                        '#${i + 1}',
                        style: textTheme.bodyTextSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: i == 0
                              ? LightColor.secondaryColor
                              : LightColor.secondaryTextColor,
                        ),
                      ),
                    ),
                    title: rows[i].courtName,
                    subtitle: <String>[
                      if (rows[i].venueName.isNotEmpty) rows[i].venueName,
                      '${rows[i].bookings} ${rows[i].bookings == 1 ? 'booking' : 'bookings'}',
                    ].join(' · '),
                    revenue: rows[i].revenue,
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  // Indented to line up with the title, not the badge.
                  Padding(
                    padding: const EdgeInsets.only(
                      left: _LeadingBadge.size + AppDimens.paddingX12,
                    ),
                    child: _MiniBar(
                      // Prefer the server's relative bar when provided.
                      fraction: rows[i].progress ?? rows[i].revenue / maxV,
                      color: LightColor.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1) const _RowDivider(),
          ],
        ],
      ),
    );
  }
}

/// Leading badge | title + subtitle | revenue — the shared row header so
/// every leaderboard card lines up the same way.
class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({
    required this.leading,
    required this.title,
    this.revenue,
    this.subtitle,
    this.subtitleIcon,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final IconData? subtitleIcon;

  /// Trailing amount; omitted when the row shows revenue elsewhere.
  final int? revenue;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final TextStyle? subStyle = textTheme.bodyTextSmall?.copyWith(
      color: LightColor.hintTextColor,
      fontSize: AppDimens.fontBodySubTitle,
    );
    return Row(
      children: [
        leading,
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (subtitleIcon != null) ...[
                      Icon(
                        subtitleIcon,
                        size: 12,
                        color: LightColor.hintTextColor,
                      ),
                      const SizedBox(width: 3),
                    ],
                    Expanded(
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: subStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (revenue != null) ...[
          const SizedBox(width: AppDimens.paddingX10),
          Text(
            BookingFmt.npr(revenue!),
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// 36×36 rounded tile holding an icon, rank or initials.
class _LeadingBadge extends StatelessWidget {
  const _LeadingBadge({required this.child, this.highlighted = true});

  static const double size = 36;

  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted
            ? LightColor.secondaryColor.withValues(alpha: 0.10)
            : LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: highlighted ? null : Border.all(color: LightColor.dividerColor),
      ),
      child: child,
    );
  }
}

/// Top 5 spending customers.
class BookingTopCustomersCard extends StatelessWidget {
  const BookingTopCustomersCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final rows = analytics.topCustomers;
    if (rows.isEmpty) {
      return const BookingEmptyMicro(text: StringConstants.noCustomerActivity);
    }

    final textTheme = FutsalTheme.getTextTheme(context);

    return BookingSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingX14),
              child: _LeaderboardHeader(
                leading: _LeadingBadge(
                  child: Text(
                    rows[i].initials.isNotEmpty
                        ? rows[i].initials
                        : _initials(rows[i].name),
                    style: textTheme.bodyTextSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LightColor.secondaryColor,
                    ),
                  ),
                ),
                title: rows[i].name,
                subtitle: <String>[
                  '${rows[i].bookings} ${rows[i].bookings == 1 ? 'booking' : 'bookings'}',
                  if (rows[i].phone.isNotEmpty)
                    rows[i].phone
                  else if (rows[i].email.isNotEmpty)
                    rows[i].email,
                ].join(' · '),
                revenue: rows[i].spent,
              ),
            ),
            if (i < rows.length - 1) const _RowDivider(),
          ],
        ],
      ),
    );
  }

  String _initials(String n) {
    final parts = n
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 6,
        color: LightColor.dividerColor.withValues(alpha: 0.5),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
      child: Divider(height: 1, color: LightColor.dividerColor),
    );
  }
}
