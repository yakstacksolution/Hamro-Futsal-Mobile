import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Presentational building blocks for the booking details screen.
///
/// The page composes only these primitives, so spacing, radii, typography and
/// colour usage stay consistent across every section and can be tuned in one
/// place.
class BookingDetailsSpacing {
  const BookingDetailsSpacing._();

  /// Gap between a section header and its card.
  static const double headerGap = 10;

  /// Gap between two sections.
  static const double sectionGap = 22;

  /// Gap between two rows inside a card.
  static const double rowGap = 10;

  /// Horizontal page padding.
  static const double page = 20;
}

/// Neutral surface every section renders on.
class BookingDetailCard extends StatelessWidget {
  const BookingDetailCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.paddingX16),
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
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: child,
    );
  }
}

/// Section heading — a quiet label above its card, with an optional trailing
/// widget (count, action, …).
class BookingSectionHeader extends StatelessWidget {
  const BookingSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Label/value row used inside list-style cards.
class BookingDetailRow extends StatelessWidget {
  const BookingDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle?.trim().isNotEmpty == true) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.right,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact money/label line used in the payment breakdown.
class BookingAmountRow extends StatelessWidget {
  const BookingAmountRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWeight,
    this.valueWeight = FontWeight.w600,
    this.valueColor,
    this.valueSize,
  });

  final String label;
  final String value;
  final FontWeight? labelWeight;
  final FontWeight valueWeight;
  final Color? valueColor;
  final double? valueSize;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: labelWeight,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Text(
          value,
          textAlign: TextAlign.right,
          style: textTheme.bodyTextMedium?.copyWith(
            color: valueColor ?? LightColor.primaryTextColor,
            fontWeight: valueWeight,
            fontSize: valueSize,
          ),
        ),
      ],
    );
  }
}

/// Emphasised amount (grand total, outstanding balance). Weight and size carry
/// the emphasis — no tinted box — so the card stays calm.
class BookingTotalHighlight extends StatelessWidget {
  const BookingTotalHighlight({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.caption,
  });

  final String label;
  final String value;

  /// Optional accent for the figure (e.g. an outstanding balance).
  final Color? color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (caption?.trim().isNotEmpty == true) ...<Widget>[
                const SizedBox(height: AppDimens.paddingX2),
                Text(
                  caption!,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Text(
          value,
          style: textTheme.bodyTextMedium?.copyWith(
            color: color ?? LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
            fontSize: AppDimens.fontBodyTextLarge,
          ),
        ),
      ],
    );
  }
}

/// Small rounded status label. [color] carries the semantic (green = settled,
/// orange = pending, red = rejected).
class BookingStatusPill extends StatelessWidget {
  const BookingStatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: color,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Inline failure banner with a retry affordance.
class BookingErrorBanner extends StatelessWidget {
  const BookingErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        BookingDetailsSpacing.page,
        AppDimens.paddingX8,
        BookingDetailsSpacing.page,
        AppDimens.paddingX4,
      ),
      padding: const EdgeInsets.fromLTRB(AppDimens.paddingX12, 8, 4, 8),
      decoration: BoxDecoration(
        color: LightColor.redColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: AppDimens.sizeX16,
            color: LightColor.redColor,
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: Text(
              message,
              style: FutsalTheme.getTextTheme(
                context,
              ).bodyTextSmall?.copyWith(color: LightColor.primaryTextColor),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              StringConstants.retry,
              style: TextStyle(color: LightColor.redColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky action bar shared by the accept/reject, cancel and complete footers.
class BookingActionBar extends StatelessWidget {
  const BookingActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.cardColor,
      elevation: 12,
      shadowColor: LightColor.shadowColor,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            BookingDetailsSpacing.page,
            AppDimens.paddingX12,
            BookingDetailsSpacing.page,
            AppDimens.paddingX12,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: LightColor.dividerColor.withValues(alpha: 0.8),
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Inserts hairline dividers between list rows.
List<Widget> bookingRowsWithDividers(List<Widget> rows) {
  final List<Widget> children = <Widget>[];
  for (int index = 0; index < rows.length; index++) {
    children.add(rows[index]);
    if (index < rows.length - 1) {
      children.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX16),
          child: Divider(height: 1, color: LightColor.dividerColor),
        ),
      );
    }
  }
  return children;
}

// ─── Formatting helpers ───────────────────────────────────────────────────────

/// Human label for the API's `booking_type`. Returns null when the field is
/// absent or blank — older payloads omit it, and callers hide the row instead
/// of showing a placeholder.
String? bookingTypeLabel(String? type) {
  final String normalized = type?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return null;
  return switch (normalized) {
    'manual' ||
    'walk_in' ||
    'walkin' ||
    'offline' => StringConstants.bookingTypeManual,
    'online' || 'app' || 'web' => StringConstants.bookingTypeOnline,
    _ => bookingTitleCase(normalized),
  };
}

String bookingCurrency(double value) {
  final bool hasDecimals = value % 1 != 0;
  return 'NPR ${value.toStringAsFixed(hasDecimals ? 2 : 0)}';
}

String bookingTitleCase(String value) {
  return value
      .trim()
      .split(RegExp(r'[_\s-]+'))
      .where((String part) => part.isNotEmpty)
      .map(
        (String part) =>
            part[0].toUpperCase() + part.substring(1).toLowerCase(),
      )
      .join(' ');
}

const List<String> _weekdays = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String bookingFormatDate(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, ${date.day} '
      '${_months[date.month - 1]} ${date.year}';
}

String bookingFormatShortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// Semantic colour for a payment status string (`paid`, `partial`, …).
Color bookingPaymentStatusColor(String status) {
  final String normalized = status.trim().toLowerCase();
  if (normalized == 'paid' || normalized == 'completed') {
    return LightColor.secondaryColor;
  }
  if (normalized == 'failed' || normalized == 'refunded') {
    return LightColor.redColor;
  }
  return LightColor.warningColor;
}

/// Semantic colour for a payment-proof verification status.
Color bookingVerificationColor(String status) {
  final String normalized = status.trim().toLowerCase();
  if (normalized == 'verified' ||
      normalized == 'approved' ||
      normalized == 'accepted') {
    return LightColor.secondaryColor;
  }
  if (normalized == 'rejected' || normalized == 'declined') {
    return LightColor.redColor;
  }
  return LightColor.warningColor;
}
