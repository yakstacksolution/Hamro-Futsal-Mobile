import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/scroll_behavior.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/payment_qr_card.dart';
import 'package:hamro_footsall/features/coupons/data/model/coupon_model.dart';
import 'package:hamro_footsall/features/coupons/presentation/bloc/coupon_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_quote_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/create_booking_request.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/booking_hold/booking_hold_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/create_booking/create_booking_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/payment_qr/payment_qr_bloc.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class BookingCheckoutPage extends StatefulWidget {
  const BookingCheckoutPage({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<BookingCheckoutPage> createState() => _BookingCheckoutPageState();
}

class _BookingCheckoutPageState extends State<BookingCheckoutPage>
    with WidgetsBindingObserver {
  final TextEditingController _couponCtrl = TextEditingController();

  static const List<String> _docExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'pdf',
  ];
  static const int _maxDocBytes = 10 * 1024 * 1024;

  static const String _payeeName = 'Hamro Futsal Pvt. Ltd.';
  static const String _payeeId = '9800000000';

  // Payment method is fixed to cash for now (sent as `payment_method`).
  static const String _paymentMethod = 'cash';

  PlatformFile? _paymentDoc;
  bool _agreedToTerms = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Place a temporary hold on the slot as soon as the page opens.
    final BookingDraft draft = widget.draft;
    final String startTime = draft.apiTime ?? '';
    if (startTime.isNotEmpty) {
      context.read<BookingHoldBloc>().add(
        CreateBookingHoldEvent(
          venueId: draft.venueId,
          courtId: draft.courtId,
          bookingDate: _apiDate(draft.selectedDate),
          startTime: startTime,
          endTime: draft.apiEndTime ?? '',
          bookingDates: draft.isRecurring
              ? draft.sessionDates.map(_apiDate).toList(growable: false)
              : const <String>[],
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Release the hold if the app is being closed/terminated while the
    // checkout page is still open. (Back navigation is handled on bloc close.)
    if (state == AppLifecycleState.detached) {
      context.read<BookingHoldBloc>().add(const ReleaseBookingHoldEvent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _couponCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => widget.draft.subtotal;

  bool get _canConfirm => _paymentDoc != null && _agreedToTerms;

  /// Effective server quote: from the coupon-apply response once a coupon is
  /// applied, otherwise from the initial booking-hold quote. [holdQuote] is the
  /// hold's quote passed by the caller.
  BookingQuoteModel? _effectiveQuote(
    CouponState coupon,
    BookingQuoteModel? holdQuote,
  ) => coupon.applied?.quote ?? holdQuote;

  /// Builds the display figures straight from the server quote — no client-side
  /// computation. Until the quote arrives, [_Pricing.ready] is false and the UI
  /// shows a loading state instead of computed numbers.
  ///
  /// Scalar amounts (advance/total/etc.) are taken from `calculation_list`
  /// first so the bottom bar and sheets always match the breakdown card, then
  /// fall back to `price_details`.
  _Pricing _pricingFor(CouponState coupon, {BookingQuoteModel? quote}) {
    final BookingQuoteModel? effective = _effectiveQuote(coupon, quote);
    final BookingPriceDetailsModel? price = effective?.priceDetails;
    final List<BookingCalculationLineModel> lines =
        effective?.calculationList ?? const <BookingCalculationLineModel>[];

    return _Pricing(
      subtotal: _lineAmount(lines, 'subtotal') ?? price?.subtotal ?? 0,
      discount:
          _lineAmount(lines, 'discount_amount') ?? price?.discountAmount ?? 0,
      total: _lineAmount(lines, 'booking_total') ?? price?.bookingTotal ?? 0,
      advance:
          _lineAmount(lines, 'advance_payable_now') ??
          price?.advancePayableNow ??
          0,
      balanceDue:
          _lineAmount(lines, 'balance_due_later') ??
          price?.balanceDueLater ??
          0,
      hasCoupon: coupon.hasApplied,
      lines: lines,
      items: effective?.items ?? const <BookingSessionItemModel>[],
      ready: price != null || lines.isNotEmpty,
    );
  }

  /// Returns the amount of the `calculation_list` row with [key], or null.
  double? _lineAmount(List<BookingCalculationLineModel> lines, String key) {
    for (final BookingCalculationLineModel line in lines) {
      if (line.key == key) return line.amount;
    }
    return null;
  }

  /// Opens the full price breakdown: per-session (day-by-day) amounts plus the
  /// overall totals — all from the server quote (booking-hold / apply-coupon).
  void _showPriceDetailsSheet(_Pricing pricing) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) =>
          _PriceDetailsSheet(items: pricing.items, lines: pricing.lines),
    );
  }

  String _apiDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  void _applyCoupon() {
    FocusScope.of(context).unfocus();
    final BookingDraft draft = widget.draft;
    context.read<CouponBloc>().add(
      ApplyCouponEvent(
        code: _couponCtrl.text.trim().toUpperCase(),
        venueId: draft.venueId,
        courtId: draft.courtId,
        bookingDate: _apiDate(draft.selectedDate),
        startTime: draft.apiTime ?? '',
        endTime: draft.apiEndTime,
        repeatWeeks: draft.isRecurring ? draft.sessions : null,
        holdToken: context.read<BookingHoldBloc>().state.holdToken,
        amount: _subtotal,
      ),
    );
  }

  void _selectCoupon(String code) {
    HapticFeedback.selectionClick();
    _couponCtrl.text = code;
    _applyCoupon();
  }

  void _removeCoupon() {
    _couponCtrl.clear();
    context.read<CouponBloc>().add(const RemoveCouponEvent());
  }

  Future<void> _pickPaymentDoc() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _docExtensions,
    );
    final PlatformFile? file = result?.files.singleOrNull;
    if (file == null || !mounted || file.path == null) return;
    if (file.size > _maxDocBytes) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Payment proof must be smaller than 10 MB.',
        key: 'doc_too_large',
      );
      return;
    }
    setState(() => _paymentDoc = file);
  }

  Future<void> _confirmBooking() async {
    setState(() => _submitted = true);
    if (_paymentDoc == null) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Please upload your payment proof.',
        key: 'doc_required',
      );
      return;
    }
    if (!_agreedToTerms) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Please accept the booking terms.',
        key: 'terms_required',
      );
      return;
    }

    HapticFeedback.selectionClick();

    final CouponState coupon = context.read<CouponBloc>().state;
    final BookingQuoteModel? quote = context
        .read<BookingHoldBloc>()
        .state
        .hold
        ?.quote;
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _BookingOverviewSheet(
        draft: widget.draft,
        pricing: _pricingFor(coupon, quote: quote),
        couponCode: coupon.hasApplied ? coupon.appliedCode : null,
        paymentMethodLabel: 'Online (QR) · proof attached',
        paymentProofName: _paymentDoc?.name,
      ),
    );

    if (confirmed != true || !mounted) return;
    _submitBooking();
  }

  void _submitBooking() {
    HapticFeedback.mediumImpact();
    final BookingDraft draft = widget.draft;
    final CouponState coupon = context.read<CouponBloc>().state;

    context.read<CreateBookingBloc>().add(
      SubmitBookingEvent(
        CreateBookingRequest(
          venueId: draft.venueId,
          courtId: draft.courtId,
          bookingDate: _apiDate(draft.selectedDate),
          startTime: draft.apiTime ?? '',
          endTime: draft.apiEndTime,
          paymentMethod: _paymentMethod,
          couponCode: coupon.hasApplied ? coupon.appliedCode : null,
          repeatWeeks: draft.isRecurring ? draft.sessions : null,
          paymentProofPath: _paymentDoc?.path,
        ),
      ),
    );
  }

  Future<void> _showSuccessSheet(_Pricing pricing) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _BookingSuccessSheet(
        draft: widget.draft,
        advance: pricing.advance,
        balanceDue: pricing.balanceDue,
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final BookingDraft draft = widget.draft;
    final CouponState coupon = context.watch<CouponBloc>().state;
    final BookingQuoteModel? quote = context
        .watch<BookingHoldBloc>()
        .state
        .hold
        ?.quote;
    final _Pricing pricing = _pricingFor(coupon, quote: quote);
    final bool showCoupons = coupon.hasApplied || coupon.hasActiveCoupon;
    return BlocListener<CreateBookingBloc, CreateBookingState>(
      listenWhen: (CreateBookingState p, CreateBookingState c) =>
          p.status != c.status,
      listener: (BuildContext context, CreateBookingState state) {
        if (state.status == CreateBookingStatus.success) {
          context.read<BookingHoldBloc>().add(
            const MarkBookingHoldConsumedEvent(),
          );
          _showSuccessSheet(
            _pricingFor(
              context.read<CouponBloc>().state,
              quote: context.read<BookingHoldBloc>().state.hold?.quote,
            ),
          );
        } else if (state.status == CreateBookingStatus.failure) {
          AppUtils().showSnackBar(
            context,
            MsgType.error,
            state.errorMessage ?? 'Could not create booking. Please try again.',
            key: 'booking_failed',
          );
        }
      },
      child: ScrollConfiguration(
        behavior: FutsalScrollBehavior(),
        child: Scaffold(
          backgroundColor: LightColor.background,
          appBar: const CustomAppBar(title: StringConstants.confirmBooking),
          body: SafeArea(
            top: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: AppUtils().getPadding(
                left: AppDimens.paddingX20,
                right: AppDimens.paddingX20,
                top: AppDimens.paddingX12,
                bottom: AppDimens.paddingX24,
              ),
              children: <Widget>[
                const _SectionLabel('Booking summary'),
                _SummaryCard(draft: draft),
                const SizedBox(height: AppDimens.sizeX20),

                if (showCoupons) ...<Widget>[
                  const _SectionLabel('Apply coupon'),
                  const SizedBox(height: AppDimens.sizeX6),
                  _CouponField(
                    controller: _couponCtrl,
                    coupon: coupon,
                    subtotal: _subtotal,
                    onApply: _applyCoupon,
                    onRemove: _removeCoupon,
                    onSelectCoupon: _selectCoupon,
                  ),
                  const SizedBox(height: AppDimens.sizeX20),
                ],

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const _SectionLabel('Price details'),
                    if (pricing.items.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showPriceDetailsSheet(pricing),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: AppUtils().getPadding(
                            left: AppDimens.paddingX4,
                            bottom: AppDimens.paddingX8,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: AppDimens.sizeX16,
                            color: LightColor.secondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                _PriceBreakdown(lines: pricing.lines, ready: pricing.ready),
                const SizedBox(height: AppDimens.sizeX20),

                const _SectionLabel('Payment'),
                Builder(
                  builder: (context) {
                    final PaymentQrState qrState = context
                        .watch<PaymentQrBloc>()
                        .state;
                    return PaymentQrCard(
                      qr: qrState.qr,
                      isLoading: qrState.isLoading,
                      fallbackPayeeName: _payeeName,
                      fallbackPayeeId: _payeeId,
                      amountLabel: StringConstants.advanceToPay,
                      amountValue: 'Rs ${pricing.advance.toStringAsFixed(0)}',
                    );
                  },
                ),
                const SizedBox(height: AppDimens.sizeX20),

                const _SectionLabel('Payment proof'),
                _UploadCard(
                  file: _paymentDoc,
                  highlightMissing: _submitted && _paymentDoc == null,
                  onPick: _pickPaymentDoc,
                  onRemove: () => setState(() => _paymentDoc = null),
                ),
                const SizedBox(height: AppDimens.sizeX12),
                const _PaymentNoteCard(),
                const SizedBox(height: AppDimens.sizeX16),

                _TermsCheckbox(
                  value: _agreedToTerms,
                  highlightMissing: _submitted && !_agreedToTerms,
                  onChanged: (bool v) => setState(() => _agreedToTerms = v),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(pricing),
        ),
      ),
    );
  }

  Widget _buildBottomBar(_Pricing pricing) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool submitting = context
        .watch<CreateBookingBloc>()
        .state
        .isSubmitting;
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX20,
        vertical: AppDimens.paddingX14,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        border: Border(
          top: BorderSide(
            color: LightColor.dividerColor.withValues(alpha: 0.8),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  StringConstants.payNowAdvance,
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  pricing.ready
                      ? 'Rs ${pricing.advance.toStringAsFixed(0)}'
                      : '—',
                  style: textTheme.headingSubTitle?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  pricing.ready
                      ? 'Total Rs ${pricing.total.toStringAsFixed(0)}'
                      : 'Total —',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimens.sizeX16),
            Expanded(
              child: SizedBox(
                height: AppDimens.sizeX50,
                child: CustomButton(
                  text: submitting ? 'Confirming…' : 'Confirm Booking',
                  isLoading: submitting,
                  onPressed: submitting ? null : _confirmBooking,
                  backgroundColor: _canConfirm
                      ? LightColor.secondaryColor
                      : LightColor.secondaryColor.withValues(alpha: 0.45),
                  foregroundColor: LightColor.inverseTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────── Reusable bits ───────────────────────────

/// A small, quiet section label above each card.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        bottom: AppDimens.paddingX8,
        left: AppDimens.paddingX2,
      ),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: borderColor ?? LightColor.dividerColor.withValues(alpha: 0.9),
        ),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppDimens.sizeX12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style:
                (emphasize ? textTheme.bodyTextMedium : textTheme.bodyTextSmall)
                    ?.copyWith(
                      color:
                          valueColor ??
                          (emphasize
                              ? LightColor.secondaryColor
                              : LightColor.primaryTextColor),
                      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                    ),
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────── Summary ───────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String timeRange = draft.endTime == null
        ? draft.selectedTime
        : '${draft.selectedTime} – ${draft.endTime}';

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CustomImageView(
                url: draft.courtImage,
                imagePath: draft.courtImage.isEmpty
                    ? 'assets/images/image_placeholder_normal.png'
                    : null,
                width: AppDimens.sizeX64,
                height: AppDimens.sizeX64,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      draft.courtName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX4),
                    Text(
                      '${draft.matchType} · ${draft.courtType}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: AppUtils().getPadding(
              symmetricVertical: AppDimens.paddingX14,
            ),
            child: Divider(
              height: 1,
              color: LightColor.dividerColor.withValues(alpha: 0.8),
            ),
          ),
          _InfoRow(
            label: draft.isRecurring ? 'Starts' : 'Date',
            value: _dateLabel(draft.selectedDate),
          ),
          const SizedBox(height: AppDimens.sizeX10),
          _InfoRow(label: StringConstants.time, value: timeRange),
          const SizedBox(height: AppDimens.sizeX10),
          _InfoRow(
            label: StringConstants.players,
            value: 'Up to ${draft.maxPlayers}',
          ),
          if (draft.isRecurring) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            _InfoRow(
              label: StringConstants.repeats,
              value:
                  'Weekly · ${draft.recurrenceLabel ?? ''} · ${draft.sessions} sessions',
            ),
          ],
        ],
      ),
    );
  }
}

