import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_details_bloc/booking_details_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({
    super.key,
    required this.booking,
    this.isFutsalView = false,
    this.repository,
    this.onAcceptBooking,
    this.onRejectBooking,
    this.onChatCustomer,
    this.onChatVenue,
    this.onCancelBooking,
  });

  final BookingModel booking;
  final bool isFutsalView;
  final BookingRepository? repository;
  final VoidCallback? onAcceptBooking;
  final VoidCallback? onRejectBooking;
  final VoidCallback? onChatCustomer;
  final VoidCallback? onChatVenue;
  final VoidCallback? onCancelBooking;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return BlocProvider<BookingDetailsBloc>(
      create: (_) {
        final BookingDetailsBloc bloc = BookingDetailsBloc(
          GetBookingsUseCase(repository ?? BookingRepositoryImpl()),
          initialBooking: booking,
        );
        if (booking.id > 0) {
          bloc.add(FetchBookingDetailsEvent(booking.id));
        }
        return bloc;
      },
      child: _BookingDetailsView(
        isFutsalView: isFutsalView,
        onAcceptBooking: onAcceptBooking,
        onRejectBooking: onRejectBooking,
        onChatCustomer: onChatCustomer,
        onChatVenue: onChatVenue,
        onCancelBooking: onCancelBooking,
      ),
    );
  }
}

class _BookingDetailsView extends StatelessWidget {
  const _BookingDetailsView({
    required this.isFutsalView,
    this.onAcceptBooking,
    this.onRejectBooking,
    this.onChatCustomer,
    this.onChatVenue,
    this.onCancelBooking,
  });

