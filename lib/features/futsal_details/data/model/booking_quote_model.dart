/// The `quote` object returned alongside a booking hold — the server's
/// authoritative pricing for the held slot(s).
class BookingQuoteModel {
  const BookingQuoteModel({
    this.bookingSummary,
    this.coupon,
    this.priceDetails,
    this.calculationList = const <BookingCalculationLineModel>[],
    this.items = const <BookingSessionItemModel>[],
  });

  final BookingSummaryQuoteModel? bookingSummary;
  final QuoteCouponModel? coupon;
  final BookingPriceDetailsModel? priceDetails;
  final List<BookingCalculationLineModel> calculationList;
  final List<BookingSessionItemModel> items;

  bool get hasCoupon => coupon != null;

  factory BookingQuoteModel.fromJson(Map<String, dynamic> json) {
    return BookingQuoteModel(
      bookingSummary: _mapOf(json['booking_summary']) == null
          ? null
          : BookingSummaryQuoteModel.fromJson(_mapOf(json['booking_summary'])!),
      coupon: _mapOf(json['coupon']) == null
          ? null
          : QuoteCouponModel.fromJson(_mapOf(json['coupon'])!),
      priceDetails: _mapOf(json['price_details']) == null
          ? null
          : BookingPriceDetailsModel.fromJson(_mapOf(json['price_details'])!),
      calculationList: _listOf(
        json['calculation_list'],
      ).map(BookingCalculationLineModel.fromJson).toList(growable: false),
      items: _listOf(
        json['items'],
      ).map(BookingSessionItemModel.fromJson).toList(growable: false),
    );
  }
}

/// `quote.price_details` — the totals shown in the price breakdown.
class BookingPriceDetailsModel {
  const BookingPriceDetailsModel({
    this.subtotal,
    this.discountAmount,
    this.bookingTotal,
    this.advancePayableNow,
    this.balanceDueLater,
    this.taxAmount,
  });

  final double? subtotal;
  final double? discountAmount;
  final double? bookingTotal;
  final double? advancePayableNow;
  final double? balanceDueLater;
  final double? taxAmount;

  factory BookingPriceDetailsModel.fromJson(Map<String, dynamic> json) {
    return BookingPriceDetailsModel(
      subtotal: _asDouble(json['subtotal']),
      discountAmount: _asDouble(json['discount_amount']),
      bookingTotal: _asDouble(json['booking_total']),
      advancePayableNow: _asDouble(json['advance_payable_now']),
      balanceDueLater: _asDouble(json['balance_due_later']),
      taxAmount: _asDouble(json['tax_amount']),
    );
  }
}

/// One line from `quote.calculation_list`.
class BookingCalculationLineModel {
  const BookingCalculationLineModel({this.label, this.key, this.amount});

  final String? label;
  final String? key;
  final double? amount;

  factory BookingCalculationLineModel.fromJson(Map<String, dynamic> json) {
    return BookingCalculationLineModel(
      label: _asString(json['label']),
      key: _asString(json['key']),
      amount: _asDouble(json['amount']),
    );
  }
}

/// One per-session row from `quote.items`.
class BookingSessionItemModel {
  const BookingSessionItemModel({
    this.bookingDate,
    this.slotCount,
    this.subtotal,
    this.discountAmount,
    this.advanceAmount,
    this.totalAmount,
  });

  final String? bookingDate;
  final int? slotCount;
  final double? subtotal;
  final double? discountAmount;
  final double? advanceAmount;
  final double? totalAmount;

  factory BookingSessionItemModel.fromJson(Map<String, dynamic> json) {
    return BookingSessionItemModel(
      bookingDate: _asString(json['booking_date']),
      slotCount: _asInt(json['slot_count']),
      subtotal: _asDouble(json['subtotal']),
      discountAmount: _asDouble(json['discount_amount']),
      advanceAmount: _asDouble(json['advance_amount']),
      totalAmount: _asDouble(json['total_amount']),
    );
  }
}

/// `quote.booking_summary`.
class BookingSummaryQuoteModel {
  const BookingSummaryQuoteModel({
    this.venueId,
    this.courtId,
    this.venueName,
    this.courtName,
    this.courtImage,
    this.surfaceType,
    this.capacity,
    this.sessionCount,
    this.bookingDates = const <String>[],
    this.startTime,
    this.endTime,
    this.paymentQrId,
    this.paymentQrUrl,
  });

  final int? venueId;
  final int? courtId;
  final String? venueName;
  final String? courtName;
  final String? courtImage;
  final String? surfaceType;
  final int? capacity;
  final int? sessionCount;
  final List<String> bookingDates;
  final String? startTime;
  final String? endTime;
  final int? paymentQrId;
  final String? paymentQrUrl;

  factory BookingSummaryQuoteModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> qr = _mapOf(json['payment_qr']) ?? const {};
    return BookingSummaryQuoteModel(
      venueId: _asInt(json['venue_id']),
      courtId: _asInt(json['court_id']),
      venueName: _asString(json['venue_name']),
      courtName: _asString(json['court_name']),
      courtImage: _asString(json['court_image']),
      surfaceType: _asString(json['surface_type']),
      capacity: _asInt(json['capacity']),
      sessionCount: _asInt(json['session_count']),
      bookingDates: _asStringList(json['booking_dates']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      paymentQrId: _asInt(qr['id']),
      paymentQrUrl: _asString(qr['url']),
    );
  }
}

/// `quote.coupon` (null when no coupon is applied to the quote).
class QuoteCouponModel {
  const QuoteCouponModel({
    this.id,
    this.title,
    this.code,
    this.type,
    this.discount,
  });

  final int? id;
  final String? title;
  final String? code;
  final String? type;
  final double? discount;

  factory QuoteCouponModel.fromJson(Map<String, dynamic> json) {
    return QuoteCouponModel(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      code: _asString(json['code']),
      type: _asString(json['type']),
      discount: _asDouble(json['discount']),
    );
  }
}

Map<String, dynamic>? _mapOf(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

List<Map<String, dynamic>> _listOf(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map e) => Map<String, dynamic>.from(e))
      .toList(growable: false);
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((dynamic e) => e?.toString().trim() ?? '')
      .where((String e) => e.isNotEmpty)
      .toList(growable: false);
}

String? _asString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble().isFinite ? value.toDouble() : null;
  final String text = value.toString().replaceAll(',', '');
  final double? parsed = double.tryParse(text);
  return (parsed != null && parsed.isFinite) ? parsed : null;
}
