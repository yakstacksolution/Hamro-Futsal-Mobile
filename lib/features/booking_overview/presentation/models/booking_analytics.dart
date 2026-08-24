import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';

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
  int get profit => data.summary.netProfit;
  int get totalBookings => data.summary.totalBookings;
  int get hoursPlayed => data.summary.hoursPlayed;
  int get avgBookingValue => data.summary.avgRevenuePerBooking;

  /// 0..1
  double get occupancy =>
      (data.summary.occupancyPercentage / 100).clamp(0.0, 1.0);

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

  // ── Revenue trend series ──
  List<int> get series =>
      data.trend.buckets.map((b) => b.value).toList(growable: false);

  String get seriesLabel =>
      data.trend.chartTitle.isEmpty ? 'Revenue' : data.trend.chartTitle;

  // ── Leaderboards ──
  List<VenuePerformanceRow> get futsalLeaderboard => data.venuePerformance;
  List<CourtPerformanceRow> get courtLeaderboard => data.topCourts;
  List<CustomerPerformanceRow> get topCustomers => data.topCustomers;
}
