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

  /// Extra amount added on Saturdays (weekend in Nepal).
  final double weekendSurcharge;

  bool get isAvailable => status.canSelect;

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

  /// Price for the given date + slot, applying the weekend surcharge.
  /// Falls back to the cheapest rule when no slot is selected.
  double priceFor(DateTime date, String? slotTime) {
    final CourtPriceRule? rule = ruleForTime(slotTime);
    final double base = rule?.price ?? minPrice;
    final bool isWeekend = date.weekday == DateTime.saturday;
    return isWeekend ? base + weekendSurcharge : base;
  }

  double get minPrice {
    if (priceList.isEmpty) return 0;
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
