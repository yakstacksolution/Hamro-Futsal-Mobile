import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/date_time/app_date_format.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';

class BookingDetailsSpacing {
  const BookingDetailsSpacing._();

  static const double headerGap = 10;

  static const double sectionGap = 22;

  static const double rowGap = 10;

  static const double page = 20;
}

class BookingDetailCard extends StatelessWidget {
  const BookingDetailCard({
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
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: child,
    );
  }
}

class BookingSectionHeader extends StatelessWidget {
  const BookingSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        Text(
          title,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.hintTextColor,
            fontSize: DataCardDensity.detail.labelSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(width: AppDimens.paddingX10),
        // A rule running to the edge, as the statement's day headings have:
        // it separates the sections without another boxed band of colour.
        Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: AppDimens.paddingX10),
          trailing!,
        ],
      ],
    );
  }
}

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
        horizontal: AppDimens.paddingX14,
        vertical: AppDimens.paddingX12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: kDataCardLabelWidth,
            child: Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
                fontSize: DataCardDensity.detail.labelSize,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontSize: DataCardDensity.detail.valueSize,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                if (subtitle?.trim().isNotEmpty == true) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: DataCardDensity.detail.labelSize,
                      height: 1.3,
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

class BookingAmountRow extends StatelessWidget {
  const BookingAmountRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWeight,
    this.valueWeight = FontWeight.w600,
    this.valueColor,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final FontWeight? labelWeight;
  final FontWeight valueWeight;
  final Color? valueColor;

  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final double size = emphasised
        ? DataCardDensity.detail.titleSize
        : DataCardDensity.detail.valueSize;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: emphasised
                  ? LightColor.primaryTextColor
                  : LightColor.hintTextColor,
              fontSize: size,
              fontWeight: labelWeight ?? FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Text(
          value,
          textAlign: TextAlign.right,
          style: textTheme.bodyTextSmall?.copyWith(
            color: valueColor ?? LightColor.primaryTextColor,
            fontSize: size,
            fontWeight: valueWeight,
            height: 1.3,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

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
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontSize: DataCardDensity.detail.titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (caption?.trim().isNotEmpty == true) ...<Widget>[
                const SizedBox(height: AppDimens.paddingX2),
                Text(
                  caption!,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                    fontSize: DataCardDensity.detail.labelSize,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Text(
          value,
          textAlign: TextAlign.right,
          style: textTheme.bodyTextSmall?.copyWith(
            color: color ?? LightColor.primaryTextColor,
            fontSize: DataCardDensity.detail.titleSize,
            fontWeight: FontWeight.w700,
            height: 1.3,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

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

class BookingActionBar extends StatelessWidget {
  const BookingActionBar({
    super.key,
    required this.child,
    this.alignToDetailsContent = false,
  });

  final Widget child;

  final bool alignToDetailsContent;

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
          // Phone: full width. Tablet / desktop: the bar still spans the
          // window, but its buttons line up with the page's content and keep
          // to a button-sized width at its right edge.
          child: !alignToDetailsContent || !context.isTabletOrWider
              ? child
              // heightFactor 1 on both: this is a bottom bar, which may be as
              // tall as the screen — without it the bar filled the page.
              : Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.isDesktop
                          ? kBookingDetailsTwoColumnMaxWidth
                          : kBookingDetailsSingleColumnMaxWidth,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: child,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

const double kBookingDetailsSingleColumnMaxWidth = 760;

const double kBookingDetailsTwoColumnMaxWidth = 1200;

List<Widget> bookingRowsWithDividers(List<Widget> rows) {
  final List<Widget> children = <Widget>[];
  for (int index = 0; index < rows.length; index++) {
    children.add(rows[index]);
    if (index < rows.length - 1) {
      children.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
          child: Divider(height: 1, color: LightColor.dividerColor),
        ),
      );
    }
  }
  return children;
}

// ─── Formatting helpers ───────────────────────────────────────────────────────

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

String bookingCurrency(double value) => Money.npr(value);

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

String bookingFormatDate(DateTime date) {
  return AppDateFormat.format(date, 'EEE, d MMM y');
}

String bookingFormatShortDate(DateTime date) {
  return AppDateFormat.format(date, 'dd/MM/yyyy');
}

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
