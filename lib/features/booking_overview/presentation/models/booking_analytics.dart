import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';

enum BookingPeriod { today, week, month, year, custom }

extension BookingPeriodLabel on BookingPeriod {
  String get label => switch (this) {
    BookingPeriod.today => 'Today',
    BookingPeriod.week => 'Week',
    BookingPeriod.month => 'Month',
    BookingPeriod.year => 'Year',
    BookingPeriod.custom => 'Custom',
  };

  /// The `date_filter` query value the API expects.
  String get key => name;

  static BookingPeriod fromKey(String? key) {
    switch ((key ?? '').toLowerCase()) {
      case 'today':
        return BookingPeriod.today;
      case 'month':
        return BookingPeriod.month;
      case 'year':
        return BookingPeriod.year;
      case 'custom':
        return BookingPeriod.custom;
      default:
        return BookingPeriod.week;
    }
  }
}

class BookingRange {
  const BookingRange(this.start, this.end);

  final DateTime start; // inclusive (00:00)
  final DateTime end; // exclusive (00:00 of next day)

  int get days => end.difference(start).inDays.clamp(1, 400);

  /// Builds a range from the API's inclusive `date_from`/`date_to` strings.
  factory BookingRange.fromApi(String from, String to) {
    final start = DateTime.tryParse(from) ?? DateTime.now();
    final end = DateTime.tryParse(to) ?? start;
    return BookingRange(
      DateTime(start.year, start.month, start.day),
      DateTime(end.year, end.month, end.day).add(const Duration(days: 1)),
    );
  }
}

/// Presentation-facing view over the server's pre-computed overview payload.
/// Every widget reads from these getters, so the raw API shape stays contained
/// to the data layer.
class BookingAnalytics {
  BookingAnalytics({
    required this.data,
    required this.period,
    required this.range,
  });

  final BookingOverviewResponse data;
  final BookingPeriod period;
  final BookingRange range;

  // ── Hero / KPI numbers ──
  int get revenue => data.summary.revenue;
  int get prevRevenue => data.netEarnings.previousRevenue;
  int get expenses => data.summary.expenses;
  int get profit => data.netProfit.value;
  int get totalBookings => data.summary.totalBookings;
  int get paidBookings => data.summary.paidBookings;
  int get cancelledBookings => data.summary.cancelledBookings;
  double get hoursPlayed => data.summary.hoursPlayed;
  double get avgPaidBookingValue => data.summary.avgRevenuePerPaidBooking;
  double get avgBookingValue => data.summary.avgRevenuePerBooking;

  /// 0..1
  double get occupancy =>
      (data.summary.occupancyPercentage / 100).clamp(0.0, 1.0);

  /// Server-computed profit margin, in percent.
  double get profitMargin => data.netProfit.margin;

  /// Server-computed revenue change vs the previous period, in percent.
  double get revenueChangePct => data.netEarnings.changePercentage;

  /// `Sep 21 - Sep 27 · 9 bookings · NPR 8,400`, straight from the server.
  String get summaryLine => data.header.summaryLine;

  /// KPI tile from `overview.snapshot`, or null if the server omitted it.
  OverviewCard? card(String key) => data.cards[key];

  /// Server subtext for a KPI tile, or [fallback] when missing/blank.
  String cardSubtext(String key, String fallback) {
    final String sub = data.cards[key]?.subtext ?? '';
    return sub.isEmpty ? fallback : sub;
  }

  /// Server label for a KPI tile, or [fallback] when missing/blank.
  String cardLabel(String key, String fallback) {
    final String label = data.cards[key]?.label ?? '';
    return label.isEmpty ? fallback : label;
  }

  // ── Status breakdown ──
  late final Map<BookingStatus, int> statusBreakdown = {
    for (final s in BookingStatus.values)
      s: data.statusMix
          .where((e) => e.status == s)
          .fold(0, (a, e) => a + e.count),
  };

  int get completed => statusBreakdown[BookingStatus.completed] ?? 0;
  int get confirmed => statusBreakdown[BookingStatus.confirmed] ?? 0;
  int get pending => statusBreakdown[BookingStatus.pending] ?? 0;
  int get cancelled => statusBreakdown[BookingStatus.cancelled] ?? 0;

  double get cancelRate => totalBookings == 0 ? 0 : cancelled / totalBookings;

  /// Status rows in server order; falls back to every status at zero.
  List<StatusMixEntry> get statusMix => data.statusMix.isNotEmpty
      ? data.statusMix
      : [
          for (final s in BookingStatus.values)
            StatusMixEntry(
              status: s,
              count: 0,
              percentage: 0,
              label: s.label,
              colorHex: '',
            ),
        ];

  int get statusTotal =>
      data.statusMix.fold(0, (int a, StatusMixEntry e) => a + e.count);

  String get statusTitle =>
      data.statusTitle.isEmpty ? 'Booking statuses' : data.statusTitle;

  String get statusChartTitle =>
      data.statusChartTitle.isEmpty ? 'Status mix' : data.statusChartTitle;

  // ── Revenue trend series ──
  List<int> get series =>
      data.trend.buckets.map((b) => b.value).toList(growable: false);

  List<String> get seriesLabels =>
      data.trend.buckets.map((b) => b.label).toList(growable: false);

  String get trendTitle =>
      data.trend.title.isEmpty ? 'Revenue trend' : data.trend.title;

  String get seriesLabel =>
      data.trend.chartTitle.isEmpty ? 'Revenue' : data.trend.chartTitle;

  /// `Avg NPR 1,200` from the server, computed from the buckets otherwise.
  String get averageLabel {
    if (data.trend.averageLabel.isNotEmpty) return data.trend.averageLabel;
    final values = series;
    final int avg = data.trend.average != 0 || values.isEmpty
        ? data.trend.average
        : (values.reduce((a, b) => a + b) / values.length).round();
    return 'Avg NPR ${_group(avg)}';
  }

  static String _group(int v) {
    final digits = v.abs().toString();
    final buf = StringBuffer(v < 0 ? '-' : '');
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  // ── Leaderboards ──
  List<VenuePerformanceRow> get futsalLeaderboard => data.venuePerformance;
  List<CourtPerformanceRow> get courtLeaderboard => data.topCourts;
  List<CustomerPerformanceRow> get topCustomers => data.topCustomers;
}
