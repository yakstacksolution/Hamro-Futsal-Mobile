enum BookingStatus { completed, confirmed, pending, cancelled }

extension BookingStatusLabel on BookingStatus {
  String get label => switch (this) {
    BookingStatus.completed => 'Completed',
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.pending => 'Pending',
    BookingStatus.cancelled => 'Cancelled',
  };

  static BookingStatus fromKey(String? key) {
    switch ((key ?? '').toLowerCase()) {
      case 'completed':
        return BookingStatus.completed;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

// ── Parsing helpers ──────────────────────────────────────────────────────

int _int(dynamic v) =>
    v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0);

double _double(dynamic v) => v is num
    ? v.toDouble()
    : double.tryParse('${v ?? ''}') ?? 0;

String _str(dynamic v) => v?.toString().trim() ?? '';

List<Map<String, dynamic>> _mapList(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const <Map<String, dynamic>>[];

/// Full payload of `GET /booking-overview`. The server pre-computes every
/// aggregate; the UI just renders it.
class BookingOverviewResponse {
  const BookingOverviewResponse({
    required this.period,
    required this.summary,
    required this.trend,
    required this.statusMix,
    required this.netEarnings,
    required this.availableVenues,
    required this.venueChips,
    required this.venuePerformance,
    required this.topCourts,
    required this.topCustomers,
  });

  final OverviewPeriod period;
  final OverviewSummary summary;
  final RevenueTrend trend;
  final List<StatusMixEntry> statusMix;
  final NetEarnings netEarnings;
  final List<OverviewVenue> availableVenues;
  final List<OverviewVenue> venueChips;
  final List<VenuePerformanceRow> venuePerformance;
  final List<CourtPerformanceRow> topCourts;
  final List<CustomerPerformanceRow> topCustomers;

  factory BookingOverviewResponse.fromResponse(dynamic payload) {
    final root = _root(payload);
    final filters = root['filters'] is Map
        ? Map<String, dynamic>.from(root['filters'])
        : const <String, dynamic>{};
    final analytics = root['analytics'] is Map
        ? Map<String, dynamic>.from(root['analytics'])
        : const <String, dynamic>{};
    final overview = root['overview'] is Map
        ? Map<String, dynamic>.from(root['overview'])
        : const <String, dynamic>{};
    final rankings = root['rankings'] is Map
        ? Map<String, dynamic>.from(root['rankings'])
        : const <String, dynamic>{};

    return BookingOverviewResponse(
      period: OverviewPeriod.fromJson(
        root['period'] is Map
            ? Map<String, dynamic>.from(root['period'])
            : const {},
      ),
      summary: OverviewSummary.fromJson(
        root['summary'] is Map
            ? Map<String, dynamic>.from(root['summary'])
            : const {},
      ),
      trend: RevenueTrend.fromJson(
        analytics['revenue_trend'] is Map
            ? Map<String, dynamic>.from(analytics['revenue_trend'])
            : const {},
      ),
      statusMix: _mapList(
        (analytics['booking_statuses'] is Map
            ? Map<String, dynamic>.from(analytics['booking_statuses'])
            : const {})['status_mix'],
      ).map(StatusMixEntry.fromJson).toList(),
      netEarnings: NetEarnings.fromJson(
        overview['net_earnings'] is Map
            ? Map<String, dynamic>.from(overview['net_earnings'])
            : const {},
      ),
      availableVenues: _mapList(
        filters['available_venues'],
      ).map(OverviewVenue.fromJson).toList(),
      venueChips: _mapList(
        filters['venue_chips'],
      ).map(OverviewVenue.fromJson).toList(),
      venuePerformance: _mapList(
        rankings['performance_by_venue'] ?? rankings['venues'],
      ).map(VenuePerformanceRow.fromJson).toList(),
      topCourts: _mapList(
        rankings['top_courts'] ?? rankings['courts'],
      ).map(CourtPerformanceRow.fromJson).toList(),
      topCustomers: _mapList(
        rankings['top_customers'] ?? rankings['customers'],
      ).map(CustomerPerformanceRow.fromJson).toList(),
    );
  }

  /// Peels the `data`/`result` envelope down to the overview object.
  static Map<String, dynamic> _root(dynamic payload) {
    dynamic current = payload;
    for (int depth = 0; depth < 8; depth++) {
      if (current is! Map) return const <String, dynamic>{};
      final map = Map<String, dynamic>.from(current);
      if (map.containsKey('summary') ||
          map.containsKey('overview') ||
          map.containsKey('analytics')) {
        return map;
      }
      final next = map['data'] ?? map['result'];
      if (next == null) return map;
      current = next;
    }
    return const <String, dynamic>{};
  }
}

class OverviewPeriod {
  const OverviewPeriod({
    required this.filter,
    required this.dateFrom,
    required this.dateTo,
    required this.label,
    required this.previousDateFrom,
    required this.previousDateTo,
  });

  final String filter;
  final String dateFrom;
  final String dateTo;
  final String label;
  final String previousDateFrom;
  final String previousDateTo;

  factory OverviewPeriod.fromJson(Map<String, dynamic> json) => OverviewPeriod(
    filter: _str(json['filter']),
    dateFrom: _str(json['date_from']),
    dateTo: _str(json['date_to']),
    label: _str(json['label']),
    previousDateFrom: _str(json['previous_date_from']),
    previousDateTo: _str(json['previous_date_to']),
  );
}

class OverviewSummary {
  const OverviewSummary({
    required this.totalBookings,
    required this.paidBookings,
    required this.cancelledBookings,
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.profitMargin,
    required this.hoursPlayed,
    required this.bookedHours,
    required this.availableHours,
    required this.occupancyPercentage,
    required this.avgRevenuePerBooking,
    required this.avgRevenuePerPaidBooking,
  });

  final int totalBookings;
  final int paidBookings;
  final int cancelledBookings;
  final int revenue;
  final int expenses;
  final int netProfit;
  final double profitMargin;
  final int hoursPlayed;
  final int bookedHours;
  final int availableHours;
  final double occupancyPercentage;
  final int avgRevenuePerBooking;
  final int avgRevenuePerPaidBooking;

  factory OverviewSummary.fromJson(Map<String, dynamic> json) =>
      OverviewSummary(
        totalBookings: _int(json['total_bookings']),
        paidBookings: _int(json['paid_bookings']),
        cancelledBookings: _int(json['cancelled_bookings']),
        revenue: _int(json['revenue']),
        expenses: _int(json['expenses']),
        netProfit: _int(json['net_profit']),
        profitMargin: _double(json['profit_margin']),
        hoursPlayed: _int(json['hours_played']),
        bookedHours: _int(json['booked_hours']),
        availableHours: _int(json['available_hours']),
        occupancyPercentage: _double(json['occupancy_percentage']),
        avgRevenuePerBooking: _int(json['avg_revenue_per_booking']),
        avgRevenuePerPaidBooking: _int(json['avg_revenue_per_paid_booking']),
      );
}

class RevenueTrend {
  const RevenueTrend({
    required this.granularity,
    required this.average,
    required this.chartTitle,
    required this.buckets,
  });

  final String granularity;
  final int average;
  final String chartTitle;
  final List<TrendBucket> buckets;

  factory RevenueTrend.fromJson(Map<String, dynamic> json) => RevenueTrend(
    granularity: _str(json['granularity']),
    average: _int(json['average']),
    chartTitle: _str(json['chart_title']).isEmpty
        ? _str(json['title'])
        : _str(json['chart_title']),
    buckets: _mapList(json['buckets']).map(TrendBucket.fromJson).toList(),
  );
}

class TrendBucket {
  const TrendBucket({required this.label, required this.value});

  final String label;
  final int value;

  factory TrendBucket.fromJson(Map<String, dynamic> json) =>
      TrendBucket(label: _str(json['label']), value: _int(json['value']));
}

class StatusMixEntry {
  const StatusMixEntry({
    required this.status,
    required this.count,
    required this.percentage,
    required this.label,
    required this.colorHex,
  });

  final BookingStatus status;
  final int count;
  final double percentage;
  final String label;
  final String colorHex;

  factory StatusMixEntry.fromJson(Map<String, dynamic> json) => StatusMixEntry(
    status: BookingStatusLabel.fromKey(_str(json['status'])),
    count: _int(json['count']),
    percentage: _double(json['percentage']),
    label: _str(json['label']),
    colorHex: _str(json['color']),
  );
}

class NetEarnings {
  const NetEarnings({
    required this.currentRevenue,
    required this.previousRevenue,
    required this.changePercentage,
  });

  final int currentRevenue;
  final int previousRevenue;
  final double changePercentage;

  factory NetEarnings.fromJson(Map<String, dynamic> json) => NetEarnings(
    currentRevenue: _int(json['current_revenue']),
    previousRevenue: _int(json['previous_revenue']),
    changePercentage: _double(json['change_percentage']),
  );
}

/// A venue as it appears in the filter row. `id` is null for the "All venues"
/// chip.
class OverviewVenue {
  const OverviewVenue({
    required this.id,
    required this.name,
    required this.selected,
  });

  final String? id;
  final String name;
  final bool selected;

  factory OverviewVenue.fromJson(Map<String, dynamic> json) => OverviewVenue(
    id: json['id'] == null ? null : _str(json['id']),
    name: _str(json['name']),
    selected: json['selected'] == true,
  );
}

class VenuePerformanceRow {
  const VenuePerformanceRow({
    required this.name,
    required this.area,
    required this.courtCount,
    required this.bookings,
    required this.revenue,
    required this.occupancy,
  });

  final String name;
  final String area;
  final int courtCount;
  final int bookings;
  final int revenue;

  /// 0..1
  final double occupancy;

  factory VenuePerformanceRow.fromJson(Map<String, dynamic> json) {
    final rawOcc = _double(
      json['occupancy'] ?? json['occupancy_percentage'] ?? 0,
    );
    return VenuePerformanceRow(
      name: _str(json['name'] ?? json['venue_name']),
      area: _str(json['area'] ?? json['location'] ?? json['address']),
      courtCount: _int(json['courts'] ?? json['court_count'] ?? json['courts_count']),
      bookings: _int(json['bookings'] ?? json['total_bookings']),
      revenue: _int(json['revenue']),
      occupancy: rawOcc > 1 ? rawOcc / 100 : rawOcc,
    );
  }
}

class CourtPerformanceRow {
  const CourtPerformanceRow({
    required this.courtName,
    required this.venueName,
    required this.bookings,
    required this.revenue,
  });

  final String courtName;
  final String venueName;
  final int bookings;
  final int revenue;

  factory CourtPerformanceRow.fromJson(Map<String, dynamic> json) =>
      CourtPerformanceRow(
        courtName: _str(json['name'] ?? json['court_name']),
        venueName: _str(json['venue_name'] ?? json['futsal_name']),
        bookings: _int(json['bookings'] ?? json['total_bookings']),
        revenue: _int(json['revenue']),
      );
}

class CustomerPerformanceRow {
  const CustomerPerformanceRow({
    required this.name,
    required this.bookings,
    required this.spent,
  });

  final String name;
  final int bookings;
  final int spent;

  factory CustomerPerformanceRow.fromJson(Map<String, dynamic> json) =>
      CustomerPerformanceRow(
        name: _str(json['name'] ?? json['customer_name']),
        bookings: _int(json['bookings'] ?? json['total_bookings']),
        spent: _int(json['spent'] ?? json['revenue']),
      );
}