  final bool isFutsalView;
  final VoidCallback? onAcceptBooking;
  final VoidCallback? onRejectBooking;
  final VoidCallback? onChatCustomer;
  final VoidCallback? onChatVenue;
  final VoidCallback? onCancelBooking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.bookingDetails),
      bottomNavigationBar: BlocBuilder<BookingDetailsBloc, BookingDetailsState>(
        buildWhen: (BookingDetailsState previous, BookingDetailsState current) {
          return previous.booking.status != current.booking.status ||
              previous.status != current.status;
        },
        builder: (BuildContext context, BookingDetailsState state) {
          final bool isLoading = state.status == BookingDetailsStatus.loading;
          if (isFutsalView && state.booking.status == BookingStatus.pending) {
            return SizedBox(
              height: 90,
              child: _BookingDecisionBar(
                onAccept: onAcceptBooking,
                onReject: onRejectBooking,
                isLoading: isLoading,
              ),
            );
          }
          if (!isFutsalView &&
              (state.booking.status == BookingStatus.pending ||
                  state.booking.status == BookingStatus.confirmed)) {
            return SizedBox(
              height: 90,
              child: _CancelBookingBar(
                onCancel: onCancelBooking,
                isLoading: isLoading,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocBuilder<BookingDetailsBloc, BookingDetailsState>(
        builder: (BuildContext context, BookingDetailsState state) {
          final BookingModel booking = state.booking;
          return SafeArea(
            bottom: true,
            child: Column(
              children: [
                if (state.status == BookingDetailsStatus.loading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: LightColor.secondaryColor,
                    backgroundColor: LightColor.dividerColor,
                  ),
                if (state.status == BookingDetailsStatus.failure)
                  _ErrorBanner(
                    message:
                        state.errorMessage ??
                        'Could not load the latest booking details.',
                    onRetry: () => context.read<BookingDetailsBloc>().add(
                      FetchBookingDetailsEvent(booking.id),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: [
                      _BookingSummary(
                        booking: booking,
                        isFutsalView: isFutsalView,
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle('Booking information'),
                      const SizedBox(height: 8),
                      _BookingInformation(booking: booking),
                      if (isFutsalView) ...[
                        const SizedBox(height: 20),
                        const _SectionTitle('Customer'),
                        const SizedBox(height: 8),
                        _CustomerCard(booking: booking, onChat: onChatCustomer),
                      ] else ...[
                        const SizedBox(height: 20),
                        const _SectionTitle('Venue Hosted by'),
                        const SizedBox(height: 8),
                        _VenueHostCard(booking: booking, onChat: onChatVenue),
                      ],
                      const SizedBox(height: 20),
                      const _SectionTitle('Payment summary'),
                      const SizedBox(height: 8),
                      _PaymentCard(booking: booking),
                      if (booking.payment != null) ...[
                        const SizedBox(height: 20),
                        const _SectionTitle('Payment proof'),
                        const SizedBox(height: 8),
                        _PaymentProofCard(payment: booking.payment!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingDecisionBar extends StatelessWidget {
  const _BookingDecisionBar({
    required this.onAccept,
    required this.onReject,
    required this.isLoading,
  });

  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.cardColor,
      elevation: 12,
      shadowColor: LightColor.shadowColor,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: LightColor.dividerColor.withValues(alpha: 0.8),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  key: const Key('reject-booking-button'),
                  text: StringConstants.reject,
                  icon: Icons.close_rounded,
                  onPressed: isLoading ? null : onReject ?? () {},
                  isOutlined: true,
                  foregroundColor: LightColor.redColor,
                  borderColor: LightColor.redColor,
                  minHeight: AppDimens.sizeX42,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  key: const Key('accept-booking-button'),
                  text: StringConstants.accept,
                  icon: Icons.check_rounded,
                  onPressed: isLoading ? null : onAccept ?? () {},
                  minHeight: AppDimens.sizeX42,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelBookingBar extends StatelessWidget {
  const _CancelBookingBar({required this.onCancel, required this.isLoading});

  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.cardColor,
      elevation: 12,
      shadowColor: LightColor.shadowColor,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: LightColor.dividerColor.withValues(alpha: 0.8),
              ),
            ),
          ),
          child: CustomButton(
            key: const Key('cancel-booking-button'),
            text: StringConstants.cancelBooking,
            onPressed: isLoading ? null : onCancel ?? () {},
            isOutlined: true,
            foregroundColor: LightColor.redColor,
            borderColor: LightColor.redColor,
            minHeight: AppDimens.sizeX42,
          ),
        ),
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({required this.booking, required this.isFutsalView});

  final BookingModel booking;
  final bool isFutsalView;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final String title = isFutsalView
        ? booking.playerName?.trim().isNotEmpty == true
              ? booking.playerName!
              : 'Customer booking'
        : booking.futsalName.isNotEmpty
        ? booking.futsalName
        : 'Futsal booking';
    final String subtitle = isFutsalView
        ? booking.futsalName
        : booking.courtName;

    return _Card(
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
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontSize: AppDimens.fontHeadingSmall,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BookingStatusChip(status: booking.status),
            ],
          ),
          if (booking.bookingRef.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: LightColor.dividerColor),
            const SizedBox(height: 12),
            _InlineValue(
              label: StringConstants.bookingId,
              value: booking.bookingRef,
              valueWeight: FontWeight.w600,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
        color: LightColor.primaryTextColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BookingInformation extends StatelessWidget {
  const _BookingInformation({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[
      _DetailRow(label: StringConstants.date, value: _formatDate(booking.date)),
      _DetailRow(
        label: StringConstants.time,
        value: booking.displayTimeRange.isEmpty
            ? '—'
            : booking.displayTimeRange,
      ),
      _DetailRow(
        label: StringConstants.venue,
        value: booking.futsalName.isEmpty ? '—' : booking.futsalName,
        subtitle: booking.futsalAddress,
      ),
      _DetailRow(
        label: StringConstants.court,
        value: booking.courtName.isEmpty ? '—' : booking.courtName,
      ),
      if (booking.isRecurring)
        _DetailRow(
          label: StringConstants.recurrence,
          value: _recurrenceLabel(booking),
          subtitle:
              booking.recurrenceStartDate != null &&
                  booking.recurrenceEndDate != null
              ? '${_formatShortDate(booking.recurrenceStartDate!)} – '
                    '${_formatShortDate(booking.recurrenceEndDate!)}'
              : null,
        ),
      if (booking.notes?.trim().isNotEmpty == true)
        _DetailRow(label: StringConstants.notes, value: booking.notes!),
    ];

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(children: _withDividers(rows)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.subtitle});

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 2),
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

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.booking, this.onChat});

  final BookingModel booking;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final String name = booking.playerName?.trim().isNotEmpty == true
        ? booking.playerName!
        : 'Unknown customer';

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (booking.playerPhone?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(
                    booking.playerPhone!,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
                if (booking.playerEmail?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 3),
                  Text(
                    booking.playerEmail!,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _BookingChatButton(
            buttonKey: const Key('chat-customer-button'),
            tooltip: StringConstants.chatWithCustomer,
            onTap: onChat,
          ),
        ],
      ),
    );
  }
}

class _VenueHostCard extends StatelessWidget {
  const _VenueHostCard({required this.booking, this.onChat});

  final BookingModel booking;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final String name = booking.futsalName.trim().isEmpty
        ? 'Futsal venue'
        : booking.futsalName.trim();
    final String detail = booking.futsalAddress?.trim().isNotEmpty == true
        ? booking.futsalAddress!.trim()
        : booking.courtName.trim();

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _BookingChatButton(
            buttonKey: const Key('chat-venue-button'),
            tooltip: StringConstants.chatWithVenue,
            onTap: onChat,
          ),
        ],
      ),
    );
  }
}

class _BookingChatButton extends StatelessWidget {
  const _BookingChatButton({
    required this.buttonKey,
    required this.tooltip,
    this.onTap,
  });

  final Key buttonKey;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: LightColor.secondaryColor.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          side: BorderSide(
            color: LightColor.secondaryColor.withValues(alpha: 0.18),
          ),
        ),
        elevation: onTap == null ? 0 : 1,
        shadowColor: LightColor.secondaryColor.withValues(alpha: 0.18),
        child: InkWell(
          key: buttonKey,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          onTap: onTap,
          child: const SizedBox(
            width: AppDimens.sizeX44,
            height: AppDimens.sizeX44,
            child: Icon(
              CupertinoIcons.chat_bubble_text,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX20,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final double subtotal = booking.subtotal > 0
        ? booking.subtotal
        : booking.amount;
    final String? couponCode = booking.coupon?.code?.trim();
    final String? paymentStatus = booking.paymentStatus?.trim();

    return _Card(
      child: Column(
        children: [
          if (paymentStatus?.isNotEmpty == true) ...[
            Row(
              children: [
                Text(
                  StringConstants.paymentStatus,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
                const Spacer(),
                _PaymentStatusChip(status: paymentStatus!),
              ],
            ),
            const SizedBox(height: 14),
          ],
          _InlineValue(
            label: StringConstants.subtotal,
            value: _currency(subtotal),
          ),
          if (booking.discountAmount > 0) ...[
            const SizedBox(height: 9),
            _InlineValue(
              label: couponCode?.isNotEmpty == true
                  ? 'Discount ($couponCode)'
                  : 'Discount',
              value: '- ${_currency(booking.discountAmount)}',
              valueColor: LightColor.secondaryColor,
            ),
          ],
          if (booking.taxAmount > 0) ...[
            const SizedBox(height: 9),
            _InlineValue(
              label: StringConstants.tax,
              value: _currency(booking.taxAmount),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: LightColor.dividerColor),
          const SizedBox(height: 14),
          _InlineValue(
            label: StringConstants.total,
            value: _currency(booking.amount),
            labelWeight: FontWeight.w700,
            valueWeight: FontWeight.w700,
            valueSize: 16,
          ),
          if (booking.payableNow > 0) ...[
            const SizedBox(height: 10),
            _InlineValue(
              label: StringConstants.payableNow,
              value: _currency(booking.payableNow),
            ),
          ],
          if (booking.balanceDueLater > 0) ...[
            const SizedBox(height: 9),
            _InlineValue(
              label: StringConstants.balanceDueLater,
              value: _currency(booking.balanceDueLater),
            ),
          ],
          if (booking.payment?.method?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: LightColor.dividerColor),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment method: ${_titleCase(booking.payment!.method!)}',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentProofCard extends StatelessWidget {
  const _PaymentProofCard({required this.payment});

  final BookingPaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final String? proofUrl = _paymentProofUrl(payment);
    final bool hasProof =
        payment.hasPaymentProof ||
        payment.paymentProofUrl?.trim().isNotEmpty == true ||
        payment.paymentProofPath?.trim().isNotEmpty == true;
    final String verification = payment.verificationStatus?.trim() ?? 'pending';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hasProof
                      ? 'Submitted payment screenshot'
                      : 'No payment screenshot',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ),
              _VerificationChip(status: verification),
            ],
          ),
          const SizedBox(height: 12),
          if (hasProof && proofUrl != null)
            Material(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              child: InkWell(
                key: const Key('payment-proof-preview'),
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => _PaymentProofViewer(imageUrl: proofUrl),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                  child: Stack(
                    children: [
                      CustomImageView(
                        url: proofUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        isHidePlaceholderImage: true,
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            StringConstants.viewFullScreen,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: LightColor.background,
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              child: Text(
                hasProof
                    ? 'Screenshot unavailable'
                    : 'No screenshot was submitted',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ),
          if (payment.note?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              payment.note!,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineValue extends StatelessWidget {
  const _InlineValue({
    required this.label,
    required this.value,
    this.labelWeight,
    this.valueWeight = FontWeight.w500,
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
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: labelWeight,
            ),
          ),
        ),
        const SizedBox(width: 12),
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

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

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

class _PaymentStatusChip extends StatelessWidget {
  const _PaymentStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color = status.toLowerCase() == 'paid'
        ? LightColor.secondaryColor
        : const Color(0xFFE65100);
    return _StatusPill(label: _titleCase(status), color: color);
  }
}

class _VerificationChip extends StatelessWidget {
  const _VerificationChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final String normalized = status.trim().toLowerCase();
    final bool verified =
        normalized == 'verified' ||
        normalized == 'approved' ||
        normalized == 'accepted';
    final bool rejected = normalized == 'rejected' || normalized == 'declined';
    final Color color = verified
        ? LightColor.secondaryColor
        : rejected
        ? LightColor.redColor
        : const Color(0xFFE65100);
    return _StatusPill(label: _titleCase(status), color: color);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: color,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: LightColor.redColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Row(
        children: [
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
            child: const Text(
              StringConstants.retry,
              style: TextStyle(color: LightColor.redColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentProofViewer extends StatelessWidget {
  const _PaymentProofViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          StringConstants.paymentProof,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: CustomImageView(
                  url: imageUrl,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  fit: BoxFit.contain,
                  isHidePlaceholderImage: true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

List<Widget> _withDividers(List<Widget> rows) {
  final List<Widget> children = <Widget>[];
  for (int index = 0; index < rows.length; index++) {
    children.add(rows[index]);
    if (index < rows.length - 1) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: LightColor.dividerColor),
        ),
      );
    }
  }
  return children;
}

String _formatDate(DateTime date) {
  const List<String> days = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
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
  return '${days[date.weekday - 1]}, ${date.day} '
      '${months[date.month - 1]} ${date.year}';
}

String _formatShortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _recurrenceLabel(BookingModel booking) {
  final String type = booking.recurrenceType?.trim() ?? '';
  final String recurrence = type.isEmpty ? 'Recurring' : _titleCase(type);
  return booking.isSeriesAnchor ? '$recurrence · Series booking' : recurrence;
}

String _currency(double value) => 'NPR ${value.toStringAsFixed(0)}';

String _titleCase(String value) {
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

String? _paymentProofUrl(BookingPaymentModel payment) {
  final String directUrl = payment.paymentProofUrl?.trim() ?? '';
  final String storedPath = payment.paymentProofPath?.trim() ?? '';
  String raw = directUrl;
  if (raw.isEmpty && storedPath.isNotEmpty) {
    final String normalizedPath = storedPath.startsWith('/')
        ? storedPath
        : '/$storedPath';
    raw = normalizedPath.startsWith('/storage/')
        ? normalizedPath
        : '/storage$normalizedPath';
  }
  if (raw.isEmpty) return null;

  final Uri? direct = Uri.tryParse(raw);
  if (direct != null && direct.hasScheme && direct.host.isNotEmpty) {
    return direct.toString();
  }

  final Uri base = Uri.parse(APIEndpoint.baseUrl);
  final String path = raw.startsWith('/') ? raw : '/$raw';
  return base.replace(path: path, query: null, fragment: null).toString();
}
