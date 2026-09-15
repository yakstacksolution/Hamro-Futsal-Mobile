import 'package:hamro_futsal/features/futsal_details/data/model/time_slot_model.dart';

/// A single pricing window of a court (e.g. Morning 6 AM – 12 PM → Rs 1000).
class CourtPriceRule {
  const CourtPriceRule({
    required this.label,
    required this.timeRange,
    required this.startHour,
    required this.endHour,
    required this.price,
  });

  final String label;
  final String timeRange;
  final int startHour;
  final int endHour;
  final double price;
}

/// What the server charges for a court at the requested slot, and what it
/// would have charged without the discount (`actual_price`).
///
/// The figures are the server's: discounts, weekend and holiday rates are all
/// already applied there, so the app shows these rather than recomputing a
/// price from the court's own rules.
class CourtActualPrice {
  const CourtActualPrice({
    required this.amount,
    required this.originalAmount,
    this.priceType = 'base',
    this.hasDiscount = false,
    this.discount,
  });

  /// What the customer pays.
  final double amount;

  /// What it would cost without the discount. Equal to [amount] when there is
  /// none.
  final double originalAmount;

  /// `base`, `weekend`, `holiday`, `custom` — which of the court's rates the
  /// server used.
  final String priceType;

  final bool hasDiscount;
  final CourtDiscount? discount;

  /// How much is taken off; zero when nothing is.
  double get savings {
    final double diff = originalAmount - amount;
    return diff > 0 ? diff : 0;
  }

  /// A discount worth showing: switched on, and actually cheaper.
  bool get showsDiscount => hasDiscount && savings > 0;

  factory CourtActualPrice.fromJson(Map<String, dynamic> json) {
    final double amount = _priceDouble(json['amount'] ?? json['price']) ?? 0;
    final double original =
        _priceDouble(json['original_amount'] ?? json['originalAmount']) ??
        amount;
    final dynamic rawDiscount = json['discount'];
    return CourtActualPrice(
      amount: amount,
      originalAmount: original,
      priceType: (json['price_type'] ?? json['priceType'] ?? 'base')
          .toString()
          .trim(),
      hasDiscount:
          json['has_discount'] == true ||
          json['hasDiscount'] == true ||
          (rawDiscount != null && original > amount),
      discount: rawDiscount is Map
          ? CourtDiscount.fromJson(Map<String, dynamic>.from(rawDiscount))
          : null,
    );
  }
}

/// The discount behind a [CourtActualPrice].
class CourtDiscount {
  const CourtDiscount({
    required this.type,
    required this.value,
    required this.amount,
    this.label = '',
  });

  /// `flat` or `percentage`.
  final String type;

  /// The rule's own number: rupees for a flat discount, percent otherwise.
  final double value;

  /// Rupees actually taken off.
  final double amount;

  /// The server's own wording, e.g. `Rs. 100 off`.
  final String label;

  bool get isPercent {
    final String normalized = type.trim().toLowerCase();
    return normalized == 'percent' || normalized == 'percentage';
  }

  factory CourtDiscount.fromJson(Map<String, dynamic> json) {
    return CourtDiscount(
      type: (json['type'] ?? 'flat').toString().trim(),
      value: _priceDouble(json['value']) ?? 0,
      amount: _priceDouble(json['amount'] ?? json['value']) ?? 0,
      label: (json['label'] ?? '').toString().trim(),
    );
  }
}

double? _priceDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', ''));
}

/// The slot a court was matched against (`matching_slot`).
class CourtMatchingSlot {
  const CourtMatchingSlot({
    this.id,
    this.label = '',
    this.startTime,
    this.endTime,
  });

  final int? id;
  final String label;
  final String? startTime;
  final String? endTime;
}

/// A court shown in the courts list of the slot selection page.
class VenueCourtItemModel {
  const VenueCourtItemModel({
    this.id,
    this.venueId,
    required this.name,
    required this.image,
    required this.maxPlayers,
    required this.matchType,
    required this.courtType,
    required this.priceList,
    this.weekendSurcharge = 0,
    this.status = SlotStatus.available,
    this.startTime,
    this.endTime,
    this.slug,
    this.basePrice,
    this.actualPrice,
    this.matchingSlot,
    this.slotDurationMinutes,
    this.availabilityReason,
  });