class _CouponField extends StatelessWidget {
  const _CouponField({
    required this.controller,
    required this.coupon,
    required this.subtotal,
    required this.onApply,
    required this.onRemove,
    required this.onSelectCoupon,
  });

  final TextEditingController controller;
  final CouponState coupon;
  final double subtotal;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  final ValueChanged<String> onSelectCoupon;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    if (coupon.hasApplied) {
      return _Surface(
        borderColor: LightColor.secondaryColor.withValues(alpha: 0.5),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.check_circle_outline_rounded,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX20,
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '${coupon.appliedCode} ',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text:
                          'applied · saved Rs ${coupon.discount.toStringAsFixed(0)}',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Text(
                StringConstants.remove,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.redColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: CustomTextField(
                controller: controller,
                labelText: StringConstants.couponCode,
                hintText: StringConstants.enterCouponCode,
                icon: Icons.local_offer_outlined,
                isRequired: false,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onApply(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            SizedBox(
              width: AppDimens.sizeX90,
              height: AppDimens.sizeX48,
              child: CustomButton(
                text: StringConstants.apply,
                isLoading: coupon.isApplying,
                onPressed: onApply,
                isOutlined: true,
                foregroundColor: LightColor.secondaryColor,
                borderColor: LightColor.secondaryColor.withValues(alpha: 0.6),
                minWidth: AppDimens.sizeX80,
                borderRadius: AppDimens.radiusX6,
              ),
            ),
          ],
        ),
        if (coupon.applyError != null) ...<Widget>[
          const SizedBox(height: AppDimens.sizeX8),
          Padding(
            padding: AppUtils().getPadding(left: AppDimens.paddingX2),
            child: Text(
              coupon.applyError!,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        _buildAvailableCoupons(context, textTheme),
      ],
    );
  }

  Widget _buildAvailableCoupons(BuildContext context, dynamic textTheme) {
    if (coupon.isLoading && coupon.coupons.isEmpty) {
      return Padding(
        padding: AppUtils().getPadding(top: AppDimens.paddingX10),
        child: Text(
          StringConstants.loadingAvailableCoupons,
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: LightColor.hintTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    if (coupon.coupons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: AppUtils().getPadding(top: AppDimens.paddingX12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            StringConstants.availableOffers,
            style: textTheme.bodyMiniSubTitle?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX8),
          Wrap(
            spacing: AppDimens.sizeX8,
            runSpacing: AppDimens.sizeX8,
            children: coupon.coupons
                .map((CouponModel c) {
                  final bool eligible = c.meetsMinimum(subtotal);
                  return _CouponChip(
                    coupon: c,
                    enabled: eligible && !coupon.isApplying,
                    onTap: () => onSelectCoupon(c.code),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

/// A tappable suggestion chip for an active coupon.
class _CouponChip extends StatelessWidget {
  const _CouponChip({
    required this.coupon,
    required this.enabled,
    required this.onTap,
  });

  final CouponModel coupon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color accent = enabled
        ? LightColor.secondaryColor
        : LightColor.hintTextColor;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: AppUtils().getPadding(
          horizontal: AppDimens.paddingX10,
          vertical: AppDimens.paddingX6,
        ),
        decoration: BoxDecoration(
          color: enabled ? LightColor.secondarySoft : LightColor.inputFillColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.local_offer_rounded,
              size: AppDimens.sizeX14,
              color: accent,
            ),
            const SizedBox(width: AppDimens.sizeX6),
            Text(
              coupon.code,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppDimens.sizeX4),
            Text(
              '· ${coupon.label}',
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────── Price breakdown ───────────────────────────

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.lines, required this.ready});

  /// Server display rows (`quote.calculation_list`) — rendered verbatim.
  final List<BookingCalculationLineModel> lines;
  final bool ready;

  /// Formats a server amount as currency, keeping the server's sign
  /// (e.g. discount `-120` → `- Rs 120`).
  static String _money(double? amount) {
    final double value = amount ?? 0;
    final String abs = value.abs().toStringAsFixed(0);
    return value < 0 ? '- Rs $abs' : 'Rs $abs';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    if (!ready || lines.isEmpty) {
      return _Surface(
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: AppDimens.sizeX18,
              height: AppDimens.sizeX18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LightColor.secondaryColor,
              ),
            ),
            const SizedBox(width: AppDimens.sizeX12),
            Text(
              StringConstants.calculatingPrice,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Hide the coupon-discount row when there's no discount (no coupon applied).
    final List<BookingCalculationLineModel> visibleLines = lines
        .where(
          (BookingCalculationLineModel l) =>
              l.key != 'discount_amount' || (l.amount ?? 0) != 0,
        )
        .toList(growable: false);

    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < visibleLines.length; i++) {
      final BookingCalculationLineModel line = visibleLines[i];
      final bool emphasize = line.key == 'advance_payable_now';
      final bool isDiscount = line.key == 'discount_amount';

      if (i > 0) {
        // A divider before the advance row separates the payment split from
        // the totals; otherwise a plain gap between rows.
        rows.add(
          emphasize
              ? Padding(
                  padding: AppUtils().getPadding(
                    symmetricVertical: AppDimens.paddingX12,
                  ),
                  child: Divider(
                    height: 1,
                    color: LightColor.dividerColor.withValues(alpha: 0.8),
                  ),
                )
              : const SizedBox(height: AppDimens.sizeX10),
        );
      }

      rows.add(
        _InfoRow(
          label: line.label ?? '',
          value: _money(line.amount),
          emphasize: emphasize,
          valueColor: isDiscount ? LightColor.secondaryColor : null,
        ),
      );
    }

    return _Surface(child: Column(children: rows));
  }
}

/// ─────────────────────────── Price details sheet ───────────────────────────

/// A bottom sheet showing the full server quote: per-session (day-by-day)
/// amounts and the overall totals. Pure display of `quote.items` and
/// `quote.calculation_list` — no client-side math.
class _PriceDetailsSheet extends StatelessWidget {
  const _PriceDetailsSheet({required this.items, required this.lines});

  final List<BookingSessionItemModel> items;
  final List<BookingCalculationLineModel> lines;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
        top: AppDimens.paddingX12,
        bottom: AppDimens.paddingX24,
      ),
      decoration: const BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusX24),
          topRight: Radius.circular(AppDimens.radiusX24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: AppDimens.sizeX40,
                height: AppDimens.sizeX4,
                decoration: BoxDecoration(
                  color: LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX50),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            Text(
              StringConstants.priceBreakdown,
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX2),
            Text(
              '${items.length} ${items.length == 1 ? 'session' : 'sessions'}',
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.hintTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),

            if (items.isNotEmpty)
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.sizeX8),
                  itemBuilder: (BuildContext context, int index) =>
                      _SessionPriceRow(item: items[index], index: index),
                ),
              ),

            if (lines.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDimens.sizeX16),
              _PriceBreakdown(lines: lines, ready: true),
            ],
          ],
        ),
      ),
    );
  }
}

/// One day's price card inside the breakdown sheet.
class _SessionPriceRow extends StatelessWidget {
  const _SessionPriceRow({required this.item, required this.index});

  final BookingSessionItemModel item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final double discount = item.discountAmount ?? 0;

    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${index + 1}. ${_dayLabel(item.bookingDate)}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _PriceBreakdown._money(item.totalAmount),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX8),
          _MiniRow(
            label: StringConstants.subtotal,
            value: _PriceBreakdown._money(item.subtotal),
          ),
          if (discount > 0) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX4),
            _MiniRow(
              label: StringConstants.discount,
              value: '- ${_PriceBreakdown._money(discount)}',
              valueColor: LightColor.secondaryColor,
            ),
          ],
          const SizedBox(height: AppDimens.sizeX4),
          _MiniRow(
            label: StringConstants.advance,
            value: _PriceBreakdown._money(item.advanceAmount),
          ),
        ],
      ),
    );
  }

  /// Formats a `yyyy-MM-dd` string as a friendly label, falling back to raw.
  static String _dayLabel(String? raw) {
    if (raw == null) return '';
    final DateTime? date = DateTime.tryParse(raw);
    return date == null ? raw : _dateLabel(date);
  }
}

