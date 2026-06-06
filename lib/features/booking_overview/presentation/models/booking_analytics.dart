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
}

class BookingRange {
  const BookingRange(this.start, this.end);

  final DateTime start; // inclusive (00:00)
  final DateTime end; // exclusive (00:00 of next day)

  Duration get span => end.difference(start);
  int get days => span.inDays.clamp(1, 400);
  BookingRange get previous => BookingRange(start.subtract(span), start);
}

class FutsalPerformanceRow {
  const FutsalPerformanceRow({
    required this.futsal,
    required this.revenue,
    required this.bookings,
    required this.occupancy,
  });

  final BookingFutsalModel futsal;
  final int revenue;
  final int bookings;
  final double occupancy;
}

class CourtPerformanceRow {
  const CourtPerformanceRow({
    required this.court,
    required this.futsalName,
    required this.revenue,
    required this.bookings,
  });

  final BookingCourtModel court;
  final String futsalName;
  final int revenue;
  final int bookings;
}

class CustomerRow {
  const CustomerRow({
    required this.name,
    required this.bookings,
    required this.spent,
  });

  final String name;
  final int bookings;
  final int spent;
}

/// Period/venue-scoped aggregation over the booking list.
///
/// Built once per frame from bloc state; all aggregates are cached
/// (`late final`) so each is computed at most once per build, regardless of
/// how many widgets read them.
class BookingAnalytics {
  BookingAnalytics({
    required this.futsals,
    required this.bookings,
    required this.period,
    required this.range,
    required this.futsalFilter, // null = all
  });

  final List<BookingFutsalModel> futsals;
  final List<BookingRecordModel> bookings;
  final BookingPeriod period;
  final BookingRange range;
  final String? futsalFilter;

  late final List<BookingRecordModel> scoped = bookings.where((b) {
    if (futsalFilter != null && b.futsalId != futsalFilter) return false;
    return !b.start.isBefore(range.start) && b.start.isBefore(range.end);
  }).toList();

  late final List<BookingRecordModel> _scopedPrev = bookings.where((b) {
    if (futsalFilter != null && b.futsalId != futsalFilter) return false;
    return !b.start.isBefore(range.previous.start) &&
        b.start.isBefore(range.previous.end);
  }).toList();

  List<BookingFutsalModel> get _scopedFutsals => futsalFilter == null
      ? futsals
      : futsals.where((f) => f.id == futsalFilter).toList();

  bool _isRevenue(BookingStatus s) =>
      s == BookingStatus.completed || s == BookingStatus.confirmed;

  int _revenueOf(List<BookingRecordModel> xs) =>
      xs.where((b) => _isRevenue(b.status)).fold(0, (a, b) => a + b.amount);

  late final int revenue = _revenueOf(scoped);
  late final int prevRevenue = _revenueOf(_scopedPrev);

  /// Pro-rated monthly overheads + 8% variable cost per paid booking.
  late final int expenses = () {
    final overhead = _scopedFutsals.fold<int>(
      0,
      (a, f) => a + f.monthlyOverhead,
    );
    final prorated = (overhead * range.days / 30).round();
    final variable = (revenue * 0.08).round();
    return prorated + variable;
  }();

  int get profit => revenue - expenses;

  int get totalBookings => scoped.length;
  late final int cancelled =
      scoped.where((b) => b.status == BookingStatus.cancelled).length;
  late final int completed =
      scoped.where((b) => b.status == BookingStatus.completed).length;
  late final int confirmed =
      scoped.where((b) => b.status == BookingStatus.confirmed).length;
  late final int pending =
      scoped.where((b) => b.status == BookingStatus.pending).length;

  double get cancelRate => totalBookings == 0 ? 0 : cancelled / totalBookings;

  late final int hoursPlayed = scoped
      .where((b) => _isRevenue(b.status))
      .fold(0, (a, b) => a + b.hours);

  /// 16 open hours/day × courts in scope × days.
  double get occupancy {
    final courtCount = _scopedFutsals.fold<int>(
      0,
      (a, f) => a + f.courts.length,
    );
    final capacity = courtCount * 16 * range.days;
    if (capacity == 0) return 0;
    return (hoursPlayed / capacity).clamp(0.0, 1.0);
  }

  int get avgBookingValue {
    final paid = scoped.where((b) => _isRevenue(b.status)).toList();
    if (paid.isEmpty) return 0;
    return (paid.fold(0, (a, b) => a + b.amount) / paid.length).round();
  }

