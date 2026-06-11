import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v?.toString() ?? '') ??
      double.tryParse(v?.toString() ?? '')?.round() ??
      0;
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

/// One ranked entity in the summary block: top category / venue / court.
class ExpenseTopRef {
  const ExpenseTopRef({
    required this.id,
    required this.name,
    required this.total,
  });

  final String id;
  final String name;
  final int total;

  static ExpenseTopRef? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = (json['id'] ?? '').toString();
    if (id.isEmpty) return null;
    return ExpenseTopRef(
      id: id,
      name: (json['title'] ?? json['name'] ?? '').toString().trim(),
      total: _toInt(json['total']),
    );
  }
}

/// `data.summary` — server-computed headline numbers for the Overview tab.
class ExpenseSummary {
  const ExpenseSummary({
    required this.totalSpend,
    required this.avgPerDay,
    required this.entries,
    this.topCategory,
    this.topVenue,
    this.topCourt,
  });

  final int totalSpend;
  final double avgPerDay;
  final int entries;
  final ExpenseTopRef? topCategory;
  final ExpenseTopRef? topVenue;
  final ExpenseTopRef? topCourt;

  int get avgPerEntry => entries == 0 ? 0 : (totalSpend / entries).round();

  static const empty = ExpenseSummary(totalSpend: 0, avgPerDay: 0, entries: 0);

  factory ExpenseSummary.fromJson(Map json) => ExpenseSummary(
    totalSpend: _toInt(json['total_spend']),
    avgPerDay: _toDouble(json['avg_per_day']),
    entries: _toInt(json['entries']),
    topCategory: ExpenseTopRef.fromJson(json['top_category']),
    topVenue: ExpenseTopRef.fromJson(json['top_venue']),
    topCourt: ExpenseTopRef.fromJson(json['top_court']),
  );
}

class ExpenseTrendBucket {
  const ExpenseTrendBucket({required this.label, required this.value});

  final String label;
  final int value;
}

/// `data.analytics.trend` — the spend chart series. [granularity] changes
/// with the selected date filter (hourly → daily → monthly).
class ExpenseTrend {
  const ExpenseTrend({
    required this.granularity,
    required this.avg,
    required this.buckets,
  });

  final String granularity; // hourly | daily | monthly
  final int avg;
  final List<ExpenseTrendBucket> buckets;

  static const empty = ExpenseTrend(granularity: '', avg: 0, buckets: []);

  String get title => switch (granularity) {
    'hourly' => 'Hourly spend',
    'monthly' => 'Monthly spend',
    _ => 'Daily spend',
  };

  factory ExpenseTrend.fromJson(Map json) {
    final buckets = <ExpenseTrendBucket>[];
    final raw = json['buckets'];
    if (raw is List) {
      for (final b in raw) {
        if (b is! Map) continue;
        buckets.add(
          ExpenseTrendBucket(
            label: (b['label'] ?? b['month'] ?? '').toString(),
            value: _toInt(b['value'] ?? b['total']),
          ),
        );
      }
    }
    return ExpenseTrend(
      granularity: (json['granularity'] ?? '').toString(),
      avg: _toInt(json['avg']),
      buckets: buckets,
    );
  }

  /// Legacy fallback: build a monthly trend from a flat `monthly_spend` list
  /// of `{label, total}` items.
  factory ExpenseTrend.fromMonthlySpend(List raw) {
    final buckets = <ExpenseTrendBucket>[];
    for (final b in raw) {
      if (b is! Map) continue;
      buckets.add(
        ExpenseTrendBucket(
          label: (b['label'] ?? b['month'] ?? '').toString(),
          value: _toInt(b['total'] ?? b['value']),
        ),
      );
    }
    final avg = buckets.isEmpty
        ? 0
        : (buckets.fold<int>(0, (a, b) => a + b.value) / buckets.length)
              .round();
    return ExpenseTrend(granularity: 'monthly', avg: avg, buckets: buckets);
  }
}

/// `data.analytics.by_category` — one slice of the category breakdown.
class ExpenseCategorySpend {
  const ExpenseCategorySpend({
    required this.id,
    required this.title,
    required this.slug,
    required this.image,
    required this.amount,
    required this.fraction,
    required this.percentage,
  });

  final String id;
  final String title;
  final String slug;
  final String image;
  final int amount;
  final double fraction;
  final double percentage;

  /// Maps onto the local enum (for accent color / fallback icon).
  ExpenseCategory get asEnum => ExpenseCategoryModel(
    id: id,
    name: title,
    slug: slug,
    image: image,
  ).asEnum;

