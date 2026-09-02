import 'package:hamro_futsal/features/expenses/data/model/expense_model.dart';
import 'package:hamro_futsal/features/expenses/presentation/utils/expense_ui_utils.dart';

enum ExpensePeriod { today, week, month, year, custom }

extension ExpensePeriodLabel on ExpensePeriod {
  String get label => switch (this) {
    ExpensePeriod.today => 'Today',
    ExpensePeriod.week => 'Week',
    ExpensePeriod.month => 'Month',
    ExpensePeriod.year => 'Year',
    ExpensePeriod.custom => 'Custom',
  };
}

class ExpenseRange {
  const ExpenseRange(this.start, this.end);

  final DateTime start;
  final DateTime end; // exclusive

  Duration get span => end.difference(start);
  int get days => span.inDays.clamp(1, 400);
  ExpenseRange get previous => ExpenseRange(start.subtract(span), start);
}

class ChartBucket {
  const ChartBucket(this.label, this.value);

  final String label;
  final int value;
}

class ExpenseAnalytics {
  ExpenseAnalytics({
    required this.expenses,
    required this.period,
    required this.range,
    required this.venueFilter,
    required this.categoryFilter,
  });

  final List<ExpenseModel> expenses;
  final ExpensePeriod period;
  final ExpenseRange range;
  final String? venueFilter;

  final String? categoryFilter;

  late final List<ExpenseModel> scoped = expenses.where((e) {
    if (venueFilter != null && e.venueId != venueFilter) return false;
    if (categoryFilter != null && e.categoryId != categoryFilter) return false;
    return !e.date.isBefore(range.start) && e.date.isBefore(range.end);
  }).toList();

  late final List<ExpenseModel> _scopedPrev = expenses.where((e) {
    if (venueFilter != null && e.venueId != venueFilter) return false;
    if (categoryFilter != null && e.categoryId != categoryFilter) return false;
    final p = range.previous;
    return !e.date.isBefore(p.start) && e.date.isBefore(p.end);
  }).toList();

  late final int total = scoped.fold(0, (a, e) => a + e.amount);
  late final int prevTotal = _scopedPrev.fold(0, (a, e) => a + e.amount);
  int get count => scoped.length;

  int get avgPerDay {
    if (range.days == 0) return 0;
    return (total / range.days).round();
  }

  int get avgPerEntry => count == 0 ? 0 : (total / count).round();

  late final Map<String, int> byCategory = scoped.fold(
    <String, int>{},
    (m, e) =>
        m..update(e.categoryId, (v) => v + e.amount, ifAbsent: () => e.amount),
  );

  late final Map<String, ExpenseCategoryModel> _categoryDetails = {
    for (final e in scoped)
      if (e.categoryDetail != null) e.categoryId: e.categoryDetail!,
  };

  late final Map<String, ExpenseCategory> _categoryEnums = {
    for (final e in scoped) e.categoryId: e.category,
  };

  ExpenseCategoryModel? categoryDetail(String id) => _categoryDetails[id];

  ExpenseCategory categoryEnumOf(String id) =>
      _categoryEnums[id] ?? ExpenseCategory.other;

  /// Display name straight from the API response, enum label as fallback.
  String categoryName(String id) =>
      categoryDetail(id)?.name ?? categoryEnumOf(id).label;

  late final Map<String, int> byVenue = scoped.fold(
    <String, int>{},
    (m, e) =>
        m..update(e.venueId, (v) => v + e.amount, ifAbsent: () => e.amount),
  );

  late final String? largestCategoryId = byCategory.isEmpty
      ? null
      : byCategory.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  late final String? largestVenueId = byVenue.isEmpty
      ? null
      : byVenue.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  /// Bucketed series for the trend chart.
  late final List<ChartBucket> series = _buildSeries();

  List<ChartBucket> _buildSeries() {
    switch (period) {
      case ExpensePeriod.year:
        return _monthlyBuckets();
      case ExpensePeriod.month:
      case ExpensePeriod.week:
        return _dailyBuckets();
      case ExpensePeriod.today:
        return _hourlyBuckets();
      case ExpensePeriod.custom:
        return range.days > 60 ? _monthlyBuckets() : _dailyBuckets();
    }
  }

  List<ChartBucket> _hourlyBuckets() {
    final out = List<int>.filled(24, 0);
    for (final e in scoped) {
      out[e.date.hour] += e.amount;
    }
    String label(int h) {
      if (h == 0) return '12am';
      if (h < 12) return '${h}am';
      if (h == 12) return '12pm';
      return '${h - 12}pm';
    }

    return [for (int i = 0; i < 24; i++) ChartBucket(label(i), out[i])];
  }

  List<ChartBucket> _dailyBuckets() {
    final out = List<int>.filled(range.days, 0);
    for (final e in scoped) {
      final idx = DateTime(
        e.date.year,
        e.date.month,
        e.date.day,
      ).difference(range.start).inDays;
      if (idx >= 0 && idx < out.length) out[idx] += e.amount;
    }
    final firstLabel = formatShortDate(range.start);
    final lastLabel = formatShortDate(
      range.end.subtract(const Duration(days: 1)),
    );
    final result = <ChartBucket>[];
    for (int i = 0; i < out.length; i++) {
      final d = range.start.add(Duration(days: i));
      result.add(
        ChartBucket(
          i == 0
              ? firstLabel
              : i == out.length - 1
              ? lastLabel
              : '${d.day}',
          out[i],
        ),
      );
    }
    return result;
  }

  List<ChartBucket> _monthlyBuckets() {
    final months = <DateTime>[];
    var cursor = DateTime(range.start.year, range.start.month, 1);
    final endCursor = DateTime(range.end.year, range.end.month, 1);
    while (!cursor.isAfter(endCursor) && cursor.isBefore(range.end)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    if (months.isEmpty) {
      months.add(DateTime(range.start.year, range.start.month, 1));
    }
    final values = List<int>.filled(months.length, 0);
    for (final e in scoped) {
      final idx = months.indexWhere(
        (m) => m.year == e.date.year && m.month == e.date.month,
      );
      if (idx >= 0) values[idx] += e.amount;
    }
    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return [
      for (int i = 0; i < months.length; i++)
        ChartBucket(monthLabels[months[i].month - 1], values[i]),
    ];
  }
}
