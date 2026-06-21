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

enum CourtAvailabilityStatus {
  available,
  unavailable,
  booked;

  String get apiValue {
    return switch (this) {
      CourtAvailabilityStatus.available => 'available',
      CourtAvailabilityStatus.unavailable => 'unavailable',
      CourtAvailabilityStatus.booked => 'booked',
    };
  }

  String get label {
    return switch (this) {
      CourtAvailabilityStatus.available => 'Available',
      CourtAvailabilityStatus.unavailable => 'Unavailable',
      CourtAvailabilityStatus.booked => 'Booked',
    };
  }

  bool get canSelect => this == CourtAvailabilityStatus.available;
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
    this.status = CourtAvailabilityStatus.available,
    this.availabilityReason,
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
  final CourtAvailabilityStatus status;
  final String? availabilityReason;
  final String? startTime;
  final String? endTime;

  /// Extra amount added on Saturdays (weekend in Nepal).
  final double weekendSurcharge;

  bool get isAvailable => status.canSelect;

  /// Friendly text for why this court can't be booked, derived from the
  /// server's [availabilityReason]. Falls back to the status label, and is
  /// null when the court is available.
  String? get unavailableReasonLabel {
    if (isAvailable) return null;
    final String? reason = availabilityReason?.trim();
    if (reason == null || reason.isEmpty) return status.label;
    switch (reason.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_')) {
      case 'booked_or_closed':
        return 'Booked / Closed';
      case 'booked':
      case 'reserved':
        return 'Booked';
      case 'closed':
        return 'Closed';
      case 'fully_booked':
        return 'Fully booked';
      case 'blocked':
        return 'Blocked';
      case 'unavailable':
        return 'Unavailable';
      default:
        final String spaced = reason.replaceAll(RegExp(r'[_-]+'), ' ').trim();
        if (spaced.isEmpty) return status.label;
        return spaced[0].toUpperCase() + spaced.substring(1);
    }
  }

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
    CourtAvailabilityStatus? status,
    String? availabilityReason,
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
      availabilityReason: availabilityReason ?? this.availabilityReason,
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
