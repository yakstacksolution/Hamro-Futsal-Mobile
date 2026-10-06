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

  bool get hasPricing =>
      priceDetails != null || calculationList.isNotEmpty || items.isNotEmpty;

  static bool _hasPriceFields(Map<String, dynamic> json) => <String>[
    'booking_total',
    'total_amount',
    'subtotal',
    'advance_payable_now',
    'payable_now',
    'advance_amount',
    'balance_due_later',
  ].any(json.containsKey);

  double? get itemsAdvance {
    final Iterable<double> parts = items
        .map((BookingSessionItemModel i) => i.advanceAmount)
        .whereType<double>();
    return parts.isEmpty ? null : parts.fold<double>(0, (a, b) => a + b);
  }

  static BookingQuoteModel? combine(List<BookingQuoteModel> quotes) {
    if (quotes.isEmpty) return null;
    if (quotes.length == 1) return quotes.single;
    double? sum(double? Function(BookingPriceDetailsModel p) of) {
      double? total;
      for (final BookingQuoteModel q in quotes) {
        final double? v = q.priceDetails == null ? null : of(q.priceDetails!);
        if (v != null) total = (total ?? 0) + v;
      }
      return total;
    }

    final bool anyDetails = quotes.any(
      (BookingQuoteModel q) => q.priceDetails != null,
    );
    final List<BookingCalculationLineModel> lines =
        <BookingCalculationLineModel>[];
    for (final BookingQuoteModel q in quotes) {
      for (final BookingCalculationLineModel line in q.calculationList) {
        final int at = lines.indexWhere(
          (BookingCalculationLineModel l) => l.key != null && l.key == line.key,
        );
        if (at < 0) {
          lines.add(line);
        } else if (line.amount != null) {
          final BookingCalculationLineModel prev = lines[at];
          lines[at] = BookingCalculationLineModel(
            label: prev.label,
            key: prev.key,
            amount: (prev.amount ?? 0) + line.amount!,
          );
        }
      }
    }
    return BookingQuoteModel(
      bookingSummary: quotes.first.bookingSummary,
      coupon: quotes.first.coupon,
      priceDetails: anyDetails
          ? BookingPriceDetailsModel(
              subtotal: sum((p) => p.subtotal),
              discountAmount: sum((p) => p.discountAmount),
              bookingTotal: sum((p) => p.bookingTotal),
              advancePayableNow: sum((p) => p.advancePayableNow),
              balanceDueLater: sum((p) => p.balanceDueLater),
              taxAmount: sum((p) => p.taxAmount),
            )
          : null,
      calculationList: lines,
      items: <BookingSessionItemModel>[
        for (final BookingQuoteModel q in quotes) ...q.items,
      ],
    );
  }

  factory BookingQuoteModel.fromJson(Map<String, dynamic> json) {
    return BookingQuoteModel(
      bookingSummary: _mapOf(json['booking_summary']) == null
          ? null
          : BookingSummaryQuoteModel.fromJson(_mapOf(json['booking_summary'])!),
      coupon: _mapOf(json['coupon']) == null
          ? null
          : QuoteCouponModel.fromJson(_mapOf(json['coupon'])!),
      // Under `price_details`, or flat on the quote itself (the booking-level
      // quote beside a list of holds puts its figures there).
      priceDetails: _mapOf(json['price_details']) != null
          ? BookingPriceDetailsModel.fromJson(_mapOf(json['price_details'])!)
          : _hasPriceFields(json)
          ? BookingPriceDetailsModel.fromJson(json)
          : null,
      calculationList: _listOf(
        json['calculation_list'],
      ).map(BookingCalculationLineModel.fromJson).toList(growable: false),
      items: _listOf(
        json['items'],
      ).map(BookingSessionItemModel.fromJson).toList(growable: false),
    );
  }
}

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
    final double? total = _asDouble(
      json['booking_total'] ?? json['total_amount'] ?? json['total'],
    );
    final double? balance = _asDouble(
      json['balance_due_later'] ?? json['balance_due'] ?? json['due_later'],
    );
    final double? advance =
        _asDouble(
          json['advance_payable_now'] ??
              json['payable_now'] ??
              json['advance_amount'] ??
              json['advance'],
        ) ??
        // Total and balance given, but not what is paid now: the rest.
        (total != null && balance != null ? total - balance : null);
    return BookingPriceDetailsModel(
      subtotal: _asDouble(json['subtotal']),
      discountAmount: _asDouble(json['discount_amount']),
      bookingTotal: total,
      advancePayableNow: advance,
      balanceDueLater: balance,
      taxAmount: _asDouble(json['tax_amount']),
    );
  }
}

class BookingCalculationLineModel {
  const BookingCalculationLineModel({this.label, this.key, this.amount});

  final String? label;
  final String? key;
  final double? amount;

  factory BookingCalculationLineModel.fromJson(Map<String, dynamic> json) {
    return BookingCalculationLineModel(
      label: _asString(json['label']),
      key: _canonicalKey(_asString(json['key'])),
      amount: _asDouble(json['amount']),
    );
  }

  static String? _canonicalKey(String? key) => switch (key) {
    'payable_now' || 'advance_amount' || 'advance' => 'advance_payable_now',
    'total_amount' || 'total' => 'booking_total',
    'balance_due' || 'due_later' => 'balance_due_later',
    _ => key,
  };
}

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
