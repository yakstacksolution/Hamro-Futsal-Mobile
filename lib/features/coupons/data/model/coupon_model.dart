/// How a coupon's value is applied to the order total.
enum CouponDiscountType {
  percentage,
  fixed;

  static CouponDiscountType fromApi(dynamic value) {
    final String s = value?.toString().trim().toLowerCase() ?? '';
    if (s.startsWith('percent') || s == '%' || s == 'rate') {
      return CouponDiscountType.percentage;
    }
    return CouponDiscountType.fixed;
  }
}

/// A coupon returned by `GET /coupons/active`.
class CouponModel {
  const CouponModel({
    this.id,
    required this.code,
    this.title,
    this.description,
    this.discountType = CouponDiscountType.fixed,
    this.discountValue = 0,
    this.maxDiscount,
    this.minOrderAmount,
    this.expiresAt,
  });

  final int? id;
  final String code;
  final String? title;
  final String? description;
  final CouponDiscountType discountType;
  final double discountValue;

  /// Cap on the discount for percentage coupons (null = uncapped).
  final double? maxDiscount;

  /// Minimum order amount required for the coupon to be valid.
  final double? minOrderAmount;
  final DateTime? expiresAt;

  bool get isPercentage => discountType == CouponDiscountType.percentage;

  /// Short human label, e.g. `10% off` or `Rs 100 off`.
  String get label {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    if (isPercentage) return '${_trimNumber(discountValue)}% off';
    return 'Rs ${_trimNumber(discountValue)} off';
  }

  /// Whether [subtotal] satisfies the coupon's [minOrderAmount].
  bool meetsMinimum(double subtotal) =>
      minOrderAmount == null || subtotal >= minOrderAmount!;

  /// Client-side discount estimate, used to preview savings before the server
  /// confirms via `apply-coupon`. Honours [maxDiscount] and never exceeds the
  /// subtotal.
  double estimatedDiscount(double subtotal) {
    if (!meetsMinimum(subtotal)) return 0;
    double discount = isPercentage
        ? subtotal * (discountValue / 100)
        : discountValue;
    if (maxDiscount != null && discount > maxDiscount!) discount = maxDiscount!;
    if (discount < 0) return 0;
    return discount > subtotal ? subtotal : discount;
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: _asInt(json['id'] ?? json['coupon_id'] ?? json['couponId']),
      code:
          _asString(
            json['code'] ?? json['coupon_code'] ?? json['couponCode'],
          ) ??
          '',
      title: _asString(json['title'] ?? json['name'] ?? json['label']),
      description: _asString(json['description'] ?? json['details']),
      discountType: CouponDiscountType.fromApi(
        json['discount_type'] ??
            json['discountType'] ??
            json['type'] ??
            json['coupon_type'],
      ),
      discountValue:
          _asDouble(
            json['discount_value'] ??
                json['discountValue'] ??
                json['value'] ??
                json['discount'] ??
                json['amount'],
          ) ??
          0,
      maxDiscount: _asDouble(
        json['max_discount'] ??
            json['maxDiscount'] ??
            json['max_discount_amount'] ??
            json['maximum_discount'],
      ),
      minOrderAmount: _asDouble(
        json['min_order_amount'] ??
            json['minOrderAmount'] ??
            json['min_amount'] ??
            json['minimum_order'] ??
            json['minimum_amount'],
      ),
      expiresAt: _asDate(
        json['expires_at'] ??
            json['expiresAt'] ??
            json['expiry_date'] ??
            json['valid_till'] ??
            json['end_date'],
      ),
    );
  }

  /// Parses the `GET /coupons/active` payload, tolerating both a bare list and
  /// a `{ data: [...] }` / `{ data: { coupons: [...] } }` envelope.
  static List<CouponModel> listFromResponse(dynamic payload) {
    final List<dynamic> items = _listFromAny(payload);
    return items
        .whereType<Map>()
        .map((Map item) => CouponModel.fromJson(Map<String, dynamic>.from(item)))
        .where((CouponModel coupon) => coupon.code.isNotEmpty)
        .toList(growable: false);
  }
}

List<dynamic> _listFromAny(dynamic value) {
  dynamic current = value;
  // Unwrap nested envelopes like { data: { coupons: [...] } }.
  for (int depth = 0; depth < 5 && current is Map; depth++) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final dynamic next =
        map['data'] ??
        map['coupons'] ??
        map['items'] ??
        map['list'] ??
        map['results'] ??
        map['records'];
    if (next == null) break;
    current = next;
  }
  if (current is List) return current;
  return const <dynamic>[];
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
  final double? direct = double.tryParse(text);
  if (direct != null && direct.isFinite) return direct;
  final RegExpMatch? match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
  final double? parsed = match == null
      ? null
      : double.tryParse(match.group(1) ?? '');
  return (parsed != null && parsed.isFinite) ? parsed : null;
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

String _trimNumber(double value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
}