  factory ExpenseCategorySpend.fromJson(Map json) {
    final amount = _toInt(json['amount'] ?? json['total']);
    final pct = json.containsKey('percentage')
        ? _toDouble(json['percentage'])
        : _toDouble(json['fraction']) * 100;
    return ExpenseCategorySpend(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString().trim(),
      slug: (json['slug'] ?? '').toString().trim(),
      image: (json['image'] ?? '').toString().trim(),
      amount: amount,
      fraction: json.containsKey('fraction')
          ? _toDouble(json['fraction'])
          : pct / 100,
      percentage: pct,
    );
  }
}

/// `data.analytics.by_court` — one slice of the court breakdown.
class ExpenseCourtSpend {
  const ExpenseCourtSpend({
    required this.id,
    required this.name,
    required this.amount,
    required this.fraction,
    required this.percentage,
  });

  final String id;
  final String name;
  final int amount;
  final double fraction;
  final double percentage;

  factory ExpenseCourtSpend.fromJson(Map json) {
    final amount = _toInt(json['amount'] ?? json['total']);
    final pct = json.containsKey('percentage')
        ? _toDouble(json['percentage'])
        : _toDouble(json['fraction']) * 100;
    return ExpenseCourtSpend(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString().trim(),
      amount: amount,
      fraction: json.containsKey('fraction')
          ? _toDouble(json['fraction'])
          : pct / 100,
      percentage: pct,
    );
  }
}

class ExpenseReport {
  const ExpenseReport({
    required this.summary,
    required this.trend,
    required this.byCategory,
    required this.byCourt,
    required this.records,
  });

  final ExpenseSummary summary;
  final ExpenseTrend trend;
  final List<ExpenseCategorySpend> byCategory;
  final List<ExpenseCourtSpend> byCourt;
  final List<ExpenseModel> records;

  static const empty = ExpenseReport(
    summary: ExpenseSummary.empty,
    trend: ExpenseTrend.empty,
    byCategory: [],
    byCourt: [],
    records: [],
  );

  ExpenseReport copyWith({List<ExpenseModel>? records}) => ExpenseReport(
    summary: summary,
    trend: trend,
    byCategory: byCategory,
    byCourt: byCourt,
    records: records ?? this.records,
  );

 
  static Map<String, dynamic> _data(dynamic payload) {
    if (payload is Map) {
      final inner = payload['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(payload);
    }
    return const {};
  }

  factory ExpenseReport.fromApi(dynamic payload) {
    final data = _data(payload);

    final summaryJson = data['summary'];
    final summary = summaryJson is Map
        ? ExpenseSummary.fromJson(summaryJson)
        : ExpenseSummary.empty;

     final analytics = data['analytics'];
    ExpenseTrend trend = ExpenseTrend.empty;
    final byCategory = <ExpenseCategorySpend>[];
    final byCourt = <ExpenseCourtSpend>[];
    if (analytics is Map) {
      final trendJson = analytics['trend'];
      if (trendJson is Map) {
        trend = ExpenseTrend.fromJson(trendJson);
      } else if (analytics['monthly_spend'] is List) {
        trend = ExpenseTrend.fromMonthlySpend(
          analytics['monthly_spend'] as List,
        );
      }

      final cats =
          analytics['by_category'] ?? analytics['category_wise_spends'];
      if (cats is List) {
        for (final c in cats) {
          if (c is Map) byCategory.add(ExpenseCategorySpend.fromJson(c));
        }
      }

      final courts = analytics['by_court'] ?? analytics['court_wise_spends'];
      if (courts is List) {
        for (final c in courts) {
          if (c is Map) byCourt.add(ExpenseCourtSpend.fromJson(c));
        }
      }
    }
    byCategory.sort((a, b) => b.amount.compareTo(a.amount));
    byCourt.sort((a, b) => b.amount.compareTo(a.amount));

     final records = <ExpenseModel>[];
    final recordsNode = data['records'];
    dynamic items;
    if (recordsNode is Map) {
      items = recordsNode['items'] ?? recordsNode['data'];
    } else if (recordsNode is List) {
      items = recordsNode;
    }
    if (items is List) {
      for (final e in items) {
        if (e is Map) {
          records.add(ExpenseModel.fromApiJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    records.sort((a, b) => b.date.compareTo(a.date));

    return ExpenseReport(
      summary: summary,
      trend: trend,
      byCategory: byCategory,
      byCourt: byCourt,
      records: records,
    );
  }
}
