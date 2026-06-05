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
    required this.name,
    required this.image,
    required this.maxPlayers,
    required this.matchType,
    required this.courtType,
    required this.priceList,
    this.weekendSurcharge = 0,
  });

  final String name;
  final String image;
  final int maxPlayers;
  final String matchType;
  final String courtType;
  final List<CourtPriceRule> priceList;

  /// Extra amount added on Saturdays (weekend in Nepal).
  final double weekendSurcharge;

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
