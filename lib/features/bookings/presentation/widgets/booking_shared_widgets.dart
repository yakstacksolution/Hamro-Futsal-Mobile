import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_details_widgets.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:hamro_futsal/core/widgets/app_message_view.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';

/// Height of the manual-booking pill on the futsal bookings list.
const double kManualBookingFabHeight = 44;

/// Gap kept between the pill and whatever sits below it.
const double _kManualBookingFabGap = AppDimens.paddingX12;

/// Where the manual-booking pill sits above the bottom of its Stack.
///
/// The dashboard's bottom navigation bar overlays this page as a sibling, and
/// that bar is content-sized — it grows with the user's text scale and adds the
/// system inset itself. A fixed offset therefore cleared it on some devices and
/// not others, so it is measured. Wide layouts use side navigation and have
/// already applied the bottom inset, so only the gap is needed there.
double manualBookingFabBottomInset(BuildContext context) =>
    context.isTabletOrWider
    ? AppDimens.paddingX16
    : CustomBottomNavigationBar.heightOf(context) + _kManualBookingFabGap;

/// Bottom padding a list needs so its last row can scroll clear of the pill.
double manualBookingFabListInset(BuildContext context) =>
    manualBookingFabBottomInset(context) +
    kManualBookingFabHeight +
    _kManualBookingFabGap;

Color bookingStatusColor(BookingStatus status) => switch (status) {
  BookingStatus.confirmed => LightColor.secondaryColor,
  BookingStatus.pending => LightColor.warningColor,
  BookingStatus.cancelled => LightColor.redColor,
  BookingStatus.rejected => LightColor.redColor,
  BookingStatus.completed => LightColor.purpleColor,
};

List<BookingModel> sortBookingsForDisplay(Iterable<BookingModel> bookings) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final List<BookingModel> sorted = bookings.toList(growable: false);
  sorted.sort((BookingModel a, BookingModel b) {
    final bool aIsPast = a.date.isBefore(today);
    final bool bIsPast = b.date.isBefore(today);
    if (aIsPast != bIsPast) return aIsPast ? 1 : -1;
    return aIsPast ? b.date.compareTo(a.date) : a.date.compareTo(b.date);
  });
  return sorted;
}

/// Human-readable age of a booking: minutes/hours ago for the first 12 hours,
/// then the absolute date and time. Uses `created_at` when the API reports it,
/// otherwise the booking's slot.
String bookingTimeAgo(BookingModel booking, {DateTime? now}) {
  final DateTime reference = now ?? DateTime.now();
  final DateTime moment = booking.createdAt ?? booking.date;
  final Duration diff = reference.difference(moment);
  final bool past = !diff.isNegative;
  final Duration span = diff.abs();

  if (span.inMinutes < 1) return 'Just now';
  if (span.inMinutes < 60) {
    final String value = '${span.inMinutes} m';
    return past ? '$value ago' : 'in $value';
  }
  if (span.inHours <= 12) {
    final String value = '${span.inHours} hr';
    return past ? '$value ago' : 'in $value';
  }
  // Older (or further out) than half a day — an exact stamp is more useful
  // than an ever-growing relative count.
  return bookingDateTimeStamp(moment, reference: reference);
}

/// `12 Aug, 6:00 PM` — the year is appended only when it differs from [reference].
String bookingDateTimeStamp(DateTime moment, {DateTime? reference}) {
  const List<String> months = <String>[
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
  final DateTime now = reference ?? DateTime.now();
  final int hour12 = moment.hour % 12 == 0 ? 12 : moment.hour % 12;
  final String minute = moment.minute.toString().padLeft(2, '0');
  final String meridiem = moment.hour < 12 ? 'AM' : 'PM';
  final String year = moment.year == now.year ? '' : ' ${moment.year}';
  return '${moment.day} ${months[moment.month - 1]}$year, '
      '$hour12:$minute $meridiem';
}

/// Muted relative timestamp shown alongside a booking card's actions.
class BookingTimeAgoLabel extends StatelessWidget {
  const BookingTimeAgoLabel({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Text(
      bookingTimeAgo(booking),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
        color: LightColor.hintTextColor,
        fontSize: AppDimens.fontBodySubTitle,
      ),
    );
  }
}

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({super.key, required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final Color base = bookingStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        border: Border.all(color: base.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.value[0].toUpperCase() + status.value.substring(1),
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: base,
          fontWeight: FontWeight.w600,
          fontSize: AppDimens.fontBodySubTitle,
        ),
      ),
    );
  }
}

