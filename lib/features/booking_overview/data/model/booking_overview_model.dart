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

double _double(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

String _str(dynamic v) => v?.toString().trim() ?? '';

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

List<Map<String, dynamic>> _mapList(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const <Map<String, dynamic>>[];

/// Full payload of `GET /booking-overview`. The server pre-computes every
/// aggregate (and most display strings); the UI just renders it.
class BookingOverviewResponse {
  const BookingOverviewResponse({
    required this.period,
    required this.header,
    required this.datePresets,
    required this.summary,
    required this.cards,
    required this.trend,
    required this.statusMix,
    required this.statusTitle,
    required this.statusChartTitle,
    required this.netEarnings,
    required this.netProfit,
    required this.availableVenues,
    required this.venueChips,
    required this.selectedVenueIds,
    required this.venuePerformance,
    required this.topCourts,
    required this.topCustomers,
  });

  final OverviewPeriod period;
  final OverviewHeader header;
  final List<DatePreset> datePresets;
  final OverviewSummary summary;

  /// `overview.snapshot` (falls back to `overview.cards`), keyed by card key:
  /// `total_bookings`, `cancelled`, `revenue`, `expenses`, `hours_played`,
  /// `occupancy`.
  final Map<String, OverviewCard> cards;
  final RevenueTrend trend;
  final List<StatusMixEntry> statusMix;
  final String statusTitle;
  final String statusChartTitle;
  final NetEarnings netEarnings;
  final NetProfit netProfit;
  final List<OverviewVenue> availableVenues;
  final List<OverviewVenue> venueChips;
  final List<String> selectedVenueIds;
  final List<VenuePerformanceRow> venuePerformance;
  final List<CourtPerformanceRow> topCourts;
  final List<CustomerPerformanceRow> topCustomers;

  factory BookingOverviewResponse.fromResponse(dynamic payload) {
    final root = _root(payload);
    final filters = _map(root['filters']);
    final analytics = _map(root['analytics']);
    final overview = _map(root['overview']);
    final rankings = _map(root['rankings']);
    final statuses = _map(analytics['booking_statuses']);
    final summary = OverviewSummary.fromJson(_map(root['summary']));

    return BookingOverviewResponse(
      period: OverviewPeriod.fromJson(_map(root['period'])),
      header: OverviewHeader.fromJson(_map(root['header'])),
      datePresets: _mapList(
        filters['date_presets'],
      ).map(DatePreset.fromJson).toList(),
      summary: summary,
      cards: _cards(overview),
      trend: RevenueTrend.fromJson(_map(analytics['revenue_trend'])),
      statusMix: _mapList(
        statuses['status_mix'],
      ).map(StatusMixEntry.fromJson).toList(),
      statusTitle: _str(statuses['title']),
      statusChartTitle: _str(statuses['chart_title']),
      netEarnings: NetEarnings.fromJson(_map(overview['net_earnings'])),
      netProfit: overview['net_profit'] is Map
          ? NetProfit.fromJson(_map(overview['net_profit']))
          : NetProfit(value: summary.netProfit, margin: summary.profitMargin),
      availableVenues: _mapList(
        filters['available_venues'],
      ).map(OverviewVenue.fromJson).toList(),
      venueChips: _mapList(
        filters['venue_chips'],
      ).map(OverviewVenue.fromJson).toList(),
      selectedVenueIds: filters['selected_venue_ids'] is List
          ? (filters['selected_venue_ids'] as List)
                .where((e) => e != null)
                .map(_str)
                .toList()
          : const <String>[],
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

  static Map<String, OverviewCard> _cards(Map<String, dynamic> overview) {
    final snapshot = _mapList(overview['snapshot']);
    if (snapshot.isNotEmpty) {
      return {
        for (final json in snapshot)
          _str(json['key']): OverviewCard.fromJson(json),
      };
    }
    return {
      for (final entry in _map(overview['cards']).entries)
        if (entry.value is Map)
          entry.key: OverviewCard.fromJson({
            ..._map(entry.value),
            'key': entry.key,
          }),
    };
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

class OverviewHeader {
  const OverviewHeader({
    required this.title,
    required this.periodLabel,
    required this.totalBookings,
    required this.revenue,
    required this.summaryLine,
  });

  final String title;
  final String periodLabel;
  final int totalBookings;
  final int revenue;

  /// e.g. `Sep 21 - Sep 27 · 9 bookings · NPR 8,400`.
  final String summaryLine;

  factory OverviewHeader.fromJson(Map<String, dynamic> json) => OverviewHeader(
    title: _str(json['title']),
    periodLabel: _str(json['period_label']),
    totalBookings: _int(json['total_bookings']),
    revenue: _int(json['revenue']),
    summaryLine: _str(json['summary_line']),
  );
}

/// A date-window chip from `filters.date_presets`.
class DatePreset {
  const DatePreset({
    required this.key,
    required this.label,
    required this.selected,
  });

  final String key;
  final String label;
  final bool selected;

  factory DatePreset.fromJson(Map<String, dynamic> json) => DatePreset(
    key: _str(json['key']),
    label: _str(json['label']),
    selected: json['selected'] == true,
  );
}

/// One KPI tile from `overview.snapshot` / `overview.cards`.
class OverviewCard {
  const OverviewCard({
    required this.key,
    required this.label,
    required this.value,
    required this.subtext,
  });

  final String key;
  final String label;
  final num value;
  final String subtext;

  factory OverviewCard.fromJson(Map<String, dynamic> json) => OverviewCard(
    key: _str(json['key']),
    label: _str(json['label']),
    value: json['value'] is num ? json['value'] as num : _double(json['value']),
    subtext: _str(json['subtext']),
  );
}

class NetProfit {
  const NetProfit({required this.value, required this.margin});

  final int value;

  /// Percentage, e.g. `100` for 100%.
  final double margin;

  factory NetProfit.fromJson(Map<String, dynamic> json) =>
      NetProfit(value: _int(json['value']), margin: _double(json['margin']));
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
  final double hoursPlayed;
  final double bookedHours;
  final double availableHours;
  final double occupancyPercentage;
  final double avgRevenuePerBooking;
  final double avgRevenuePerPaidBooking;

  factory OverviewSummary.fromJson(Map<String, dynamic> json) =>
      OverviewSummary(
        totalBookings: _int(json['total_bookings']),
        paidBookings: _int(json['paid_bookings']),
        cancelledBookings: _int(json['cancelled_bookings']),
        revenue: _int(json['revenue']),
        expenses: _int(json['expenses']),
        netProfit: _int(json['net_profit']),
        profitMargin: _double(json['profit_margin']),
        hoursPlayed: _double(json['hours_played']),
        bookedHours: _double(json['booked_hours']),
        availableHours: _double(json['available_hours']),
        occupancyPercentage: _double(json['occupancy_percentage']),
        avgRevenuePerBooking: _double(json['avg_revenue_per_booking']),
        avgRevenuePerPaidBooking: _double(json['avg_revenue_per_paid_booking']),
      );
}

class RevenueTrend {
  const RevenueTrend({
    required this.granularity,
    required this.average,
    required this.title,
    required this.chartTitle,
    required this.averageLabel,
    required this.buckets,
  });

  /// `hourly` / `daily` / `monthly`.
  final String granularity;
  final int average;

  /// Section heading, e.g. `Revenue trend`.
  final String title;

  /// Card heading, e.g. `Daily revenue`.
  final String chartTitle;

  /// e.g. `Avg NPR 1,200`.
  final String averageLabel;
  final List<TrendBucket> buckets;

  factory RevenueTrend.fromJson(Map<String, dynamic> json) => RevenueTrend(
    granularity: _str(json['granularity']),
    average: _int(json['average']),
    title: _str(json['title']),
    chartTitle: _str(json['chart_title']),
    averageLabel: _str(json['average_label']),
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
    required this.id,
    required this.name,
    required this.area,
    required this.courtCount,
    required this.bookings,
    required this.revenue,
    required this.bookedHours,
    required this.occupancy,
  });

  final String? id;
  final String name;
  final String area;
  final int courtCount;
  final int bookings;
  final int revenue;
  final double bookedHours;

  /// 0..1
  final double occupancy;

  factory VenuePerformanceRow.fromJson(Map<String, dynamic> json) {
    // `occupancy_percentage` is always 0..100; a bare `occupancy` may be 0..1.
    final double occupancy = json.containsKey('occupancy_percentage')
        ? _double(json['occupancy_percentage']) / 100
        : () {
            final raw = _double(json['occupancy']);
            return raw > 1 ? raw / 100 : raw;
          }();
    return VenuePerformanceRow(
      id: json['id'] == null ? null : _str(json['id']),
      name: _str(json['name'] ?? json['venue_name']),
      area: _str(json['area'] ?? json['location'] ?? json['address']),
      courtCount: _int(
        json['courts'] ?? json['court_count'] ?? json['courts_count'],
      ),
      bookings: _int(
        json['bookings_count'] ?? json['bookings'] ?? json['total_bookings'],
      ),
      revenue: _int(json['revenue']),
      bookedHours: _double(json['booked_hours']),
      occupancy: occupancy.clamp(0.0, 1.0),
    );
  }
}

class CourtPerformanceRow {
  const CourtPerformanceRow({
    required this.id,
    required this.courtName,
    required this.venueName,
    required this.bookings,
    required this.revenue,
    required this.progress,
  });

  final String? id;
  final String courtName;
  final String venueName;
  final int bookings;
  final int revenue;

  /// Relative revenue bar, 0..1. Null when the server didn't send one.
  final double? progress;

  factory CourtPerformanceRow.fromJson(Map<String, dynamic> json) =>
      CourtPerformanceRow(
        id: json['id'] == null ? null : _str(json['id']),
        courtName: _str(json['name'] ?? json['court_name']),
        venueName: _str(json['venue_name'] ?? json['futsal_name']),
        bookings: _int(
          json['bookings_count'] ?? json['bookings'] ?? json['total_bookings'],
        ),
        revenue: _int(json['revenue']),
        progress: json['progress_percentage'] == null
            ? null
            : (_double(json['progress_percentage']) / 100).clamp(0.0, 1.0),
      );
}

class CustomerPerformanceRow {
  const CustomerPerformanceRow({
    required this.name,
    required this.initials,
    required this.email,
    required this.phone,
    required this.bookings,
    required this.spent,
  });

  final String name;
  final String initials;
  final String email;
  final String phone;
  final int bookings;
  final int spent;

  factory CustomerPerformanceRow.fromJson(Map<String, dynamic> json) =>
      CustomerPerformanceRow(
        name: _str(json['name'] ?? json['customer_name']),
        initials: _str(json['initials']),
        email: _str(json['email']),
        phone: _str(json['phone']),
        bookings: _int(
          json['bookings_count'] ?? json['bookings'] ?? json['total_bookings'],
        ),
        spent: _int(json['spent'] ?? json['revenue']),
      );
}
