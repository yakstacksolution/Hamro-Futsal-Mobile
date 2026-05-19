import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';

Color bookingStatusColor(BookingStatus status) => switch (status) {
  BookingStatus.confirmed => LightColor.secondaryColor,
  BookingStatus.pending => const Color(0xFFE65100),
  BookingStatus.cancelled => LightColor.redColor,
  BookingStatus.completed => LightColor.purpleColor,
};

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
    this.color = LightColor.secondaryTextColor,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimens.sizeX12, color: color),
        const SizedBox(width: AppDimens.paddingX4),
        Text(
          label,
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: color,
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
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
              decoration: const BoxDecoration(
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

class BookingErrorView extends StatelessWidget {
  const BookingErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

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
                color: LightColor.redColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: LightColor.redColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Text(
              'Something went wrong',
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Text(
                  'Try again',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Minimal booking card (shared by both tabs) ───────────────────────────────

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.showPlayer = false,
    this.onTap,
  });

  final BookingModel booking;
  final bool showPlayer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color dot = bookingStatusColor(booking.status);

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            boxShadow: const [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: AppUtils().getPadding(all: AppDimens.paddingX16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showPlayer
                              ? (booking.playerName?.isNotEmpty == true
                                    ? booking.playerName!
                                    : 'Unknown Player')
                              : (booking.futsalName.isNotEmpty
                                    ? booking.futsalName
                                    : 'Futsal Court'),
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimens.paddingX2),
                        Text(
                          booking.courtName.isNotEmpty
                              ? booking.courtName
                              : '—',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.secondaryTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: AppDimens.sizeX6,
                        height: AppDimens.sizeX6,
                        decoration: BoxDecoration(
                          color: dot,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX4),
                      Text(
                        booking.status.value[0].toUpperCase() +
                            booking.status.value.substring(1),
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: dot,
                          fontWeight: FontWeight.w600,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (showPlayer && booking.playerPhone?.isNotEmpty == true) ...[
                const SizedBox(height: AppDimens.paddingX4),
                Text(
                  booking.playerPhone!,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.paddingX12),
              const Divider(color: LightColor.dividerColor, height: 1),
              const SizedBox(height: AppDimens.paddingX12),
              Row(
                children: [
                  _Meta(
                    icon: Icons.calendar_today_outlined,
                    label: _fmt(booking.date),
                  ),
                  _separator(),
                  _Meta(
                    icon: Icons.access_time_outlined,
                    label: booking.startTime.isNotEmpty
                        ? '${booking.startTime} – ${booking.endTime}'
                        : '—',
                  ),
                  if (booking.amount > 0) ...[
                    _separator(),
                    _Meta(
                      icon: Icons.payments_outlined,
                      label: 'Rs. ${booking.amount.toStringAsFixed(0)}',
                      color: LightColor.secondaryColor,
                    ),
                  ],
                ],
              ),
              if (booking.bookingRef.isNotEmpty) ...[
                const SizedBox(height: AppDimens.paddingX8),
                Text(
                  'Ref: #${booking.bookingRef}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _separator() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: LightColor.iconGrey,
        shape: BoxShape.circle,
      ),
    ),
  );

  String _fmt(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? LightColor.secondaryTextColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimens.sizeX12, color: c),
        const SizedBox(width: AppDimens.paddingX4),
        Text(
          label,
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: c,
            fontSize: AppDimens.fontBodySubTitle,
          ),
        ),
      ],
    );
  }
}