class BookingInfoChip extends StatelessWidget {
  const BookingInfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppDimens.sizeX12,
          color: color ?? context.appColors.secondaryText,
        ),
        const SizedBox(width: AppDimens.paddingX4),
        Text(
          label,
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: color ?? context.appColors.secondaryText,
            fontSize: AppDimens.fontBodySubTitle,
          ),
        ),
      ],
    );
  }
}

class BookingSkeletonLoader extends StatefulWidget {
  const BookingSkeletonLoader({super.key});

  @override
  State<BookingSkeletonLoader> createState() => _BookingSkeletonLoaderState();
}

class _BookingSkeletonLoaderState extends State<BookingSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FadeTransition, not an AnimatedBuilder around the list: the previous
    // shape rebuilt four cards and their decorations on every one of the
    // pulse's frames. Now the list is built once and only its opacity layer is
    // re-composited — which matters because the status pager keeps the
    // neighbouring pages' loaders alive while the user swipes.
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _anim,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX16,
            top: AppDimens.paddingX12,
          ),
          itemCount: 4,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimens.paddingX12),
          itemBuilder: (_, __) => const _SkeletonCard(),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: LightColor.dividerColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radiusX14),
                  bottomLeft: Radius.circular(AppDimens.radiusX14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingX14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Bone(width: 140, height: 14),
                        _Bone(
                          width: 64,
                          height: 20,
                          radius: AppDimens.radiusX20,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.paddingX8),
                    _Bone(width: 100, height: 11),
                    const Spacer(),
                    Row(
                      children: [
                        _Bone(width: 90, height: 11),
                        const SizedBox(width: AppDimens.paddingX16),
                        _Bone(width: 80, height: 11),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, this.radius = 4});
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: LightColor.dividerColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class BookingEmptyView extends StatelessWidget {
  const BookingEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: LightColor.secondaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Text(
              title,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Load-failure state for the booking lists.
///
/// Thin wrapper over [AppMessageView] so bookings and the wishlist share one
/// error treatment. [title] defaults to the bookings wording; pass your own
/// where the surface differs.
class BookingErrorView extends StatelessWidget {
  const BookingErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = StringConstants.unableToLoadBookings,
  });

  final String message;
  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppMessageView(
      icon: Icons.wifi_off_rounded,
      title: title,
      message: message,
      actionLabel: StringConstants.retry,
      onAction: onRetry,
    );
  }
}

