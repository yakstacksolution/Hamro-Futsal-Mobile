import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/utils/booking_ui_utils.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_common.dart';

/// Per-venue revenue + occupancy table.
class BookingVenuePerformanceCard extends StatelessWidget {
  const BookingVenuePerformanceCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final rows = analytics.futsalLeaderboard;
    if (rows.isEmpty) {
      return const BookingEmptyMicro(text: 'No venue activity.');
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

  final FutsalPerformanceRow row;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX14,
        symmetricVertical: AppDimens.paddingX12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.stadium_outlined,
                  color: LightColor.secondaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.futsal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    Text(
                      '${row.futsal.area} · ${row.futsal.courts.length} courts · ${row.bookings} bookings',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                BookingFmt.npr(row.revenue),
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: LightColor.primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Row(
            children: [
              Expanded(
                child: _MiniBar(
                  fraction: row.occupancy,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Text(
                '${(row.occupancy * 100).round()}%',
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w700,
                  color: LightColor.secondaryColor,
                ),
              ),
            ],
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
      return const BookingEmptyMicro(text: 'No court activity.');
    }

    final maxV = rows.first.revenue.clamp(1, 1 << 30);
    final textTheme = FutsalTheme.getTextTheme(context);

    return BookingSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX14,
                symmetricVertical: AppDimens.paddingX12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LightColor.background,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                      border: Border.all(color: LightColor.dividerColor),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.secondaryTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].court.name,
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        Text(
                          '${rows[i].futsalName} · ${rows[i].bookings} bookings',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _MiniBar(
                          fraction: rows[i].revenue / maxV,
                          color: LightColor.secondaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Text(
                    BookingFmt.npr(rows[i].revenue),
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
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

/// Top 5 spending customers.
class BookingTopCustomersCard extends StatelessWidget {
  const BookingTopCustomersCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final rows = analytics.topCustomers;
    if (rows.isEmpty) {
      return const BookingEmptyMicro(text: 'No customer activity.');
    }

    final textTheme = FutsalTheme.getTextTheme(context);

    return BookingSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX14,
                symmetricVertical: AppDimens.paddingX12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                    ),
                    child: Text(
                      _initials(rows[i].name),
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LightColor.secondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].name,
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        Text(
                          '${rows[i].bookings} bookings',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    BookingFmt.npr(rows[i].spent),
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
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

  String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+'));
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
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
      child: Divider(height: 1, color: LightColor.dividerColor),
    );
  }
}
