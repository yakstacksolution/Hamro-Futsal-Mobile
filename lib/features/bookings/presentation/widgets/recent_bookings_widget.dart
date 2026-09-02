import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_shared_widgets.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class _Summary {
  const _Summary({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class RecentBookingsWidget extends StatelessWidget {
  const RecentBookingsWidget({super.key, this.maxItems = 3});

  final int maxItems;

  // A getter, not a field: a `static` initialiser runs once per app launch, so
  // a cached shadow keeps the brightness it was first built under and never
  // follows a theme toggle.
  static List<BoxShadow> get _cardShadow => <BoxShadow>[
    BoxShadow(
      color: LightColor.shadowColor,
      blurRadius: AppDimens.radiusX18,
      offset: const Offset(0, 8),
      spreadRadius: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      buildWhen: (p, c) =>
          p.futsalBookingsStatus != c.futsalBookingsStatus ||
          p.futsalBookings != c.futsalBookings,
      builder: (context, state) {
        final summaries = _buildSummaries(state.futsalBookings);
        final recent = _recent(state.futsalBookings, maxItems);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(),
            const SizedBox(height: 16),
            Row(
              children: List.generate(summaries.length, (index) {
                final item = summaries[index];
                return Expanded(
                  child: Padding(
                    padding: AppUtils().getPadding(
                      right: index == summaries.length - 1 ? 0 : 10,
                    ),
                    child: _SummaryCard(summary: item),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            if (state.futsalBookingsStatus == BookingLoadStatus.loading &&
                state.futsalBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: LoadingWidget()),
              )
            else if (state.futsalBookingsStatus == BookingLoadStatus.failure &&
                state.futsalBookings.isEmpty)
              _InlineError(
                message:
                    state.futsalBookingsError ??
                    'Failed to load recent bookings.',
                onRetry: () => context.read<BookingBloc>().add(
                  const FetchFutsalBookingsEvent(),
                ),
              )
            else if (recent.isEmpty)
              const _InlineEmpty()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _BookingTile(booking: recent[index]),
              ),
          ],
        );
      },
    );
  }

  static List<BookingModel> _recent(List<BookingModel> all, int max) {
    final sorted = [...all]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(max).toList(growable: false);
  }

  static List<_Summary> _buildSummaries(List<BookingModel> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final int newToday = bookings.where((b) {
      final d = DateTime(b.date.year, b.date.month, b.date.day);
      return d == today;
    }).length;

    final double revenue = bookings
        .where(
          (b) =>
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.completed,
        )
        .fold<double>(0, (sum, b) => sum + b.amount);

    final int pending = bookings
        .where((b) => b.status == BookingStatus.pending)
        .length;

    return [
      _Summary(
        label: StringConstants.newToday,
        value: newToday.toString().padLeft(2, '0'),
        icon: Icons.add_task_rounded,
        color: LightColor.secondaryColor,
      ),
      _Summary(
        label: StringConstants.revenue,
        value: 'NPR ${_compact(revenue)}',
        icon: Icons.payments_rounded,
        color: LightColor.secondaryColor,
      ),
      _Summary(
        label: StringConstants.pending,
        value: pending.toString().padLeft(2, '0'),
        icon: Icons.timelapse_rounded,
        color: LightColor.warningColor,
      ),
    ];
  }

  static String _compact(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toStringAsFixed(0);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            StringConstants.recentBookings,
            style: textTheme.headingSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
              letterSpacing: -0.2,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {},
          child: Container(
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX12,
              symmetricVertical: AppDimens.paddingX8,
            ),
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  StringConstants.viewAll,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: LightColor.secondaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final _Summary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX12,
        symmetricVertical: AppDimens.paddingX14,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: RecentBookingsWidget._cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(summary.icon, color: summary.color, size: 18),
          const SizedBox(height: 4),
          Text(
            summary.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: LightColor.primaryTextColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            summary.label,
            style: textTheme.bodyTextSmall?.copyWith(
              fontSize: 10,
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final surface = Theme.of(context).colorScheme.surface;
    final statusColor = bookingStatusColor(booking.status);
    final displayName = (booking.playerName?.isNotEmpty == true)
        ? booking.playerName!
        : (booking.futsalName.isNotEmpty ? booking.futsalName : 'Unknown');

    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: RecentBookingsWidget._cardShadow,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _BookingAvatar(
                initials: _initials(displayName),
                statusColor: statusColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.bookingRef.isNotEmpty
                          ? 'Ref #${booking.bookingRef}'
                          : _relativeDate(booking.date),
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontSize: 11,
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(status: booking.status, statusColor: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: AppUtils().getPadding(all: AppDimens.paddingX12),
            decoration: BoxDecoration(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stadium_outlined,
                      size: 16,
                      color: LightColor.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.courtName.isNotEmpty ? booking.courtName : '—',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: LightColor.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _scheduleLabel(booking),
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX10,
                  symmetricVertical: AppDimens.paddingX6,
                ),
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 14,
                      color: LightColor.secondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      StringConstants.bookingFee,
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontSize: 10.5,
                        color: LightColor.secondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'NPR ${booking.amount.toStringAsFixed(0)}',
                style: textTheme.bodyTextLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: LightColor.primaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '--';
    if (parts.length == 1) {
      final word = parts.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String _scheduleLabel(BookingModel b) {
    final datePart = _relativeDate(b.date);
    if (b.startTime.isEmpty) return datePart;
    return '$datePart • ${b.startTime} – ${b.endTime}';
  }

  static String _relativeDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = that.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    const months = [
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
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _BookingAvatar extends StatelessWidget {
  const _BookingAvatar({required this.initials, required this.statusColor});

  final String initials;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.18),
            statusColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          initials,
          style: textTheme.bodyTextMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: statusColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.statusColor});

  final BookingStatus status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX8,
        symmetricVertical: AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(status), size: 13, color: statusColor),
          const SizedBox(width: 5),
          Text(
            status.value[0].toUpperCase() + status.value.substring(1),
            style: textTheme.bodyTextSmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(BookingStatus s) => switch (s) {
    BookingStatus.confirmed => Icons.check_circle_rounded,
    BookingStatus.pending => Icons.access_time_filled_rounded,
    BookingStatus.completed => Icons.verified_rounded,
    BookingStatus.cancelled => Icons.cancel_rounded,
    BookingStatus.rejected => Icons.block_rounded,
  };
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RecentBookingsWidget._cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            color: LightColor.secondaryTextColor,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            StringConstants.noRecentBookings,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RecentBookingsWidget._cardShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, color: LightColor.redColor, size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX16,
                symmetricVertical: AppDimens.paddingX8,
              ),
              decoration: BoxDecoration(
                color: LightColor.secondaryColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                StringConstants.retry,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.inverseTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
