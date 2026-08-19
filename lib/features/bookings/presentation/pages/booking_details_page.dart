import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_cancel_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_details_bloc/booking_details_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_details_widgets.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_products_sheet.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';
import 'package:hamro_footsall/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_hosted_by_use_case.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_launcher.dart';
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
          isFutsalView: isFutsalView,
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

  Future<void> _confirmAndCancel(BuildContext context) async {
    final BookingDetailsBloc bloc = context.read<BookingDetailsBloc>();
    final bool? confirmed = await showAppBottomSheet<bool>(
      context: context,
      child: const _CancelBookingSheet(),
    );
    if (confirmed == true) {
      bloc.add(CancelBookingEvent(bloc.state.booking.id));
    }
  }

  // ── Payment proof verify / reject ──

  Future<void> _verifyPayment(BuildContext context) async {
    final BookingDetailsBloc bloc = context.read<BookingDetailsBloc>();
    final BookingModel booking = bloc.state.booking;
    final BookingPaymentModel? payment = booking.payment;
    if (payment == null || payment.id <= 0) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.noPaymentToVerify,
      );
      return;
    }
    final _PaymentProofAcceptResult? result =
        await showAppBottomSheet<_PaymentProofAcceptResult>(
          context: context,
          builder: (_) => _PaymentProofAcceptSheet(payment: payment),
        );
    if (result != null) {
      bloc.add(
        VerifyPaymentEvent(
          bookingId: booking.id,
          paymentId: payment.id,
          actualAmount: result.actualAmount,
          note: result.note,
        ),
      );
    }
  }

  Future<void> _rejectPayment(BuildContext context) async {
    final BookingDetailsBloc bloc = context.read<BookingDetailsBloc>();
    final BookingModel booking = bloc.state.booking;
    final BookingPaymentModel? payment = booking.payment;
    if (payment == null || payment.id <= 0) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.noPaymentToVerify,
      );
      return;
    }
    final _RejectResult? result = await showAppBottomSheet<_RejectResult>(
      context: context,
      builder: (_) => const _PaymentProofRejectSheet(),
    );
    if (result != null) {
      bloc.add(
        RejectPaymentEvent(
          bookingId: booking.id,
          paymentId: payment.id,
          note: result.note,
        ),
      );
    }
  }

  // ── Complete booking ──

  Future<void> _completeBooking(
    BuildContext context,
    BookingModel booking,
  ) async {
    final BookingDetailsBloc bloc = context.read<BookingDetailsBloc>();
    final BookingCompleteResult? result = await showBookingCompleteSheet(
      context,
      booking,
    );
    if (result == null || !context.mounted) return;
    final bool ok = await completeBooking(booking.id, result: result);
    if (!context.mounted) return;
    AppUtils().showSnackBar(
      context,
      ok ? MsgType.success : MsgType.error,
      ok ? 'Booking marked as completed.' : 'Could not complete the booking.',
    );
    if (ok) bloc.add(FetchBookingDetailsEvent(booking.id));
  }

  Future<void> _collectDue(BuildContext context, BookingModel booking) async {
    final BookingDetailsBloc bloc = context.read<BookingDetailsBloc>();
    final BookingCollectDueResult? result = await showCollectBookingDueSheet(
      context,
      booking,
    );
    if (result == null || !context.mounted) return;
    final bool ok = await collectBookingDue(booking.id, result);
    if (!context.mounted) return;
    AppUtils().showSnackBar(
      context,
      ok ? MsgType.success : MsgType.error,
      ok
          ? 'Due amount collected successfully.'
          : 'Could not collect the due amount.',
    );
    if (ok) bloc.add(FetchBookingDetailsEvent(booking.id));
  }

  // ── Booking accept / reject ──

  void _acceptBooking(BuildContext context) {
    final BookingDetailsBloc bloc = context.read<BookingDetailsBloc>();
    bloc.add(AcceptBookingEvent(bookingId: bloc.state.booking.id));
  }

  Future<void> _rejectBooking(BuildContext context) async {
    final BookingDetailsBloc bloc = context.read<BookingDetailsBloc>();
    final int bookingId = bloc.state.booking.id;
    final _RejectResult? result = await showAppBottomSheet<_RejectResult>(
      context: context,
      builder: (_) => const _RejectBookingSheet(),
    );
    if (result != null) {
      bloc.add(RejectBookingEvent(bookingId: bookingId, note: result.note));
    }
  }

  /// The conversations API requires `vendor_id`, and it must be the booking's
  /// vendor record id. Both booking payloads (list item and details) carry it,
  /// and the details bloc preserves it across refreshes — so the booking is the
  /// source of truth. The hosted-by endpoint is only a fallback for older
  /// payloads that omit the field.
  Future<int?> _resolveVendorId(
    BuildContext context,
    BookingModel booking,
  ) async {
    final int? vendorId = booking.vendorId;
    if (vendorId != null && vendorId > 0) return vendorId;

    final int? venueId = booking.venueId;
    if (venueId == null || venueId <= 0) return null;

    final result = await GetHostedByUseCase(FutsalDetailsRepositoryImpl())(
      venueId: venueId,
    );
    if (!context.mounted) return null;
    // Same id the futsal details page passes as `vendor_id` when a player
    // messages a venue host.
    return result.fold((_) => null, (hostedBy) => hostedBy.id);
  }

  /// Customer → vendor: the venue owner is the peer, addressed by `vendor_id`.
  Future<void> _chatWithVenue(
    BuildContext context,
    BookingModel booking,
  ) async {
    final int? vendorId = await _resolveVendorId(context, booking);
    if (!context.mounted) return;
    if (vendorId == null || vendorId <= 0) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Vendor information is unavailable for messaging.',
      );
      return;
    }
    await ChatLauncher.startDirect(
      context,
      vendorId: vendorId,
      venueId: booking.venueId,
    );
  }

  /// Vendor → customer: the peer is supplied as `user_id`, while `vendor_id`
  /// still identifies which vendor the conversation belongs to.
  Future<void> _chatWithCustomer(
    BuildContext context,
    BookingModel booking,
  ) async {
    final int? customerId = booking.playerId;
    if (customerId == null || customerId <= 0) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Customer information is unavailable for messaging.',
      );
      return;
    }

    final int? vendorId = await _resolveVendorId(context, booking);
    if (!context.mounted) return;
    if (vendorId == null || vendorId <= 0) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Vendor information is unavailable for messaging.',
      );
      return;
    }

    await ChatLauncher.startDirectUser(
      context,
      userId: customerId,
      vendorId: vendorId,
      venueId: booking.venueId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingDetailsBloc, BookingDetailsState>(
      listenWhen: (BookingDetailsState previous, BookingDetailsState current) =>
          previous.cancelStatus != current.cancelStatus ||
          previous.decisionStatus != current.decisionStatus ||
          previous.paymentStatus != current.paymentStatus,
      listener: (BuildContext context, BookingDetailsState state) {
        void refresh() => context.read<BookingDetailsBloc>().add(
          FetchBookingDetailsEvent(state.booking.id),
        );
        if (state.cancelStatus == CancelBookingStatus.cancelled) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            StringConstants.bookingCancelledSuccessfully,
          );
          // Re-fetch so the status chip and details reflect the server state.
          refresh();
        } else if (state.cancelStatus == CancelBookingStatus.failure) {
          AppUtils().showSnackBar(
            context,
            MsgType.error,
            state.errorMessage ?? StringConstants.couldNotCancelBooking,
          );
        } else if (state.paymentStatus == PaymentActionStatus.verified) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            StringConstants.paymentVerifiedSuccessfully,
          );
        } else if (state.paymentStatus == PaymentActionStatus.rejected) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            StringConstants.paymentRejectedSuccessfully,
          );
        } else if (state.paymentStatus == PaymentActionStatus.failure) {
          AppUtils().showSnackBar(
            context,
            MsgType.error,
            state.errorMessage ?? StringConstants.couldNotVerifyPayment,
          );
        } else if (state.decisionStatus == DecisionStatus.accepted) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            StringConstants.bookingAcceptedSuccessfully,
          );
          refresh();
        } else if (state.decisionStatus == DecisionStatus.rejected) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            StringConstants.bookingRejectedSuccessfully,
          );
          refresh();
        } else if (state.decisionStatus == DecisionStatus.failure) {
          AppUtils().showSnackBar(
            context,
            MsgType.error,
            state.errorMessage ?? StringConstants.couldNotAcceptBooking,
          );
        }
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: LightColor.background,
        appBar: const CustomAppBar(title: StringConstants.bookingDetails),
        bottomNavigationBar:
            BlocBuilder<BookingDetailsBloc, BookingDetailsState>(
              buildWhen:
                  (BookingDetailsState previous, BookingDetailsState current) {
                    return previous.booking.status != current.booking.status ||
                        previous.booking.payment?.verificationStatus !=
                            current.booking.payment?.verificationStatus ||
                        previous.status != current.status ||
                        previous.cancelStatus != current.cancelStatus ||
                        previous.canCancel != current.canCancel ||
                        previous.paymentStatus != current.paymentStatus ||
                        previous.decisionStatus != current.decisionStatus;
                  },
              builder: (BuildContext context, BookingDetailsState state) {
                final bool isLoading =
                    state.status == BookingDetailsStatus.loading ||
                    state.cancelStatus == CancelBookingStatus.cancelling ||
                    state.decisionStatus == DecisionStatus.submitting;
                if (isFutsalView &&
                    state.booking.status == BookingStatus.pending) {
                  final String verification =
                      state.booking.payment?.verificationStatus
                          ?.trim()
                          .toLowerCase() ??
                      'pending';
                  // Booking Accept unlocks once the payment proof is verified —
                  // either reflected by the server's verification status or the
                  // just-completed verify action in this session. Booking Reject
                  // stays available regardless.
                  final bool paymentVerified =
                      verification == 'accepted' ||
                      verification == 'verified' ||
                      state.paymentStatus == PaymentActionStatus.verified;
                  return SizedBox(
                    height: 70 + MediaQuery.viewPaddingOf(context).bottom,
                    child: _BookingDecisionBar(
                      onAccept:
                          onAcceptBooking ?? () => _acceptBooking(context),
                      onReject:
                          onRejectBooking ?? () => _rejectBooking(context),
                      isLoading: isLoading,
                      canAccept: paymentVerified,
                    ),
                  );
                }
                if (isFutsalView &&
                    state.booking.status == BookingStatus.confirmed &&
                    state.cancelStatus != CancelBookingStatus.cancelled) {
                  return SizedBox(
                    height: 70 + MediaQuery.viewPaddingOf(context).bottom,
                    child: _ConfirmedActionsBar(
                      onComplete: () =>
                          _completeBooking(context, state.booking),
                      isLoading: isLoading,
                      amountToCollect: state.booking.amountDueForCompletion,
                    ),
                  );
                }
                if (isFutsalView &&
                    state.booking.status == BookingStatus.completed &&
                    state.booking.amountDueForCollection > 0) {
                  return SizedBox(
                    height: 70 + MediaQuery.viewPaddingOf(context).bottom,
                    child: _CollectDueActionBar(
                      amount: state.booking.amountDueForCollection,
                      onCollect: () => _collectDue(context, state.booking),
                    ),
                  );
                }
                if (!isFutsalView &&
                    state.canCancel &&
                    state.cancelStatus != CancelBookingStatus.cancelled &&
                    (state.booking.status == BookingStatus.pending ||
                        state.booking.status == BookingStatus.confirmed)) {
                  return SizedBox(
                    height: 70 + MediaQuery.viewPaddingOf(context).bottom,
                    child: _CancelBookingBar(
                      onCancel:
                          onCancelBooking ?? () => _confirmAndCancel(context),
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
            return Column(
              children: [
                if (state.status == BookingDetailsStatus.loading)
                  LinearProgressIndicator(
                    minHeight: 2,
                    color: LightColor.secondaryColor,
                    backgroundColor: LightColor.dividerColor,
                  ),
                if (state.status == BookingDetailsStatus.failure)
                  BookingErrorBanner(
                    message:
                        state.errorMessage ??
                        'Could not load the latest booking details.',
                    onRetry: () => context.read<BookingDetailsBloc>().add(
                      FetchBookingDetailsEvent(booking.id),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      BookingDetailsSpacing.page,
                      12,
                      BookingDetailsSpacing.page,
                      28,
                    ),
                    children: [
                      _BookingSummary(
                        booking: booking,
                        isFutsalView: isFutsalView,
                      ),
                      const _SectionGap(),
                      const BookingSectionHeader(title: 'Booking information'),
                      const _HeaderGap(),
                      _BookingInformation(booking: booking),
                      if (isFutsalView) ...[
                        const _SectionGap(),
                        const BookingSectionHeader(title: 'Customer'),
                        const _HeaderGap(),
                        _CustomerCard(
                          booking: booking,
                          onChat:
                              onChatCustomer ??
                              ((booking.playerId ?? 0) > 0
                                  ? () => _chatWithCustomer(context, booking)
                                  : null),
                        ),
                      ] else ...[
                        const _SectionGap(),
                        const BookingSectionHeader(
                          title: StringConstants.vendor,
                        ),
                        const _HeaderGap(),
                        _VenueHostCard(
                          booking: booking,
                          onChat:
                              onChatVenue ??
                              ((booking.venueId ?? 0) > 0
                                  ? () => _chatWithVenue(context, booking)
                                  : null),
                        ),
                      ],
                      // Vendors can sell add-ons; customers still see what was
                      // charged to their booking.
                      if ((isFutsalView && bookingSupportsProducts(booking)) ||
                          booking.extraItems.isNotEmpty) ...[
                        const _SectionGap(),
                        const BookingSectionHeader(title: 'Products'),
                        const _HeaderGap(),
                        BookingProductsSection(
                          booking: booking,
                          canAdd:
                              isFutsalView && bookingSupportsProducts(booking),
                          onChanged: () => context
                              .read<BookingDetailsBloc>()
                              .add(FetchBookingDetailsEvent(booking.id)),
                        ),
                      ],
                      const _SectionGap(),
                      const BookingSectionHeader(title: 'Payment summary'),
                      const _HeaderGap(),
                      _PaymentCard(booking: booking),
                      if (booking.payment != null) ...[
                        const _SectionGap(),
                        const BookingSectionHeader(title: 'Payment proof'),
                        const _HeaderGap(),
                        Builder(
                          builder: (context) {
                            final String verification =
                                booking.payment!.verificationStatus
                                    ?.trim()
                                    .toLowerCase() ??
                                'pending';
                            final bool verificationPending =
                                verification != 'accepted' &&
                                verification != 'verified' &&
                                verification != 'rejected';
                            final bool paymentSettled =
                                state.paymentStatus ==
                                    PaymentActionStatus.verified ||
                                state.paymentStatus ==
                                    PaymentActionStatus.rejected;
                            final bool canDecide =
                                isFutsalView &&
                                booking.status == BookingStatus.pending &&
                                verificationPending &&
                                !paymentSettled;
                            return _PaymentProofCard(
                              payment: booking.payment!,
                              isLoading:
                                  state.paymentStatus ==
                                  PaymentActionStatus.submitting,
                              onAccept: canDecide
                                  ? () => _verifyPayment(context)
                                  : null,
                              onReject: canDecide
                                  ? () => _rejectPayment(context)
                                  : null,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CancelBookingSheet extends StatelessWidget {
  const _CancelBookingSheet();

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstants.cancelBooking,
          style: textTheme.bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          StringConstants.cancelBookingConfirmation,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                key: const Key('keep-booking-button'),
                text: StringConstants.keepBooking,
                onPressed: () => Navigator.of(context).pop(false),
                minHeight: AppDimens.sizeX42,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                key: const Key('confirm-cancel-booking-button'),
                text: StringConstants.cancelBooking,
                onPressed: () => Navigator.of(context).pop(true),
                backgroundColor: LightColor.redColor,
                minHeight: AppDimens.sizeX42,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RejectResult {
  const _RejectResult({this.note});
  final String? note;
}

class _PaymentProofAcceptResult {
  const _PaymentProofAcceptResult({required this.actualAmount, this.note});

  final double actualAmount;
  final String? note;
}

class _PaymentProofAcceptSheet extends StatefulWidget {
  const _PaymentProofAcceptSheet({required this.payment});

  final BookingPaymentModel payment;

  @override
  State<_PaymentProofAcceptSheet> createState() =>
      _PaymentProofAcceptSheetState();
}

class _PaymentProofAcceptSheetState extends State<_PaymentProofAcceptSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _amountInputValue(widget.payment.amount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final double amount =
        double.tryParse(_amountController.text.trim()) ?? widget.payment.amount;
    final String note = _noteController.text.trim();
    Navigator.of(context).pop(
      _PaymentProofAcceptResult(
        actualAmount: amount,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConstants.approvePayment,
            style: textTheme.bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            StringConstants.approvePaymentProofConfirmation,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            key: const Key('payment-proof-actual-amount-field'),
            labelText: StringConstants.actualAmount,
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (String? value) {
              final double? amount = double.tryParse(value?.trim() ?? '');
              if (amount == null || amount <= 0) {
                return StringConstants.enterValidAmount;
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            key: const Key('payment-proof-remarks-field'),
            labelText: StringConstants.paymentNote,
            hintText: StringConstants.addARemarkInvoiceRefEtc,
            controller: _noteController,
            isRequired: false,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomCancelButton(
                  onPressed: () => Navigator.of(context).pop(),
                  minHeight: AppDimens.sizeX42,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  key: const Key('confirm-payment-proof-accept-button'),
                  text: StringConstants.approvePayment,
                  onPressed: _submit,
                  minHeight: AppDimens.sizeX42,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentProofRejectSheet extends StatefulWidget {
  const _PaymentProofRejectSheet();

  @override
  State<_PaymentProofRejectSheet> createState() =>
      _PaymentProofRejectSheetState();
}

class _PaymentProofRejectSheetState extends State<_PaymentProofRejectSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final String note = _noteController.text.trim();
    Navigator.of(context).pop(_RejectResult(note: note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstants.rejectPayment,
          style: textTheme.bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          StringConstants.rejectBookingConfirmation,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          key: const Key('payment-proof-reject-reason-field'),
          labelText: StringConstants.rejectionReason,
          hintText: StringConstants.rejectionReasonHint,
          controller: _noteController,
          isRequired: false,
          maxLines: 3,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomCancelButton(
                onPressed: () => Navigator.of(context).pop(),
                minHeight: AppDimens.sizeX42,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                key: const Key('confirm-payment-proof-reject-button'),
                text: StringConstants.reject,
                onPressed: _submit,
                backgroundColor: LightColor.redColor,
                minHeight: AppDimens.sizeX42,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RejectBookingSheet extends StatefulWidget {
  const _RejectBookingSheet();

  @override
  State<_RejectBookingSheet> createState() => _RejectBookingSheetState();
}

class _RejectBookingSheetState extends State<_RejectBookingSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final String note = _noteController.text.trim();
    Navigator.of(context).pop(_RejectResult(note: note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstants.rejectBooking,
          style: textTheme.bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          StringConstants.rejectBookingConfirmation,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          key: const Key('reject-note-field'),
          labelText: StringConstants.rejectionReason,
          controller: _noteController,
          isRequired: false,
          maxLines: 3,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomCancelButton(
                onPressed: () => Navigator.of(context).pop(),
                minHeight: AppDimens.sizeX42,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                key: const Key('confirm-reject-booking-button'),
                text: StringConstants.reject,
                onPressed: _submit,
                backgroundColor: LightColor.redColor,
                minHeight: AppDimens.sizeX42,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fixed vertical rhythm helpers so every section is spaced identically.
class _SectionGap extends StatelessWidget {
  const _SectionGap();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: BookingDetailsSpacing.sectionGap);
}

class _HeaderGap extends StatelessWidget {
  const _HeaderGap();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: BookingDetailsSpacing.headerGap);
}

class _BookingDecisionBar extends StatelessWidget {
  const _BookingDecisionBar({
    required this.onAccept,
    required this.onReject,
    required this.isLoading,
    this.canAccept = true,
  });

  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isLoading;

  /// Accept is only tappable once the payment proof has been verified.
  final bool canAccept;

  @override
  Widget build(BuildContext context) {
    return BookingActionBar(
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
              onPressed: (isLoading || !canAccept) ? null : onAccept ?? () {},
              backgroundColor: canAccept
                  ? LightColor.secondaryColor
                  : LightColor.buttonDisabledColor,
              minHeight: AppDimens.sizeX42,
            ),
          ),
        ],
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
    return BookingActionBar(
      child: CustomButton(
        key: const Key('cancel-booking-button'),
        text: StringConstants.cancelBooking,
        onPressed: isLoading ? null : onCancel ?? () {},
        isOutlined: true,
        foregroundColor: LightColor.redColor,
        borderColor: LightColor.redColor,
        minHeight: AppDimens.sizeX42,
      ),
    );
  }
}

class _ConfirmedActionsBar extends StatelessWidget {
  const _ConfirmedActionsBar({
    required this.onComplete,
    required this.isLoading,
    this.amountToCollect = 0,
  });

  final VoidCallback onComplete;
  final bool isLoading;

  /// Shown beside the action so the vendor sees what they are collecting.
  final double amountToCollect;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return BookingActionBar(
      child: Row(
        children: [
          if (amountToCollect > 0) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'To collect',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                  Text(
                    bookingCurrency(amountToCollect),
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: amountToCollect > 0 ? 2 : 1,
            child: CustomButton(
              key: const Key('complete-booking-button'),
              text: 'Complete',
              icon: Icons.check_circle_outline_rounded,
              onPressed: isLoading ? null : onComplete,
              backgroundColor: LightColor.secondaryColor,
              minHeight: AppDimens.sizeX42,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectDueActionBar extends StatelessWidget {
  const _CollectDueActionBar({required this.amount, required this.onCollect});

  final double amount;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return BookingActionBar(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Due amount',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
                Text(
                  bookingCurrency(amount),
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            flex: 2,
            child: CustomButton(
              key: const Key('collect-due-button'),
              text: 'Collect due',
              icon: Icons.payments_outlined,
              onPressed: onCollect,
              minHeight: AppDimens.sizeX42,
            ),
          ),
        ],
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

    return BookingDetailCard(
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
                        fontSize: AppDimens.fontHeadingSubTitle,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 14),
          Text(
            booking.displayTimeRange.isEmpty
                ? bookingFormatDate(booking.date)
                : '${bookingFormatDate(booking.date)} · '
                      '${booking.displayTimeRange}',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (booking.bookingRef.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${StringConstants.bookingId} ${booking.bookingRef}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _BookingInformation extends StatelessWidget {
  const _BookingInformation({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final String? bookingType = bookingTypeLabel(booking.bookingType);
    final List<Widget> rows = <Widget>[
      // Time is already the hero fact — not repeated here.
      BookingDetailRow(
        label: StringConstants.venue,
        value: booking.futsalName.isEmpty ? '—' : booking.futsalName,
        subtitle: booking.futsalAddress,
      ),
      BookingDetailRow(
        label: StringConstants.court,
        value: booking.courtName.isEmpty ? '—' : booking.courtName,
      ),
      if (bookingType != null)
        BookingDetailRow(label: StringConstants.bookedVia, value: bookingType),
      if (booking.isRecurring)
        BookingDetailRow(
          label: StringConstants.recurrence,
          value: _recurrenceLabel(booking),
          subtitle:
              booking.recurrenceStartDate != null &&
                  booking.recurrenceEndDate != null
              ? '${bookingFormatShortDate(booking.recurrenceStartDate!)} – '
                    '${bookingFormatShortDate(booking.recurrenceEndDate!)}'
              : null,
        ),
      if (booking.notes?.trim().isNotEmpty == true)
        BookingDetailRow(label: StringConstants.notes, value: booking.notes!),
    ];

    return BookingDetailCard(
      padding: EdgeInsets.zero,
      child: Column(children: bookingRowsWithDividers(rows)),
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

    return BookingDetailCard(
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

    return BookingDetailCard(
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
        color: LightColor.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          side: BorderSide(color: LightColor.dividerColor),
        ),
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
    final double extras = booking.extraItemsTotal;
    // Extras are billed on top of the booking amount (same rule the complete-
    // booking sheet settles on).
    final double grandTotal = booking.grandTotal;
    final double outstanding = switch (booking.status) {
      BookingStatus.completed => booking.amountDueForCollection,
      BookingStatus.confirmed => booking.amountDueForCompletion,
      _ => booking.remainingBookingBalance,
    };
    final double paid = booking.effectivePaidAmount;
    final bool hasSettlement =
        booking.payableNow > 0 ||
        booking.balanceDueLater > 0 ||
        paid > 0 ||
        outstanding > 0;

    return BookingDetailCard(
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
                BookingStatusPill(
                  label: bookingTitleCase(paymentStatus!),
                  color: bookingPaymentStatusColor(paymentStatus),
                ),
              ],
            ),
            const SizedBox(height: BookingDetailsSpacing.rowGap + 4),
          ],

          // ── Charges ──
          BookingAmountRow(
            label: booking.slotCount > 0 && booking.pricePerSlot > 0
                ? '${StringConstants.subtotal} '
                      '(${booking.slotCount} × ${bookingCurrency(booking.pricePerSlot)})'
                : StringConstants.subtotal,
            value: bookingCurrency(subtotal),
          ),
          if (booking.discountAmount > 0) ...[
            const SizedBox(height: BookingDetailsSpacing.rowGap),
            BookingAmountRow(
              label: couponCode?.isNotEmpty == true
                  ? 'Discount ($couponCode)'
                  : 'Discount',
              value: '- ${bookingCurrency(booking.discountAmount)}',
              valueColor: LightColor.secondaryColor,
            ),
          ],
          if (booking.taxAmount > 0) ...[
            const SizedBox(height: BookingDetailsSpacing.rowGap),
            BookingAmountRow(
              label: StringConstants.tax,
              value: bookingCurrency(booking.taxAmount),
            ),
          ],
          const _CardDivider(),
          BookingAmountRow(
            label: extras > 0 ? 'Booking total' : StringConstants.total,
            value: bookingCurrency(booking.bookingTotal),
            labelWeight: FontWeight.w700,
            valueWeight: FontWeight.w700,
            valueSize: extras > 0 ? null : AppDimens.fontBodyTextLarge,
          ),
          if (extras > 0) ...[
            const SizedBox(height: BookingDetailsSpacing.rowGap),
            BookingAmountRow(
              label:
                  'Products (${booking.extraItemsCount} '
                  '${booking.extraItemsCount == 1 ? 'item' : 'items'})',
              value: '+ ${bookingCurrency(extras)}',
            ),
            const SizedBox(height: 12),
            BookingTotalHighlight(
              label: 'Grand total',
              value: bookingCurrency(grandTotal),
            ),
          ],

          // ── Settlement ──
          if (hasSettlement) const _CardDivider(),
          if (booking.payableNow > 0)
            BookingAmountRow(
              label: StringConstants.payableNow,
              value: bookingCurrency(booking.payableNow),
            ),
          if (booking.balanceDueLater > 0) ...[
            if (booking.payableNow > 0)
              const SizedBox(height: BookingDetailsSpacing.rowGap),
            BookingAmountRow(
              label: StringConstants.balanceDueLater,
              value: bookingCurrency(booking.balanceDueLater),
            ),
          ],
          if (paid > 0) ...[
            if (booking.payableNow > 0 || booking.balanceDueLater > 0)
              const SizedBox(height: BookingDetailsSpacing.rowGap),
            BookingAmountRow(
              label: StringConstants.paidAmount,
              value: bookingCurrency(paid),
              valueColor: LightColor.secondaryColor,
            ),
          ],
          if (outstanding > 0) ...[
            const SizedBox(height: 12),
            BookingTotalHighlight(
              label: StringConstants.balanceDue,
              caption: extras > 0 ? 'Includes products sold' : null,
              value: bookingCurrency(outstanding),
              color: LightColor.warningColor,
            ),
          ],
          if (booking.payment?.method?.trim().isNotEmpty == true) ...[
            const _CardDivider(),
            Row(
              children: [
                Icon(
                  Icons.credit_card_rounded,
                  size: AppDimens.sizeX14,
                  color: LightColor.iconGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  'Paid via ${bookingTitleCase(booking.payment!.method!)}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w500,
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

/// Hairline separator between the groups of a card (charges / totals /
/// settlement), with the vertical rhythm baked in.
class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: LightColor.dividerColor),
    );
  }
}

class _PaymentProofCard extends StatelessWidget {
  const _PaymentProofCard({
    required this.payment,
    this.onAccept,
    this.onReject,
    this.isLoading = false,
  });

  final BookingPaymentModel payment;

  /// When provided (futsal view, decision still pending) compact accept/reject
  /// actions are rendered on the payment proof itself.
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final String? proofUrl = _paymentProofUrl(payment);
    final bool hasProof =
        payment.hasPaymentProof ||
        payment.paymentProofUrl?.trim().isNotEmpty == true ||
        payment.paymentProofPath?.trim().isNotEmpty == true;
    final String verification = payment.verificationStatus?.trim() ?? 'pending';
    final bool showDecisionActions = onAccept != null && onReject != null;

    return BookingDetailCard(
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
              BookingStatusPill(
                label: bookingTitleCase(verification),
                color: bookingVerificationColor(verification),
              ),
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
                            color: LightColor.shadowOf(0.7),
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
          if (showDecisionActions) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: LightColor.dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    key: const Key('proof-reject-button'),
                    text: StringConstants.reject,
                    icon: Icons.close_rounded,
                    onPressed: isLoading ? null : onReject,
                    isOutlined: true,
                    foregroundColor: LightColor.redColor,
                    borderColor: LightColor.redColor,
                    minHeight: AppDimens.sizeX38,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    key: const Key('proof-accept-button'),
                    text: StringConstants.accept,
                    icon: Icons.check_rounded,
                    onPressed: isLoading ? null : onAccept,
                    minHeight: AppDimens.sizeX38,
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

String _recurrenceLabel(BookingModel booking) {
  final String type = booking.recurrenceType?.trim() ?? '';
  final String recurrence = type.isEmpty ? 'Recurring' : bookingTitleCase(type);
  return booking.isSeriesAnchor ? '$recurrence · Series booking' : recurrence;
}

String _amountInputValue(double value) {
  if (value <= 0) return '';
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
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
