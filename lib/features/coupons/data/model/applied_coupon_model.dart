import 'package:hamro_footsall/features/futsal_details/data/model/booking_quote_model.dart';

/// The result of `POST /bookings/apply-coupon` — the server's authoritative
/// pricing for a coupon against a given booking.
class AppliedCouponModel {
  const AppliedCouponModel({
    required this.code,
    this.couponId,
    this.couponTitle,
    this.couponType,
    this.message,
    required this.discount,
    required this.originalAmount,
    required this.finalAmount,
    this.advancePayableNow,
    this.balanceDueLater,
    this.taxAmount,
    this.quote,
  });

  final String code;
  final int? couponId;

  /// Coupon display title, e.g. "First book".
  final String? couponTitle;

  /// Coupon type, e.g. "percentage".
  final String? couponType;

  /// Optional success message from the server, e.g. "Coupon applied".
  final String? message;

  /// Discount amount in rupees (`price_details.discount_amount`).
  final double discount;

  /// Order amount before the discount (`price_details.subtotal`).
  final double originalAmount;

  /// Order amount after the discount (`price_details.booking_total`).
  final double finalAmount;

  /// Server-computed advance payable now (`price_details.advance_payable_now`).
  final double? advancePayableNow;

  /// Server-computed balance due later (`price_details.balance_due_later`).
  final double? balanceDueLater;

  /// Tax amount (`price_details.tax_amount`).
  final double? taxAmount;

  /// The full server quote (same shape as the booking-hold quote), so the UI
  /// can render the breakdown/items from a single source after applying.
  final BookingQuoteModel? quote;

  /// Whether the server returned its own advance/balance split. When true the
  /// UI should trust these figures instead of computing the advance locally.
  bool get hasServerPricing => advancePayableNow != null;

  /// Builds the model from the API response. [fallbackCode] and
  /// [fallbackOriginal] (the amount we sent) fill in fields the server may omit;
  /// any missing amount is derived from the others so the totals always agree.
  factory AppliedCouponModel.fromResponse(
    dynamic payload, {
    required String fallbackCode,
    required double fallbackOriginal,
  }) {
    final Map<String, dynamic> data = _unwrap(payload);
    // Prices live under `price_details`; fall back to the data node itself for
    // older flat responses. The coupon meta is a sibling object.
    final Map<String, dynamic> price = _mapOf(data['price_details']) ?? data;
    final Map<String, dynamic> coupon = _mapOf(data['coupon']) ?? data;

    final String code =
        _asString(
          coupon['code'] ??
              data['coupon_code'] ??
              data['couponCode'] ??
              data['code'],
        ) ??
        fallbackCode;

    double? original = _asDouble(
      price['subtotal'] ??
          price['original_amount'] ??
          price['amount'] ??
          price['total'],
    );
    // NOTE: read the amount from `price_details`, never `coupon.discount`
    // (that is the percentage, e.g. 10, not the rupee discount).
    double? discount = _asDouble(
      price['discount_amount'] ??
          price['discountAmount'] ??
          price['discount'] ??
          price['savings'],
    );
    double? finalAmount = _asDouble(
      price['booking_total'] ??
          price['bookingTotal'] ??
          price['final_amount'] ??
          price['finalAmount'] ??
          price['payable_amount'] ??
          price['grand_total'],
    );

    original ??= (discount != null && finalAmount != null)
        ? discount + finalAmount
        : fallbackOriginal;
    discount ??= (finalAmount != null) ? (original - finalAmount) : 0;
    finalAmount ??= original - discount;

    // Keep the three numbers internally consistent and within bounds.
    if (discount < 0) discount = 0;
    if (discount > original) discount = original;
    finalAmount = (original - discount).clamp(0, original);

    return AppliedCouponModel(
      code: code,
      couponId: _asInt(coupon['id'] ?? data['coupon_id'] ?? data['couponId']),
      couponTitle: _asString(coupon['title'] ?? coupon['name']),
      couponType: _asString(coupon['type']),
      message: _asString(data['message'] ?? data['msg']),
      discount: discount,
      originalAmount: original,
      finalAmount: finalAmount,
      advancePayableNow: _asDouble(
        price['advance_payable_now'] ?? price['advancePayableNow'],
      ),
      balanceDueLater: _asDouble(
        price['balance_due_later'] ?? price['balanceDueLater'],
      ),
      taxAmount: _asDouble(price['tax_amount'] ?? price['taxAmount']),
      // `data` carries the same {booking_summary, coupon, price_details,
      // calculation_list, items} shape as the booking-hold quote.
      quote: BookingQuoteModel.fromJson(data),
    );
  }
}

/// Drills through the response envelope until it reaches the node that holds
/// the pricing (`price_details`/`coupon`) or, for older responses, the flat
/// amount fields.
Map<String, dynamic> _unwrap(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 5 && current is Map; depth++) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final bool stop =
        map.containsKey('price_details') ||
        map.containsKey('coupon') ||
        map.containsKey('booking_summary') ||
        map.keys.any(
          (String k) => const <String>{
            'discount',
            'discount_amount',
            'final_amount',
            'finalAmount',
            'payable_amount',
            'original_amount',
            'subtotal',
          }.contains(k),
        );
    final dynamic nested = map['data'] ?? map['result'];
    if (stop || nested is! Map) return map;
    current = nested;
  }
  return current is Map ? Map<String, dynamic>.from(current) : <String, dynamic>{};
}

Map<String, dynamic>? _mapOf(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

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
  final double? direct = double.tryParse(text);
  if (direct != null && direct.isFinite) return direct;
  final RegExpMatch? match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
  final double? parsed = match == null
      ? null
      : double.tryParse(match.group(1) ?? '');
  return (parsed != null && parsed.isFinite) ? parsed : null;
}