  final int? id;
  final int? venueId;
  final String name;
  final String image;
  final int maxPlayers;
  final String matchType;
  final String courtType;
  final List<CourtPriceRule> priceList;

  /// Availability of the court for the selected slot, from the server's
  /// `availability_status` field.
  final SlotStatus status;
  final String? startTime;
  final String? endTime;

  /// Extra amount added on Saturdays (weekend in Nepal). Only used when the
  /// server did not price the slot itself.
  final double weekendSurcharge;

  final String? slug;

  /// The court's list price before any slot rate or discount.
  final double? basePrice;

  /// What the server charges for the requested slot. Authoritative when
  /// present — it already carries weekend, holiday and discount handling.
  final CourtActualPrice? actualPrice;

  /// The slot this court was matched against.
  final CourtMatchingSlot? matchingSlot;

  final int? slotDurationMinutes;

  /// Why the court is (un)available, e.g. `available`, `booked`.
  final String? availabilityReason;

  bool get isAvailable => status.canSelect;

  /// True when the server priced this slot below its original amount.
  bool get hasDiscount => actualPrice?.showsDiscount ?? false;

  /// What the slot costs before the discount, or null when there is none.
  double? get originalPriceForSlot =>
      hasDiscount ? actualPrice!.originalAmount : null;

  /// How much a single session saves.
  double get savingsPerSession => actualPrice?.savings ?? 0;

  VenueCourtItemModel copyWith({
    int? id,
    int? venueId,
    String? name,
    String? image,
    int? maxPlayers,
    String? matchType,
    String? courtType,
    List<CourtPriceRule>? priceList,
    double? weekendSurcharge,
    SlotStatus? status,
    String? startTime,
    String? endTime,
    String? slug,
    double? basePrice,
    CourtActualPrice? actualPrice,
    CourtMatchingSlot? matchingSlot,
    int? slotDurationMinutes,
    String? availabilityReason,
  }) {
    return VenueCourtItemModel(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      image: image ?? this.image,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      matchType: matchType ?? this.matchType,
      courtType: courtType ?? this.courtType,
      priceList: priceList ?? this.priceList,
      weekendSurcharge: weekendSurcharge ?? this.weekendSurcharge,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slug: slug ?? this.slug,
      basePrice: basePrice ?? this.basePrice,
      actualPrice: actualPrice ?? this.actualPrice,
      matchingSlot: matchingSlot ?? this.matchingSlot,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      availabilityReason: availabilityReason ?? this.availabilityReason,
    );
  }

  /// The rule whose window contains [slotTime] (e.g. '7:00 AM'),
  /// or null when nothing matches.
  CourtPriceRule? ruleForTime(String? slotTime) {
    if (slotTime == null || priceList.isEmpty) return null;
    final int hour = _slotHour(slotTime);
    for (final CourtPriceRule rule in priceList) {
      if (hour >= rule.startHour && hour < rule.endHour) return rule;
    }
    return null;
  }

  /// Price for the given date + slot.
  ///
  /// The server's `actual_price` wins whenever it is present: it already
  /// applies the slot's weekend, holiday and discount rules, so adding the
  /// local surcharge on top would double-charge. The rule list is the fallback
  /// for responses that carry no priced slot.
  double priceFor(DateTime date, String? slotTime) {
    final CourtActualPrice? priced = actualPrice;
    if (priced != null) return priced.amount;

    final CourtPriceRule? rule = ruleForTime(slotTime);
    final double base = rule?.price ?? minPrice;
    final bool isWeekend = date.weekday == DateTime.saturday;
    return isWeekend ? base + weekendSurcharge : base;
  }

  /// What [priceFor] would have been without the discount.
  double originalPriceFor(DateTime date, String? slotTime) {
    final CourtActualPrice? priced = actualPrice;
    if (priced != null) return priced.originalAmount;
    return priceFor(date, slotTime);
  }

  double get minPrice {
    final CourtActualPrice? priced = actualPrice;
    if (priced != null) return priced.amount;
    if (priceList.isEmpty) return basePrice ?? 0;
    return priceList
        .map((CourtPriceRule rule) => rule.price)
        .reduce((double a, double b) => a < b ? a : b);
  }

  static int _slotHour(String time) {
    final List<String> parts = time.trim().split(' ');
    int hour = int.tryParse(parts.first.split(':').first) ?? 0;
    final bool isPm = parts.length > 1 && parts[1].toUpperCase() == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return hour;
  }
}