/// A compact label/value line used inside the per-session card.
class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMiniSubTitle?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: valueColor ?? LightColor.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────── Company QR ───────────────────────────

/// ─────────────────────────── Upload ───────────────────────────

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.file,
    required this.highlightMissing,
    required this.onPick,
    required this.onRemove,
  });

  final PlatformFile? file;
  final bool highlightMissing;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  bool get _isImage {
    final String ext = (file?.extension ?? '').toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png';
  }

  String _sizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    if (file == null) {
      return GestureDetector(
        onTap: onPick,
        child: Container(
          width: double.infinity,
          padding: AppUtils().getPadding(
            symmetricVertical: AppDimens.paddingX20,
            symmetricHorizontal: AppDimens.paddingX16,
          ),
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: highlightMissing
                  ? LightColor.redColor.withValues(alpha: 0.8)
                  : LightColor.dividerColor.withValues(alpha: 0.9),
            ),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.cloud_upload_outlined,
                color: highlightMissing
                    ? LightColor.redColor
                    : LightColor.secondaryColor,
                size: AppDimens.sizeX28,
              ),
              const SizedBox(height: AppDimens.sizeX8),
              Text(
                StringConstants.uploadPaymentReceipt,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                StringConstants.jpgPngOrPdfUpTo10Mb,
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.hintTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final PlatformFile picked = file!;
    return _Surface(
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            child: _isImage && picked.path != null
                ? Image.file(
                    File(picked.path!),
                    width: AppDimens.sizeX48,
                    height: AppDimens.sizeX48,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: AppDimens.sizeX48,
                    height: AppDimens.sizeX48,
                    color: LightColor.inputFillColor,
                    child: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
          ),
          const SizedBox(width: AppDimens.sizeX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  picked.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  'Attached · ${_sizeLabel(picked.size)}',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onPick,
            child: Text(
              StringConstants.change,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: StringConstants.remove,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.close_rounded,
              size: AppDimens.sizeX18,
              color: LightColor.hintTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentNoteCard extends StatelessWidget {
  const _PaymentNoteCard();

  static const List<String> _notes = <String>[
    'Please pay the exact amount shown for your booking.',
    'In the payment remarks, type: "Hamro Futsal Booking".',
    'After completing the payment, upload a clear screenshot of the payment confirmation receipt.',
    'Bookings with an incorrect payment amount or unclear/invalid screenshot may be cancelled.',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.info_outline_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.secondaryColor,
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Text(
                StringConstants.importantNote,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX10),
          ..._notes.map(
            (String note) => Padding(
              padding: AppUtils().getPadding(bottom: AppDimens.paddingX8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: AppUtils().getPadding(top: AppDimens.paddingX6),
                    child: Container(
                      width: AppDimens.sizeX4,
                      height: AppDimens.sizeX4,
                      decoration: const BoxDecoration(
                        color: LightColor.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX8),
                  Expanded(
                    child: Text(
                      note,
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.highlightMissing,
    required this.onChanged,
  });

  final bool value;
  final bool highlightMissing;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: AppDimens.sizeX20,
            height: AppDimens.sizeX20,
            decoration: BoxDecoration(
              color: value ? LightColor.secondaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusX4),
              border: Border.all(
                color: value
                    ? LightColor.secondaryColor
                    : highlightMissing
                    ? LightColor.redColor
                    : LightColor.dividerColor,
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    size: AppDimens.sizeX14,
                    color: LightColor.inverseTextColor,
                  )
                : null,
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Expanded(
            child: Text(
              StringConstants
                  .iConfirmTheBookingDetailsAreCorrectAndAcceptTheCabab03b,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────── Overview sheet ───────────────────────────

/// Shown when the user taps "Confirm Booking": a final review of the booking
/// and price. Pops `true` when the user confirms, after which the booking is
/// actually created.
class _BookingOverviewSheet extends StatelessWidget {
  const _BookingOverviewSheet({
    required this.draft,
    required this.pricing,
    required this.couponCode,
    required this.paymentMethodLabel,
    required this.paymentProofName,
  });

  final BookingDraft draft;
  final _Pricing pricing;
  final String? couponCode;
  final String paymentMethodLabel;
  final String? paymentProofName;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String timeRange = draft.endTime == null
        ? draft.selectedTime
        : '${draft.selectedTime} – ${draft.endTime}';
    final String recurrence = draft.recurrenceLabel?.trim().isNotEmpty == true
        ? draft.recurrenceLabel!.trim()
        : '${draft.sessions} sessions';
    final List<DateTime> sessionDates = draft.sessionDates.isEmpty
        ? <DateTime>[draft.selectedDate]
        : draft.sessionDates;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
        top: AppDimens.paddingX12,
        bottom: AppDimens.paddingX16,
      ),
      decoration: const BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusX24),
          topRight: Radius.circular(AppDimens.radiusX24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: AppDimens.sizeX40,
                height: AppDimens.sizeX4,
                decoration: BoxDecoration(
                  color: LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX50),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: AppDimens.sizeX44,
                  height: AppDimens.sizeX44,
                  decoration: BoxDecoration(
                    color: LightColor.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: LightColor.secondaryColor,
                    size: AppDimens.sizeX22,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        StringConstants.reviewYourBooking,
                        style: textTheme.bodyTextLarge?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sizeX4),
                      Text(
                        StringConstants.pleaseConfirmTheDetailsBeforeBooking,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX18),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ReviewCourtCard(draft: draft, timeRange: timeRange),
                    if (draft.isRecurring) ...<Widget>[
                      const SizedBox(height: AppDimens.sizeX12),
                      _RecurringReviewCard(
                        recurrence: recurrence,
                        sessions: draft.sessions,
                        sessionDates: sessionDates,
                      ),
                    ],
                    const SizedBox(height: AppDimens.sizeX12),
                    _ReviewPaymentCard(
                      paymentMethodLabel: paymentMethodLabel,
                      paymentProofName: paymentProofName,
                      couponCode: couponCode,
                    ),
                    const SizedBox(height: AppDimens.sizeX12),
                    _PriceBreakdown(lines: pricing.lines, ready: pricing.ready),
                    const SizedBox(height: AppDimens.sizeX4),
                  ],
                ),
              ),
            ),
            Padding(
              padding: AppUtils().getPadding(
                top: AppDimens.paddingX14,
                bottom: AppDimens.paddingX12,
              ),
              child: Divider(
                height: 1,
                color: LightColor.dividerColor.withValues(alpha: 0.85),
              ),
            ),

            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool stackActions = constraints.maxWidth < 330;
                final Widget backButton = CustomButton(
                  text: StringConstants.goBack,
                  onPressed: () => Navigator.of(context).pop(false),
                  isOutlined: true,
                  foregroundColor: LightColor.primaryTextColor,
                  borderColor: LightColor.greyBorderColor,
                  minHeight: AppDimens.sizeX48,
                );
                final Widget confirmButton = CustomButton(
                  text: StringConstants.confirmBooking,
                  onPressed: () => Navigator.of(context).pop(true),
                  backgroundColor: LightColor.secondaryColor,
                  foregroundColor: LightColor.inverseTextColor,
                  minHeight: AppDimens.sizeX48,
                );

                if (stackActions) {
                  return Column(
                    children: <Widget>[
                      confirmButton,
                      const SizedBox(height: AppDimens.sizeX10),
                      backButton,
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(child: backButton),
                    const SizedBox(width: AppDimens.sizeX12),
                    Expanded(flex: 2, child: confirmButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCourtCard extends StatelessWidget {
  const _ReviewCourtCard({required this.draft, required this.timeRange});

  final BookingDraft draft;
  final String timeRange;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CustomImageView(
                url: draft.courtImage,
                imagePath: draft.courtImage.isEmpty
                    ? 'assets/images/image_placeholder_normal.png'
                    : null,
                width: AppDimens.sizeX56,
                height: AppDimens.sizeX56,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      draft.courtName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX4),
                    Text(
                      '${draft.matchType} · ${draft.courtType}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: AppUtils().getPadding(
              symmetricVertical: AppDimens.paddingX14,
            ),
            child: Divider(
              height: 1,
              color: LightColor.dividerColor.withValues(alpha: 0.8),
            ),
          ),
          _ReviewDetailRow(
            icon: Icons.calendar_today_rounded,
            label: draft.isRecurring ? 'Starts' : 'Date',
            value: _dateLabel(draft.selectedDate),
          ),
          const SizedBox(height: AppDimens.sizeX10),
          _ReviewDetailRow(
            icon: Icons.schedule_rounded,
            label: StringConstants.time,
            value: timeRange,
          ),
          const SizedBox(height: AppDimens.sizeX10),
          _ReviewDetailRow(
            icon: Icons.groups_rounded,
            label: StringConstants.players,
            value: 'Up to ${draft.maxPlayers}',
          ),
        ],
      ),
    );
  }
}

class _RecurringReviewCard extends StatelessWidget {
  const _RecurringReviewCard({
    required this.recurrence,
    required this.sessions,
    required this.sessionDates,
  });

  final String recurrence;
  final int sessions;
  final List<DateTime> sessionDates;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      borderColor: LightColor.secondaryColor.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ReviewDetailRow(
            icon: Icons.repeat_rounded,
            label: StringConstants.recurringBooking,
            value: 'Weekly · $recurrence · $sessions sessions',
            emphasize: true,
          ),
          if (sessionDates.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX12),
            Wrap(
              spacing: AppDimens.sizeX8,
              runSpacing: AppDimens.sizeX8,
              children: <Widget>[
                for (final DateTime date in sessionDates)
                  _SessionDateChip(label: _dateLabel(date)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewPaymentCard extends StatelessWidget {
  const _ReviewPaymentCard({
    required this.paymentMethodLabel,
    required this.paymentProofName,
    required this.couponCode,
  });

  final String paymentMethodLabel;
  final String? paymentProofName;
  final String? couponCode;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        children: <Widget>[
          _ReviewDetailRow(
            icon: Icons.payments_rounded,
            label: StringConstants.payment,
            value: paymentMethodLabel,
          ),
          if (paymentProofName != null) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            _ReviewDetailRow(
              icon: Icons.attach_file_rounded,
              label: StringConstants.proof,
              value: paymentProofName!,
            ),
          ],
          if (couponCode != null && couponCode!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            _ReviewDetailRow(
              icon: Icons.local_offer_rounded,
              label: StringConstants.couponCode,
              value: couponCode!.trim().toUpperCase(),
              valueColor: LightColor.secondaryColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewDetailRow extends StatelessWidget {
  const _ReviewDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: AppDimens.sizeX30,
          height: AppDimens.sizeX30,
          decoration: BoxDecoration(
            color: LightColor.inputFillColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          child: Icon(
            icon,
            size: AppDimens.sizeX16,
            color: LightColor.iconGrey,
          ),
        ),
        const SizedBox(width: AppDimens.sizeX10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.hintTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                value,
                style: textTheme.bodyTextSmall?.copyWith(
                  color:
                      valueColor ??
                      (emphasize
                          ? LightColor.secondaryColor
                          : LightColor.primaryTextColor),
                  fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionDateChip extends StatelessWidget {
  const _SessionDateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
          color: LightColor.secondaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// ─────────────────────────── Success sheet ───────────────────────────

class _BookingSuccessSheet extends StatelessWidget {
  const _BookingSuccessSheet({
    required this.draft,
    required this.advance,
    required this.balanceDue,
  });

  final BookingDraft draft;
  final double advance;
  final double balanceDue;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX24),
      decoration: const BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusX24),
          topRight: Radius.circular(AppDimens.radiusX24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: AppDimens.sizeX56,
              height: AppDimens.sizeX56,
              decoration: BoxDecoration(
                color: LightColor.secondarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX30,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            Text(
              StringConstants.bookingRequestSent,
              style: textTheme.headingSubTitle?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX8),
            Text(
              '${draft.courtName} · ${draft.selectedTime}\nWe will confirm once your advance of Rs ${advance.toStringAsFixed(0)} is verified. Balance Rs ${balanceDue.toStringAsFixed(0)} payable later.',
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX20),
            SizedBox(
              width: double.infinity,
              height: AppDimens.sizeX50,
              child: CustomButton(
                text: StringConstants.done,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _dateLabel(DateTime date) {
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
  return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}

/// The price figures shown across the page — taken verbatim from the server
/// quote (`price_details` + `calculation_list`). Nothing is computed on device.
class _Pricing {
  const _Pricing({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.advance,
    required this.balanceDue,
    required this.hasCoupon,
    required this.lines,
    required this.items,
    required this.ready,
  });

  final double subtotal;
  final double discount;
  final double total;
  final double advance;
  final double balanceDue;
  final bool hasCoupon;

  /// Server-provided display rows (`quote.calculation_list`).
  final List<BookingCalculationLineModel> lines;

  /// Server-provided per-session rows (`quote.items`).
  final List<BookingSessionItemModel> items;

  /// Whether the server quote (price details) has arrived yet.
  final bool ready;
}
