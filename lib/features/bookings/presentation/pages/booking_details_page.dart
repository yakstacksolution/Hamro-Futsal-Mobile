import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({
    super.key,
    required this.booking,
    this.isFutsalView = false,
  });

  final BookingModel booking;
  final bool isFutsalView;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: AppBar(
        backgroundColor: LightColor.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: LightColor.primaryTextColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Booking Details',
          style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: LightColor.primaryTextColor,
              ),
        ),
      ),
      body: ListView(
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
          top: AppDimens.paddingX4,
          bottom: AppDimens.paddingX24,
        ),
        children: [
          _SummaryHeader(booking: booking, isFutsalView: isFutsalView),
          const SizedBox(height: AppDimens.paddingX16),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: _formatDate(booking.date),
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: booking.startTime.isEmpty
                    ? '—'
                    : '${booking.startTime} – ${booking.endTime}',
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.stadium_outlined,
                label: 'Court',
                value: booking.courtName.isNotEmpty ? booking.courtName : '—',
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Venue',
                value: booking.futsalName.isNotEmpty
                    ? booking.futsalName
                    : 'Futsal Court',
                subtitle: booking.futsalAddress,
              ),
            ],
          ),
          if (isFutsalView) ...[
            const SizedBox(height: AppDimens.paddingX16),
            _PlayerCard(booking: booking),
          ],
          const SizedBox(height: AppDimens.paddingX16),
          _PaymentCard(booking: booking),
          const SizedBox(height: AppDimens.paddingX24),
          _Actions(booking: booking, isFutsalView: isFutsalView),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const days = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.booking, required this.isFutsalView});

  final BookingModel booking;
  final bool isFutsalView;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final title = isFutsalView
        ? (booking.playerName?.isNotEmpty == true
            ? booking.playerName!
            : 'Unknown Player')
        : (booking.futsalName.isNotEmpty
            ? booking.futsalName
            : 'Futsal Court');
    final subtitle = isFutsalView
        ? (booking.futsalName.isNotEmpty ? booking.futsalName : 'Futsal booking')
        : (booking.courtName.isNotEmpty ? booking.courtName : 'Booking');

    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX16,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextLarge?.copyWith(
                    fontSize: AppDimens.fontHeadingSmall,
                    fontWeight: FontWeight.w700,
                    color: LightColor.primaryTextColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              BookingStatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          if (booking.bookingRef.isNotEmpty) ...[
            const SizedBox(height: AppDimens.paddingX12),
            Container(height: 1, color: LightColor.dividerColor),
            const SizedBox(height: AppDimens.paddingX12),
            Row(
              children: [
                Text(
                  'Booking ID',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '#${booking.bookingRef}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: LightColor.secondaryTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX16),
      child: Divider(height: 1, color: LightColor.dividerColor),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final name = booking.playerName?.isNotEmpty == true
        ? booking.playerName!
        : 'Unknown player';
    final phone = booking.playerPhone?.isNotEmpty == true
        ? booking.playerPhone!
        : null;

    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                if (phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (phone != null)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LightColor.dividerColor),
                ),
                child: const Icon(
                  Icons.call_rounded,
                  size: 16,
                  color: LightColor.secondaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final amount = booking.amount;
    final base = amount / 1.13;
    final tax = amount - base;

    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX16,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: [
          _amountRow(
            context,
            'Booking fee',
            'NPR ${base.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _amountRow(
            context,
            'Service & taxes',
            'NPR ${tax.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: LightColor.dividerColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColor.primaryTextColor,
                ),
              ),
              Text(
                'NPR ${amount.toStringAsFixed(0)}',
                style: textTheme.bodyTextLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: LightColor.primaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountRow(BuildContext context, String label, String value) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.booking, required this.isFutsalView});
  final BookingModel booking;
  final bool isFutsalView;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    if (booking.status == BookingStatus.cancelled) {
      return Center(
        child: Text(
          'This booking was cancelled.',
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
          ),
        ),
      );
    }

    if (booking.status == BookingStatus.completed) {
      return _PrimaryButton(label: 'Book Again', onTap: () {});
    }

    if (isFutsalView && booking.status == BookingStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: _OutlineButton(
              label: 'Reject',
              color: LightColor.redColor,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _PrimaryButton(label: 'Accept', onTap: () {})),
        ],
      );
    }

    if (isFutsalView) {
      return _PrimaryButton(label: 'Mark as Completed', onTap: () {});
    }

    return Row(
      children: [
        Expanded(
          child: _OutlineButton(
            label: 'Cancel',
            color: LightColor.redColor,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _PrimaryButton(label: 'Contact Venue', onTap: () {})),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return SizedBox(
      height: 48,
      child: Material(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return SizedBox(
      height: 48,
      child: Material(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              label,
              style: textTheme.bodyTextMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
