import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/date_time/app_date_format.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/utils/booking_ui_utils.dart';

class BookingSurface extends StatelessWidget {
  const BookingSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.paddingX14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class BookingSectionLabel extends StatelessWidget {
  const BookingSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX2,
        bottom: AppDimens.paddingX8,
      ),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }
}

class BookingEmptyMicro extends StatelessWidget {
  const BookingEmptyMicro({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return BookingSurface(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX10),
          child: Text(
            text,
            style: FutsalTheme.getTextTheme(
              context,
            ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
          ),
        ),
      ),
    );
  }
}

class BookingContextLine extends StatelessWidget {
  const BookingContextLine({
    super.key,
    required this.range,
    required this.count,
    required this.revenue,
    this.summaryLine = '',
  });

  final BookingRange range;
  final int count;
  final int revenue;

  final String summaryLine;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final last = range.end.subtract(const Duration(days: 1));
    final sameDay = range.days == 1;
    final label = sameDay
        ? BookingFmt.shortDate(range.start)
        : '${BookingFmt.shortDate(range.start)} – ${BookingFmt.shortDate(last)}';
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX4),
      child: Text(
        // The server writes its line with Gregorian dates; in the Nepali
        // calendar the line is built here, from the same range, instead.
        summaryLine.isNotEmpty && !AppDateFormat.isBs
            ? summaryLine
            : '$label · $count ${count == 1 ? 'booking' : 'bookings'} · '
                  '${BookingFmt.npr(revenue)}',
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}
