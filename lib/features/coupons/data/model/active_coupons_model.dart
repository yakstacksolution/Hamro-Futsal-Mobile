import 'package:hamro_footsall/features/coupons/data/model/coupon_model.dart';

/// The result of `GET /coupons/active`.
///
/// The server may signal availability with just a flag
/// (`{ has_active_coupon: true }`) and no list, so [hasActiveCoupon] is tracked
/// independently of [coupons] — the coupon section is shown whenever the flag is
/// true, even when there are no specific coupons to list.
class ActiveCouponsModel {
  const ActiveCouponsModel({
    this.hasActiveCoupon = false,
    this.coupons = const <CouponModel>[],
  });

  final bool hasActiveCoupon;
  final List<CouponModel> coupons;

  factory ActiveCouponsModel.fromResponse(dynamic payload) {
    final List<CouponModel> coupons = CouponModel.listFromResponse(payload);
    final bool? flag = _readFlag(payload);
    return ActiveCouponsModel(
      // Trust the explicit flag; otherwise infer from the parsed list.
      hasActiveCoupon: flag ?? coupons.isNotEmpty,
      coupons: coupons,
    );
  }
}

bool? _readFlag(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 5 && current is Map; depth++) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    if (map.containsKey('has_active_coupon') ||
        map.containsKey('hasActiveCoupon')) {
      return _asBool(map['has_active_coupon'] ?? map['hasActiveCoupon']);
    }
    final dynamic nested = map['data'];
    if (nested == null) break;
    current = nested;
  }
  return null;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return null;
  if (const <String>{'true', '1', 'yes'}.contains(text)) return true;
  if (const <String>{'false', '0', 'no'}.contains(text)) return false;
  return null;
}