  /// Revenue series bucketed to match the period: hourly for today,
  /// monthly for year (and long custom ranges), daily otherwise.
  late final List<int> series = () {
    switch (period) {
      case BookingPeriod.today:
        return _hourlySeries();
      case BookingPeriod.year:
        return _monthlySeries();
      case BookingPeriod.custom:
        return range.days > 60 ? _monthlySeries() : _dailySeries();
      case BookingPeriod.week:
      case BookingPeriod.month:
        return _dailySeries();
    }
  }();

  /// Matching title for the trend card.
  String get seriesLabel {
    switch (period) {
      case BookingPeriod.today:
        return 'Hourly revenue';
      case BookingPeriod.year:
        return 'Monthly revenue';
      case BookingPeriod.custom:
        return range.days > 60 ? 'Monthly revenue' : 'Daily revenue';
      case BookingPeriod.week:
      case BookingPeriod.month:
        return 'Daily revenue';
    }
  }

  List<int> _dailySeries() {
    final out = List<int>.filled(range.days, 0);
    for (final b in scoped) {
      if (!_isRevenue(b.status)) continue;
      final dayIdx = b.start.difference(range.start).inDays;
      if (dayIdx >= 0 && dayIdx < out.length) out[dayIdx] += b.amount;
    }
    return out;
  }

  List<int> _hourlySeries() {
    final out = List<int>.filled(24, 0);
    for (final b in scoped) {
      if (!_isRevenue(b.status)) continue;
      out[b.start.hour] += b.amount;
    }
    return out;
  }

  List<int> _monthlySeries() {
    final months = <DateTime>[];
    var cursor = DateTime(range.start.year, range.start.month, 1);
    while (cursor.isBefore(range.end)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    if (months.isEmpty) {
      months.add(DateTime(range.start.year, range.start.month, 1));
    }
    final out = List<int>.filled(months.length, 0);
    for (final b in scoped) {
      if (!_isRevenue(b.status)) continue;
      final idx = months.indexWhere(
        (m) => m.year == b.start.year && m.month == b.start.month,
      );
      if (idx >= 0) out[idx] += b.amount;
    }
    return out;
  }

  late final Map<BookingStatus, int> statusBreakdown = () {
    final m = <BookingStatus, int>{
      for (final s in BookingStatus.values) s: 0,
    };
    for (final b in scoped) {
      m[b.status] = (m[b.status] ?? 0) + 1;
    }
    return m;
  }();

  late final List<FutsalPerformanceRow> futsalLeaderboard = () {
    final out = <FutsalPerformanceRow>[];
    for (final f in _scopedFutsals) {
      final rows = scoped.where((b) => b.futsalId == f.id);
      final rev = rows
          .where((b) => _isRevenue(b.status))
          .fold(0, (a, b) => a + b.amount);
      final hours = rows
          .where((b) => _isRevenue(b.status))
          .fold(0, (a, b) => a + b.hours);
      final capacity = f.courts.length * 16 * range.days;
      final util = capacity == 0 ? 0.0 : (hours / capacity).clamp(0.0, 1.0);
      out.add(
        FutsalPerformanceRow(
          futsal: f,
          revenue: rev,
          bookings: rows.length,
          occupancy: util,
        ),
      );
    }
    out.sort((a, b) => b.revenue.compareTo(a.revenue));
    return out;
  }();

  late final List<CourtPerformanceRow> courtLeaderboard = () {
    final out = <CourtPerformanceRow>[];
    for (final f in _scopedFutsals) {
      for (final c in f.courts) {
        final rows = scoped.where((b) => b.courtId == c.id);
        final rev = rows
            .where((b) => _isRevenue(b.status))
            .fold(0, (a, b) => a + b.amount);
        out.add(
          CourtPerformanceRow(
            court: c,
            futsalName: f.name,
            revenue: rev,
            bookings: rows.length,
          ),
        );
      }
    }
    out.sort((a, b) => b.revenue.compareTo(a.revenue));
    return out;
  }();

  late final List<CustomerRow> topCustomers = () {
    final acc = <String, CustomerRow>{};
    for (final b in scoped) {
      if (!_isRevenue(b.status)) continue;
      final row = acc.putIfAbsent(
        b.customer,
        () => CustomerRow(name: b.customer, bookings: 0, spent: 0),
      );
      acc[b.customer] = CustomerRow(
        name: row.name,
        bookings: row.bookings + 1,
        spent: row.spent + b.amount,
      );
    }
    final out = acc.values.toList()..sort((a, b) => b.spent.compareTo(a.spent));
    return out.take(5).toList();
  }();
}