/// One booking, as a card.
///
/// Built from the shared card language in `core/widgets/data_card.dart`, the
/// same parts the account ledger uses, so the two lists read as one product
/// rather than two screens that happen to both show cards.
///
/// The header answers "whose booking, and how much": the venue (or, on a
/// vendor's list, the player) with the court or phone under it, the amount in
/// tabular digits on the right and the status as a chip beneath it. The body
/// carries the facts that identify the slot — date, time, reference — as
/// labelled rows whose values align down the card. Type and recurrence badges
/// and the optional [footer] sit at the bottom.
///
/// Every field is optional: a missing one takes its row away rather than
/// showing a blank, and long values elide instead of overflowing.
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.showPlayer = false,
    this.onTap,
    this.footer,
  });

  /// A booking card reads at the same size wherever it appears — in a list or
  /// as the summary at the top of the details page. They show the same facts
  /// about the same booking, so a reader moving between them should not have
  /// to adjust.
  static const DataCardDensity _density = DataCardDensity.detail;

  final BookingModel booking;

  /// Vendor lists lead with the player rather than the venue.
  final bool showPlayer;
  final VoidCallback? onTap;

  /// Optional trailing widget rendered at the bottom of the card (e.g. the
  /// "Add products" quick action on eligible futsal bookings).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = bookingStatusColor(booking.status);
    final String? bookingType = bookingTypeLabel(booking.bookingType);
    final bool manual = _isManual(booking.bookingType);

    final String title = showPlayer
        ? (booking.playerName?.isNotEmpty == true
              ? booking.playerName!
              : StringConstants.unknownPlayer)
        : (booking.futsalName.isNotEmpty
              ? booking.futsalName
              : StringConstants.futsalCourt);
    // Under the title goes the line that identifies the other party. A vendor
    // list leads with the player, so the phone and the court share it there;
    // a player's own list already names the venue, so the court stands alone.
    // Keeping both here is what lets the grid below stay an exact 2×2.
    final String subtitle = showPlayer
        ? <String>[
            if (booking.playerPhone?.isNotEmpty == true) booking.playerPhone!,
            if (booking.courtName.isNotEmpty) booking.courtName,
          ].join('  ·  ')
        : booking.courtName;

    // The booking type has its own cell in the grid below, so it is not also
    // a badge — one fact, one place on the card.
    final List<Widget> badges = <Widget>[
      if (booking.isRecurring)
        BookingInfoChip(
          icon: Icons.repeat_rounded,
          label:
              '${_capitalize(booking.recurrenceType ?? 'Recurring')} booking',
          color: LightColor.purpleColor,
        ),
    ];

    final String timeRange = booking.displayTimeRange;
    final double balanceDue = booking.balanceDue;

    // The facts sit in a two-column grid that fills exactly: when it is for,
    // how it was taken, when it was placed, and where the money stands. Cells
    // are ordered so each row pairs two facts of a kind — the slot, then the
    // booking's identity, then its money — and the count stays even so no row
    // is left half empty. The court and phone live on the subtitle above
    // rather than taking cells here.
    final List<Widget> cells = <Widget>[
      DataCardCell(
        label: StringConstants.date,
        value: DateFmt.date(booking.date),
        density: _density,
      ),
      if (timeRange.isNotEmpty)
        DataCardCell(
          label: StringConstants.time,
          value: timeRange,
          density: _density,
        ),
      if (booking.bookingRef.isNotEmpty)
        DataCardCell(
          label: StringConstants.reference,
          value: booking.bookingRef,
          density: _density,
        ),
      // `regular`, `manual`, `online` — how the booking was taken. Paired with
      // the reference because both answer "which booking is this".
      if (bookingType != null && bookingType.isNotEmpty)
        DataCardCell(
          label: StringConstants.type,
          value: bookingType,
          valueColor: manual ? LightColor.warningColor : null,
          density: _density,
        ),
      // When the booking was placed, as opposed to the slot it is for — the
      // two are often weeks apart, so the card names both rather than showing
      // one date and leaving the reader to guess which.
      if (booking.createdAt != null)
        DataCardCell(
          label: StringConstants.bookedOn,
          value: DateFmt.dateTime(booking.createdAt!),
          density: _density,
        ),
      // What is still owed, or what has been paid when nothing is — the money
      // question a reader has either way, and it completes the last pair.
      if (balanceDue > 0)
        DataCardCell(
          label: StringConstants.balanceDue,
          value: Money.npr(balanceDue),
          valueColor: LightColor.warningColor,
          density: _density,
        )
      else if (booking.paidAmount > 0)
        DataCardCell(
          label: StringConstants.paid,
          value: Money.npr(booking.paidAmount),
          valueColor: LightColor.brandTextColor,
          density: _density,
        ),
    ];

    return Semantics(
      container: true,
      button: onTap != null,
      label: <String>[
        title,
        if (subtitle.isNotEmpty) subtitle,
        booking.status.value,
        if (booking.amount > 0) Money.npr(booking.amount),
        DateFmt.date(booking.date),
        if (timeRange.isNotEmpty) timeRange,
        if (booking.bookingRef.isNotEmpty) booking.bookingRef,
        if (bookingType != null && bookingType.isNotEmpty)
          '${StringConstants.type} $bookingType',
        if (booking.createdAt != null)
          '${StringConstants.bookedOn} '
              '${DateFmt.dateTime(booking.createdAt!)}',
      ].join(', '),
      child: DataCard(
        onTap: onTap,
        child: Column(
          // Shrink-wraps: a card is as tall as its content, wherever it is
          // put — a list item, a Column, an Align.
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DataCardHeader(
              icon: showPlayer ? Icons.person_rounded : Icons.stadium_rounded,
              iconColor: statusColor,
              title: title,
              subtitle: subtitle,
              amount: booking.amount > 0 ? Money.npr(booking.amount) : null,
              chipLabel: booking.status.value,
              chipColor: statusColor,
              titleMaxLines: 1,
              density: _density,
              // The venue name and the figure lead the card without heading
              // it: on a list the card is scanned whole, and a full step up
              // made the top of every card shout.
              titleSize: kDataCardListTitleSize,
            ),
            const DataCardDivider(),
            DataCardGrid(cells: cells),
            if (badges.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDimens.paddingX10),
              Wrap(
                spacing: AppDimens.paddingX6,
                runSpacing: AppDimens.paddingX4,
                children: badges,
              ),
            ],
            if (footer != null) ...<Widget>[
              const DataCardDivider(),
              // Full width, not aligned: the actions are a row of equal-width
              // buttons and they are meant to span the card.
              footer!,
            ],
          ],
        ),
      ),
    );
  }

  static bool _isManual(String? type) {
    return const <String>{
      'manual',
      'walk_in',
      'walkin',
      'offline',
    }.contains(type?.trim().toLowerCase() ?? '');
  }
}

String _capitalize(String value) {
  final String text = value.trim();
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}
