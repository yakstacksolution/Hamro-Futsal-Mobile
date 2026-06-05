import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

enum _Period { week, month, year, custom }

extension on _Period {
  String get label => switch (this) {
    _Period.week => 'Week',
    _Period.month => 'Month',
    _Period.year => 'Year',
    _Period.custom => 'Custom',
  };
}

enum _ExpenseCategory {
  rent,
  maintenance,
  salaries,
  supplies,
  marketing,
  refreshments,
  insurance,
  utilities,
  other,
}

extension _CatExt on _ExpenseCategory {
  String get label => switch (this) {
    _ExpenseCategory.rent => 'Rent',
    _ExpenseCategory.maintenance => 'Maintenance',
    _ExpenseCategory.salaries => 'Salaries',
    _ExpenseCategory.supplies => 'Supplies',
    _ExpenseCategory.marketing => 'Marketing',
    _ExpenseCategory.refreshments => 'Refreshments',
    _ExpenseCategory.insurance => 'Insurance',
    _ExpenseCategory.utilities => 'Utilities',
    _ExpenseCategory.other => 'Other',
  };

  IconData get icon => switch (this) {
    _ExpenseCategory.rent => Icons.home_work_outlined,
    _ExpenseCategory.maintenance => Icons.build_outlined,
    _ExpenseCategory.salaries => Icons.badge_outlined,
    _ExpenseCategory.supplies => Icons.inventory_2_outlined,
    _ExpenseCategory.marketing => Icons.campaign_outlined,
    _ExpenseCategory.refreshments => Icons.local_cafe_outlined,
    _ExpenseCategory.insurance => Icons.shield_outlined,
    _ExpenseCategory.utilities => Icons.bolt_outlined,
    _ExpenseCategory.other => Icons.more_horiz_rounded,
  };

  Color get color => switch (this) {
    _ExpenseCategory.rent => const Color(0xFF2C7969),
    _ExpenseCategory.maintenance => const Color(0xFFE0922A),
    _ExpenseCategory.salaries => const Color(0xFF3B82F6),
    _ExpenseCategory.supplies => const Color(0xFF8B5CF6),
    _ExpenseCategory.marketing => const Color(0xFFE5407A),
    _ExpenseCategory.refreshments => const Color(0xFFEAB308),
    _ExpenseCategory.insurance => const Color(0xFF14B8A6),
    _ExpenseCategory.utilities => const Color(0xFFEF4444),
    _ExpenseCategory.other => const Color(0xFF6B7280),
  };
}

enum _PaymentMethod { cash, bank, card, wallet }

extension on _PaymentMethod {
  String get label => switch (this) {
    _PaymentMethod.cash => 'Cash',
    _PaymentMethod.bank => 'Bank',
    _PaymentMethod.card => 'Card',
    _PaymentMethod.wallet => 'Wallet',
  };
}

class _Venue {
  final String id;
  final String name;
  const _Venue(this.id, this.name);
}

class _Expense {
  final String id;
  final DateTime date;
  final _ExpenseCategory category;
  final String vendor;
  final int amount;
  final String venueId;
  final _PaymentMethod method;
  final String? note;
  const _Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.vendor,
    required this.amount,
    required this.venueId,
    required this.method,
    this.note,
  });
}

// ─────────────────────────────────────────────
//  DEMO DATA + ANALYTICS
// ─────────────────────────────────────────────

class _DemoData {
  _DemoData._(this.venues, this.expenses);
  final List<_Venue> venues;
  final List<_Expense> expenses;

  static _DemoData generate() {
    const venues = <_Venue>[
      _Venue('f1', 'Green Turf Arena'),
      _Venue('f2', 'Capital Futsal'),
      _Venue('f3', 'Champions Court'),
    ];

    const vendorsByCat = <_ExpenseCategory, List<String>>{
      _ExpenseCategory.rent: ['Landlord — Mr. Sharma', 'Property Holdings'],
      _ExpenseCategory.maintenance: [
        'Turf Repair Co.',
        'Net & Posts Pvt.',
        'Floodlight Services',
      ],
      _ExpenseCategory.salaries: ['Staff Payroll', 'Court Manager', 'Cleaner'],
      _ExpenseCategory.supplies: [
        'Sports Hub',
        'Equipment Plus',
        'Cleaning Mart',
      ],
      _ExpenseCategory.marketing: [
        'Facebook Ads',
        'Local Print Press',
        'Influencer Promo',
      ],
      _ExpenseCategory.refreshments: ['Beverage Co.', 'Snack Supplier'],
      _ExpenseCategory.insurance: ['NIC Insurance', 'Premier Insure'],
      _ExpenseCategory.utilities: ['NEA — Electricity', 'KUKL — Water'],
      _ExpenseCategory.other: ['Miscellaneous', 'Bank Fees'],
    };

    final rng = math.Random(7);
    final now = DateTime.now();
    final start = DateTime(now.year - 1, now.month, now.day);

    final expenses = <_Expense>[];
    int id = 0;
    // Walk every day across the past year and emit 0–3 expenses.
    var day = start;
    while (!day.isAfter(now)) {
      final n = rng.nextInt(4); // 0..3
      for (int k = 0; k < n; k++) {
        final cat = _ExpenseCategory
            .values[rng.nextInt(_ExpenseCategory.values.length)];
        final vendors = vendorsByCat[cat]!;
        final venue = venues[rng.nextInt(venues.length)];

        // Amount tier by category for realism.
        final amount = switch (cat) {
          _ExpenseCategory.rent => 28000 + rng.nextInt(8000),
          _ExpenseCategory.salaries => 12000 + rng.nextInt(15000),
          _ExpenseCategory.utilities => 3500 + rng.nextInt(6500),
          _ExpenseCategory.insurance => 4500 + rng.nextInt(5500),
          _ExpenseCategory.marketing => 1500 + rng.nextInt(8500),
          _ExpenseCategory.maintenance => 1800 + rng.nextInt(11000),
          _ExpenseCategory.supplies => 800 + rng.nextInt(4500),
          _ExpenseCategory.refreshments => 350 + rng.nextInt(2200),
          _ExpenseCategory.other => 250 + rng.nextInt(3500),
        };

        // Rent and salaries tend to land on day 1 or 28.
        DateTime when = day;
        if (cat == _ExpenseCategory.rent && day.day != 1) continue;
        if (cat == _ExpenseCategory.salaries && day.day != 28) continue;
        when = DateTime(
          day.year,
          day.month,
          day.day,
          8 + rng.nextInt(12),
          rng.nextInt(60),
        );

        expenses.add(
          _Expense(
            id: 'e${id++}',
            date: when,
            category: cat,
            vendor: vendors[rng.nextInt(vendors.length)],
            amount: amount,
            venueId: venue.id,
            method: _PaymentMethod
                .values[rng.nextInt(_PaymentMethod.values.length)],
          ),
        );
      }
      day = day.add(const Duration(days: 1));
    }

    // Make sure recurring monthly costs always exist for the current month.
    for (final v in venues) {
      expenses.add(
        _Expense(
          id: 'e${id++}',
          date: DateTime(now.year, now.month, 1, 9, 30),
          category: _ExpenseCategory.rent,
          vendor: 'Landlord — Mr. Sharma',
          amount: 32000,
          venueId: v.id,
          method: _PaymentMethod.bank,
          note: 'Monthly rent',
        ),
      );
    }

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return _DemoData._(venues, expenses);
  }
}

class _Range {
  final DateTime start;
  final DateTime end; // exclusive
  const _Range(this.start, this.end);
  Duration get span => end.difference(start);
  int get days => span.inDays.clamp(1, 400);
  _Range get previous => _Range(start.subtract(span), start);
}

class _Bucket {
  final String label;
  final int value;
  const _Bucket(this.label, this.value);
}

class _Analytics {
  _Analytics({
    required this.data,
    required this.period,
    required this.range,
    required this.venueFilter,
    required this.categoryFilter,
  });

  final _DemoData data;
  final _Period period;
  final _Range range;
  final String? venueFilter;
  final _ExpenseCategory? categoryFilter;

  late final List<_Expense> _scoped = data.expenses.where((e) {
    if (venueFilter != null && e.venueId != venueFilter) return false;
    if (categoryFilter != null && e.category != categoryFilter) return false;
    return !e.date.isBefore(range.start) && e.date.isBefore(range.end);
  }).toList();

  late final List<_Expense> _scopedPrev = data.expenses.where((e) {
    if (venueFilter != null && e.venueId != venueFilter) return false;
    if (categoryFilter != null && e.category != categoryFilter) return false;
    final p = range.previous;
    return !e.date.isBefore(p.start) && e.date.isBefore(p.end);
  }).toList();

  // All aggregates are cached (`late final`) so each one is computed at most
  // once per build, regardless of how many widgets read them.
  late final int total = _scoped.fold(0, (a, e) => a + e.amount);
  late final int prevTotal = _scopedPrev.fold(0, (a, e) => a + e.amount);
  int get count => _scoped.length;

  int get avgPerDay {
    if (range.days == 0) return 0;
    return (total / range.days).round();
  }

  int get avgPerEntry => count == 0 ? 0 : (total / count).round();

  late final Map<_ExpenseCategory, int> byCategory = _scoped.fold(
    <_ExpenseCategory, int>{},
    (m, e) =>
        m..update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount),
  );

  late final Map<String, int> byVenue = _scoped.fold(
    <String, int>{},
    (m, e) =>
        m..update(e.venueId, (v) => v + e.amount, ifAbsent: () => e.amount),
  );

  late final _ExpenseCategory? largestCategory = byCategory.isEmpty
      ? null
      : byCategory.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  late final String? largestVenueId = byVenue.isEmpty
      ? null
      : byVenue.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  /// Bucketed series for the trend chart.
  late final List<_Bucket> series = _buildSeries();

  List<_Bucket> _buildSeries() {
    switch (period) {
      case _Period.year:
        return _monthlyBuckets();
      case _Period.month:
      case _Period.week:
        return _dailyBuckets();
      case _Period.custom:
        return range.days > 60 ? _monthlyBuckets() : _dailyBuckets();
    }
  }

  List<_Bucket> _dailyBuckets() {
    final out = List<int>.filled(range.days, 0);
    for (final e in _scoped) {
      final idx = DateTime(
        e.date.year,
        e.date.month,
        e.date.day,
      ).difference(range.start).inDays;
      if (idx >= 0 && idx < out.length) out[idx] += e.amount;
    }
    final firstLabel = _shortDate(range.start);
    final lastLabel = _shortDate(range.end.subtract(const Duration(days: 1)));
    final result = <_Bucket>[];
    for (int i = 0; i < out.length; i++) {
      final d = range.start.add(Duration(days: i));
      result.add(
        _Bucket(
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

  List<_Bucket> _monthlyBuckets() {
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
    for (final e in _scoped) {
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
        _Bucket(monthLabels[months[i].month - 1], values[i]),
    ];
  }
}

String _shortDate(DateTime d) {
  const m = [
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
  return '${m[d.month - 1]} ${d.day}';
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late final _DemoData _data;
  late final TabController _tabController;
  _Period _period = _Period.month;
  String? _venueId;
  _ExpenseCategory? _categoryFilter;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _data = _DemoData.generate();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _Range _resolvedRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case _Period.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return _Range(start, start.add(const Duration(days: 7)));
      case _Period.month:
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 1);
        return _Range(start, end);
      case _Period.year:
        final start = DateTime(today.year, 1, 1);
        final end = DateTime(today.year + 1, 1, 1);
        return _Range(start, end);
      case _Period.custom:
        final r = _customRange;
        if (r == null) {
          final start = today.subtract(const Duration(days: 13));
          return _Range(start, today.add(const Duration(days: 1)));
        }
        return _Range(
          DateTime(r.start.year, r.start.month, r.start.day),
          DateTime(
            r.end.year,
            r.end.month,
            r.end.day,
          ).add(const Duration(days: 1)),
        );
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          _customRange ??
          DateTimeRange(
            start: today.subtract(const Duration(days: 13)),
            end: today,
          ),
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: LightColor.secondaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _period = _Period.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = _resolvedRange();
    final analytics = _Analytics(
      data: _data,
      period: _period,
      range: range,
      venueFilter: _venueId,
      categoryFilter: _categoryFilter,
    );

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Expenses'),
      floatingActionButton: SizedBox(
        height: 45,
        child: FloatingActionButton.extended(
          onPressed: _openCreate,
          backgroundColor: LightColor.secondaryColor,
          foregroundColor: LightColor.whiteColor,
          elevation: 0,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(
            'New Expense',
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.whiteColor,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shared filters — pinned above the tabs so they apply everywhere.
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX20,
                top: AppDimens.paddingX4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SubtitleLine(
                    range: range,
                    count: analytics.count,
                    total: analytics.total,
                  ),
                  const SizedBox(height: AppDimens.paddingX12),
                  _PeriodChips(
                    period: _period,
                    customRange: _customRange,
                    onPeriod: (p) {
                      if (p == _Period.custom) {
                        _pickRange();
                      } else {
                        setState(() => _period = p);
                      }
                    },
                    onEditCustom: _pickRange,
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  _VenueFilter(
                    venues: _data.venues,
                    selectedId: _venueId,
                    onChange: (id) => setState(() => _venueId = id),
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  // Category filter is shared — it scopes every tab
                  // (totals, KPIs, charts and records) consistently.
                  _CategoryFilterRow(
                    selected: _categoryFilter,
                    onChange: (c) => setState(() => _categoryFilter = c),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX8),
            TabBar(
              controller: _tabController,
              labelColor: LightColor.secondaryColor,
              unselectedLabelColor: LightColor.secondaryTextColor,
              indicatorColor: LightColor.secondaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: LightColor.dividerColor,
              labelStyle: FutsalTheme.getTextTheme(
                context,
              ).bodyTextSmall?.copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: FutsalTheme.getTextTheme(
                context,
              ).bodyTextSmall?.copyWith(fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Overview', height: 40),
                Tab(text: 'Analytics', height: 40),
                Tab(text: 'Records', height: 40),
              ],
            ),
            // Breathing room between the tab bar and tab content.
            const SizedBox(height: AppDimens.paddingX12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(analytics: analytics, venues: _data.venues),
                  _AnalyticsTab(
                    analytics: analytics,
                    selectedCategory: _categoryFilter,
                    onSelectCategory: (c) =>
                        setState(() => _categoryFilter = c),
                  ),
                  _RecordsTab(
                    expenses: analytics._scoped,
                    venues: _data.venues,
                    categoryFilter: _categoryFilter,
                    hasFilters: _categoryFilter != null || _venueId != null,
                    onTap: _showExpenseDetails,
                    onAdd: _openCreate,
                    onClearFilters: () => setState(() {
                      _categoryFilter = null;
                      _venueId = null;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<_Expense>(
      MaterialPageRoute<_Expense>(
        builder: (_) => _CreateExpensePage(venues: _data.venues),
      ),
    );
    if (created == null || !mounted) return;
    setState(() {
      _data.expenses.insert(0, created);
      _data.expenses.sort((a, b) => b.date.compareTo(a.date));
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Expense added · ${_Fmt.npr(created.amount)}',
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.whiteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: LightColor.secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          margin: const EdgeInsets.all(AppDimens.paddingX16),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _showExpenseDetails(_Expense expense) async {
    final venueName = _data.venues
        .firstWhere(
          (v) => v.id == expense.venueId,
          orElse: () => const _Venue('?', '—'),
        )
        .name;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: LightColor.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX20),
        ),
      ),
      builder: (_) =>
          _ExpenseDetailsSheet(expense: expense, venueName: venueName),
    );
    if (action == _ExpenseDetailsSheet.deleteAction && mounted) {
      _deleteExpense(expense);
    }
  }

  void _deleteExpense(_Expense expense) {
    final index = _data.expenses.indexOf(expense);
    if (index < 0) return;
    setState(() => _data.expenses.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Expense deleted · ${_Fmt.npr(expense.amount)}',
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.whiteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: LightColor.redColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          margin: const EdgeInsets.all(AppDimens.paddingX16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            textColor: LightColor.whiteColor,
            onPressed: () {
              if (!mounted) return;
              setState(() => _data.expenses.insert(index, expense));
            },
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────
//  TABS
// ─────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.analytics, required this.venues});
  final _Analytics analytics;
  final List<_Venue> venues;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('expenses_overview'),
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        top: AppDimens.paddingX4,
        bottom: AppDimens.paddingX50 + AppDimens.paddingX20,
      ),
      children: [
        _SectionLabel('Total spend'),
        _HeroCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        _SectionLabel('Snapshot'),
        _KpiGrid(analytics: analytics, venues: venues),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({
    required this.analytics,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  final _Analytics analytics;
  final _ExpenseCategory? selectedCategory;
  final ValueChanged<_ExpenseCategory?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('expenses_analytics'),
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        top: AppDimens.paddingX4,
        bottom: AppDimens.paddingX50 + AppDimens.paddingX20,
      ),
      children: [
        _SectionLabel('Trend'),
        _TrendCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        _SectionLabel('By category'),
        _CategoryCard(
          analytics: analytics,
          selectedCategory: selectedCategory,
          onSelect: onSelectCategory,
        ),
      ],
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({
    required this.expenses,
    required this.venues,
    required this.categoryFilter,
    required this.hasFilters,
    required this.onTap,
    required this.onAdd,
    required this.onClearFilters,
  });

  final List<_Expense> expenses;
  final List<_Venue> venues;
  final _ExpenseCategory? categoryFilter;
  final bool hasFilters;
  final ValueChanged<_Expense> onTap;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('expenses_records'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX20,
            top: AppDimens.paddingX4,
          ),
          sliver: SliverToBoxAdapter(
            child: _SectionLabel(
              categoryFilter == null
                  ? 'Records'
                  : 'Records · ${categoryFilter!.label}',
            ),
          ),
        ),
        // Records are grouped per day and built lazily — only the
        // day-cards near the viewport are instantiated.
        _RecordsSliver(
          expenses: expenses,
          venues: venues,
          hasFilters: hasFilters,
          onTap: onTap,
          onAdd: onAdd,
          onClearFilters: onClearFilters,
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimens.paddingX50 + AppDimens.paddingX20),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  HEADER + FILTERS
// ─────────────────────────────────────────────

class _SubtitleLine extends StatelessWidget {
  const _SubtitleLine({
    required this.range,
    required this.count,
    required this.total,
  });

  final _Range range;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final last = range.end.subtract(const Duration(days: 1));
    final sameDay = range.days == 1;
    final label = sameDay
        ? _shortDate(range.start)
        : '${_shortDate(range.start)} – ${_shortDate(last)}';
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX4),
      child: Text(
        '$label · $count entries · ${_Fmt.npr(total)}',
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({
    required this.period,
    required this.customRange,
    required this.onPeriod,
    required this.onEditCustom,
  });

  final _Period period;
  final DateTimeRange? customRange;
  final ValueChanged<_Period> onPeriod;
  final VoidCallback onEditCustom;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.paddingX8,
      runSpacing: AppDimens.paddingX8,
      children: _Period.values.map((p) {
        final label = p == _Period.custom && customRange != null
            ? '${customRange!.duration.inDays + 1}d'
            : p.label;
        return _Chip(
          label: label,
          selected: period == p,
          icon: p == _Period.custom ? Icons.date_range_outlined : null,
          onTap: () {
            if (p == _Period.custom && period == _Period.custom) {
              onEditCustom();
            } else {
              onPeriod(p);
            }
          },
        );
      }).toList(),
    );
  }
}

class _VenueFilter extends StatelessWidget {
  const _VenueFilter({
    required this.venues,
    required this.selectedId,
    required this.onChange,
  });

  final List<_Venue> venues;
  final String? selectedId;
  final ValueChanged<String?> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: venues.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _Chip(
              label: 'All venues',
              selected: selectedId == null,
              onTap: () => onChange(null),
            );
          }
          final v = venues[i - 1];
          return _Chip(
            label: v.name,
            selected: selectedId == v.id,
            onTap: () => onChange(v.id),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 12,
                  color: selected
                      ? LightColor.whiteColor
                      : LightColor.secondaryTextColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: selected
                      ? LightColor.whiteColor
                      : LightColor.secondaryTextColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HERO
// ─────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final delta = analytics.total - analytics.prevTotal;
    final pct = analytics.prevTotal == 0
        ? null
        : (delta / analytics.prevTotal) * 100;
    // For expenses, up = bad, down = good.
    final up = delta > 0;

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.redColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: LightColor.redColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Text(
                'Total expenses',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (pct != null) _TrendPill(value: pct, badIfUp: true, up: up),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          // Count-up animation; re-animates from the previous total whenever
          // the filtered total changes.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: analytics.total.toDouble()),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              _Fmt.npr(value.round()),
              style: textTheme.bodyTextLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: LightColor.primaryTextColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'vs ${_Fmt.npr(analytics.prevTotal)} previous period',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          SizedBox(
            height: 56,
            child: RepaintBoundary(
              child: SfSparkAreaChart(
                data: analytics.series
                    .map((b) => b.value)
                    .toList(growable: false),
                color: LightColor.redColor.withValues(alpha: 0.12),
                borderColor: LightColor.redColor,
                borderWidth: 2,
                axisLineWidth: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({
    required this.value,
    required this.up,
    this.badIfUp = false,
  });

  final double value;
  final bool up;
  final bool badIfUp;

  @override
  Widget build(BuildContext context) {
    final bad = badIfUp ? up : !up;
    final color = bad ? LightColor.redColor : LightColor.secondaryColor;
    final bg = bad
        ? LightColor.redLightColor
        : LightColor.secondaryColor.withValues(alpha: 0.10);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${value.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  KPI GRID
// ─────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.analytics, required this.venues});
  final _Analytics analytics;
  final List<_Venue> venues;

  @override
  Widget build(BuildContext context) {
    final largestCat = analytics.largestCategory;
    final largestVenueId = analytics.largestVenueId;
    final largestVenue = largestVenueId == null
        ? null
        : venues.firstWhere(
            (v) => v.id == largestVenueId,
            orElse: () => const _Venue('?', '—'),
          );

    final items = <_Kpi>[
      _Kpi(
        icon: Icons.functions_rounded,
        label: 'Avg / day',
        value: _Fmt.npr(analytics.avgPerDay),
        sub: '${analytics.range.days} days in range',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.format_list_numbered_rounded,
        label: 'Entries',
        value: '${analytics.count}',
        sub: 'Avg ${_Fmt.npr(analytics.avgPerEntry)} / entry',
        accent: LightColor.blueColor,
      ),
      _Kpi(
        icon: largestCat?.icon ?? Icons.category_outlined,
        label: 'Top category',
        value: largestCat?.label ?? '—',
        sub: largestCat == null
            ? 'No expenses yet'
            : _Fmt.npr(analytics.byCategory[largestCat] ?? 0),
        accent: largestCat?.color ?? LightColor.iconGrey,
      ),
      _Kpi(
        icon: Icons.stadium_outlined,
        label: 'Top venue',
        value: largestVenue?.name ?? '—',
        sub: largestVenueId == null
            ? 'No expenses yet'
            : _Fmt.npr(analytics.byVenue[largestVenueId] ?? 0),
        accent: LightColor.warningColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        const spacing = AppDimens.paddingX10;
        final w = (c.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((k) => SizedBox(width: w, child: k)).toList(),
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _Surface(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontSize: AppDimens.fontBodySubTitle,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TREND CHART
// ─────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final buckets = analytics.series;
    final values = buckets.map((b) => b.value).toList(growable: false);
    final maxV = values.fold<int>(0, math.max);
    final avg = buckets.isEmpty
        ? 0
        : (buckets.fold<int>(0, (a, b) => a + b.value) / buckets.length)
              .round();

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                analytics.period == _Period.year
                    ? 'Monthly spend'
                    : 'Daily spend',
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const Spacer(),
              Text(
                'Avg ${_Fmt.npr(avg)}',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX14),
          SizedBox(
            height: 170,
            // Key on the data so the grow-in animation restarts whenever the
            // period/filter changes the series.
            child: RepaintBoundary(
              child: SfCartesianChart(
                key: ValueKey(Object.hashAll(values)),
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  arrangeByIndex: true,
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: const TextStyle(
                    color: LightColor.hintTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                  // Thin out labels on dense daily series; show all months.
                  interval: buckets.length > 12
                      ? (buckets.length / 4).ceilToDouble()
                      : 1,
                  labelIntersectAction: AxisLabelIntersectAction.hide,
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  maximum: maxV == 0 ? 1 : null,
                ),
                tooltipBehavior: _tooltip(),
                series: [
                  ColumnSeries<_Bucket, String>(
                    dataSource: buckets,
                    xValueMapper: (b, _) => b.label,
                    yValueMapper: (b, _) => b.value,
                    color: LightColor.secondaryColor,
                    width: 0.7,
                    isTrackVisible: true,
                    trackColor: LightColor.dividerColor.withValues(alpha: 0.4),
                    trackBorderWidth: 0,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    animationDuration: 700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TooltipBehavior _tooltip() {
    return TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        final b = data as _Bucket;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX6,
          ),
          decoration: BoxDecoration(
            color: LightColor.primaryTextColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          child: Text(
            '${b.label} · ${_Fmt.npr(b.value)}',
            style: const TextStyle(
              color: LightColor.whiteColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  CATEGORIES
// ─────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.analytics,
    required this.selectedCategory,
    required this.onSelect,
  });

  final _Analytics analytics;
  final _ExpenseCategory? selectedCategory;
  final ValueChanged<_ExpenseCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final m = analytics.byCategory;
    final entries = m.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (a, b) => a + b.value);

    if (entries.isEmpty) {
      return const _EmptyState(
        title: 'Nothing to break down',
        message: 'No expenses recorded for this range.',
      );
    }

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                // Key on the data so the sweep-in animation restarts whenever
                // the breakdown changes.
                child: RepaintBoundary(
                  child: SfCircularChart(
                    key: ValueKey(
                      Object.hashAll(
                        entries.map((e) => Object.hash(e.key, e.value)),
                      ),
                    ),
                    margin: EdgeInsets.zero,
                    tooltipBehavior: _donutTooltip(total),
                    annotations: [
                      CircularChartAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${entries.length}',
                              style: textTheme.bodyTextLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: LightColor.primaryTextColor,
                              ),
                            ),
                            Text(
                              'cats',
                              style: textTheme.bodyTextSmall?.copyWith(
                                fontSize: AppDimens.fontBodySubTitle,
                                color: LightColor.hintTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    series: [
                      DoughnutSeries<MapEntry<_ExpenseCategory, int>, String>(
                        dataSource: entries,
                        xValueMapper: (e, _) => e.key.label,
                        yValueMapper: (e, _) => e.value,
                        pointColorMapper: (e, _) => e.key.color,
                        innerRadius: '74%',
                        radius: '100%',
                        animationDuration: 700,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.paddingX14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in entries.take(4))
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimens.paddingX6,
                        ),
                        child: _LegendDot(
                          color: e.key.color,
                          label: e.key.label,
                          value: _Fmt.npr(e.value),
                          pct: total == 0 ? 0 : e.value / total,
                        ),
                      ),
                    if (entries.length > 4)
                      Text(
                        '+ ${entries.length - 4} more',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          const Divider(
            height: 1,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
          const SizedBox(height: AppDimens.paddingX10),
          for (final e in entries)
            _CategoryRow(
              category: e.key,
              amount: e.value,
              fraction: total == 0 ? 0 : e.value / total,
              isSelected: selectedCategory == e.key,
              onTap: () => onSelect(selectedCategory == e.key ? null : e.key),
            ),
        ],
      ),
    );
  }

  TooltipBehavior _donutTooltip(int total) {
    return TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        final e = data as MapEntry<_ExpenseCategory, int>;
        final pct = total == 0 ? 0 : (e.value / total * 100).round();
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX6,
          ),
          decoration: BoxDecoration(
            color: LightColor.primaryTextColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          child: Text(
            '${e.key.label} · ${_Fmt.npr(e.value)} ($pct%)',
            style: const TextStyle(
              color: LightColor.whiteColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.value,
    required this.pct,
  });

  final Color color;
  final String label;
  final String value;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDimens.paddingX6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${(pct * 100).toStringAsFixed(0)}%',
          style: textTheme.bodyTextSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: LightColor.primaryTextColor,
            fontSize: AppDimens.fontBodySubTitle,
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.fraction,
    required this.isSelected,
    required this.onTap,
  });

  final _ExpenseCategory category;
  final int amount;
  final double fraction;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(category.icon, color: category.color, size: 16),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category.label,
                          style: textTheme.bodyTextSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _Fmt.npr(amount),
                          style: textTheme.bodyTextSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        height: 5,
                        color: LightColor.dividerColor.withValues(alpha: 0.5),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: fraction.clamp(0.0, 1.0),
                          child: Container(color: category.color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: AppDimens.paddingX8),
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: category.color,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RECORDS
// ─────────────────────────────────────────────

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({required this.selected, required this.onChange});
  final _ExpenseCategory? selected;
  final ValueChanged<_ExpenseCategory?> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _ExpenseCategory.values.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _Chip(
              label: 'All',
              selected: selected == null,
              onTap: () => onChange(null),
            );
          }
          final c = _ExpenseCategory.values[i - 1];
          return _Chip(
            label: c.label,
            selected: selected == c,
            onTap: () => onChange(selected == c ? null : c),
          );
        },
      ),
    );
  }
}

class _RecordsSliver extends StatelessWidget {
  const _RecordsSliver({
    required this.expenses,
    required this.venues,
    required this.hasFilters,
    required this.onTap,
    required this.onAdd,
    required this.onClearFilters,
  });

  final List<_Expense> expenses;
  final List<_Venue> venues;
  final bool hasFilters;
  final ValueChanged<_Expense> onTap;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX20),
        sliver: SliverToBoxAdapter(
          child: _EmptyState(
            title: hasFilters ? 'No matching records' : 'No records yet',
            message: hasFilters
                ? 'Try a different period, venue or category.'
                : 'Expenses you add will show up here.',
            actionLabel: hasFilters ? 'Clear filters' : 'Add expense',
            onAction: hasFilters ? onClearFilters : onAdd,
          ),
        ),
      );
    }

    final byDay = <DateTime, List<_Expense>>{};
    for (final e in expenses) {
      final k = DateTime(e.date.year, e.date.month, e.date.day);
      byDay.putIfAbsent(k, () => []).add(e);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX20),
      sliver: SliverList.separated(
        itemCount: days.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimens.paddingX10),
        itemBuilder: (_, i) => _DayGroupCard(
          date: days[i],
          expenses: byDay[days[i]]!,
          venues: venues,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _DayGroupCard extends StatelessWidget {
  const _DayGroupCard({
    required this.date,
    required this.expenses,
    required this.venues,
    required this.onTap,
  });

  final DateTime date;
  final List<_Expense> expenses;
  final List<_Venue> venues;
  final ValueChanged<_Expense> onTap;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX4),
      child: Column(
        children: [
          _DateHeader(date: date, expenses: expenses),
          for (final e in expenses)
            _ExpenseTile(
              expense: e,
              venueName: venues
                  .firstWhere(
                    (v) => v.id == e.venueId,
                    orElse: () => const _Venue('?', '—'),
                  )
                  .name,
              onTap: () => onTap(e),
            ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date, required this.expenses});
  final DateTime date;
  final List<_Expense> expenses;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final sum = expenses.fold<int>(0, (a, e) => a + e.amount);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Day-difference comparison handles month/year boundaries correctly.
    final diff = today.difference(date).inDays;
    final isToday = diff == 0;
    final isYesterday = diff == 1;
    final label = isToday
        ? 'Today'
        : isYesterday
        ? 'Yesterday'
        : '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';

    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX14,
        symmetricVertical: AppDimens.paddingX10,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
          const Spacer(),
          Text(
            _Fmt.npr(sum),
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.venueName,
    required this.onTap,
  });
  final _Expense expense;
  final String venueName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX14,
          symmetricVertical: AppDimens.paddingX10,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: expense.category.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              child: Icon(
                expense.category.icon,
                color: expense.category.color,
                size: 18,
              ),
            ),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.vendor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        expense.category.label,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: expense.category.color,
                          fontWeight: FontWeight.w600,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                      const _Sep(),
                      Flexible(
                        child: Text(
                          venueName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                      ),
                      const _Sep(),
                      Text(
                        expense.method.label,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingX10),
            Text(
              '- ${_Fmt.npr(expense.amount)}',
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: LightColor.redColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: TextStyle(
          color: LightColor.hintTextColor,
          fontSize: AppDimens.fontBodySubTitle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EXPENSE DETAILS SHEET
// ─────────────────────────────────────────────

class _ExpenseDetailsSheet extends StatelessWidget {
  const _ExpenseDetailsSheet({required this.expense, required this.venueName});

  static const deleteAction = 'delete';

  final _Expense expense;
  final String venueName;

  String get _dateLabel {
    final d = expense.date;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${_shortDate(d)}, ${d.year} · ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final category = expense.category;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.paddingX20,
          AppDimens.paddingX12,
          AppDimens.paddingX20,
          AppDimens.paddingX20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  ),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const SizedBox(width: AppDimens.paddingX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.vendor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: LightColor.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.label,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX10),
                Text(
                  '- ${_Fmt.npr(expense.amount)}',
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LightColor.redColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX14),
            const Divider(height: 1, color: LightColor.dividerColor),
            const SizedBox(height: AppDimens.paddingX6),
            _DetailRow(label: 'Date', value: _dateLabel),
            _DetailRow(label: 'Venue', value: venueName),
            _DetailRow(label: 'Paid via', value: expense.method.label),
            if (expense.note != null)
              _DetailRow(label: 'Note', value: expense.note!),
            const SizedBox(height: AppDimens.paddingX16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(deleteAction),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: LightColor.redColor,
                  side: BorderSide(
                    color: LightColor.redColor.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.paddingX12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  ),
                ),
                label: Text(
                  'Delete expense',
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColor.redColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyTextSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateExpensePage extends StatefulWidget {
  const _CreateExpensePage({required this.venues});
  final List<_Venue> venues;

  @override
  State<_CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<_CreateExpensePage> {
  final _amountCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _amountFocus = FocusNode();

  _ExpenseCategory? _category;
  late _Venue _venue = widget.venues.first;
  DateTime _date = DateTime.now();
  _PaymentMethod _method = _PaymentMethod.cash;
  bool _submitted = false;

  static const _presets = [500, 1000, 2500, 5000, 10000];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _vendorCtrl.dispose();
    _noteCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  int? get _amountInt {
    final raw = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  bool get _canSave =>
      (_amountInt ?? 0) > 0 &&
      _category != null &&
      _vendorCtrl.text.trim().isNotEmpty;

  void _setAmount(int value) {
    final text = _Fmt.group('$value');
    _amountCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 2),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: LightColor.secondaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    setState(() => _submitted = true);
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    final amount = _amountInt!;
    final vendor = _vendorCtrl.text.trim();
    final note = _noteCtrl.text.trim();
    final expense = _Expense(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      date: _date,
      category: _category!,
      vendor: vendor,
      amount: amount,
      venueId: _venue.id,
      method: _method,
      note: note.isEmpty ? null : note,
    );
    Navigator.of(context).pop(expense);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: 'New expense',
        actions: [
          // Rebuilds only this button while typing — not the whole form.
          ListenableBuilder(
            listenable: Listenable.merge([_amountCtrl, _vendorCtrl]),
            builder: (context, _) => TextButton(
              onPressed: _canSave ? _save : null,
              child: Text(
                'Save',
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _canSave
                      ? LightColor.secondaryColor
                      : LightColor.disabledTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX20,
            top: AppDimens.paddingX4,
            bottom: AppDimens.paddingX28,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppDimens.paddingX4),
              child: Text(
                'Log a new operating cost for your venues.',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Amount'),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _amountCtrl,
              builder: (context, _, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AmountCard(
                    controller: _amountCtrl,
                    focusNode: _amountFocus,
                    showError: _submitted && (_amountInt ?? 0) <= 0,
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  // One-tap presets for common amounts.
                  Wrap(
                    spacing: AppDimens.paddingX8,
                    runSpacing: AppDimens.paddingX8,
                    children: _presets
                        .map(
                          (p) => _Chip(
                            label: _Fmt.group('$p'),
                            selected: _amountInt == p,
                            onTap: () => _setAmount(p),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Category'),
            _Surface(
              child: CustomDropdownField<_ExpenseCategory>(
                labelText: 'Category',
                hintText: 'Select a category',
                icon: Icons.category_outlined,
                initialValue: _category,
                autovalidateMode: _submitted
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                validator: (v) => v == null ? 'Pick a category' : null,
                onChanged: (c) => setState(() => _category = c),
                items: _ExpenseCategory.values
                    .map(
                      (c) => DropdownMenuItem<_ExpenseCategory>(
                        value: c,
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusX6,
                                ),
                              ),
                              child: Icon(c.icon, size: 13, color: c.color),
                            ),
                            const SizedBox(width: AppDimens.paddingX8),
                            Text(c.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Details'),
            _Surface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX14,
                      AppDimens.paddingX14,
                      AppDimens.paddingX14,
                      AppDimens.paddingX10,
                    ),
                    child: CustomTextField(
                      controller: _vendorCtrl,
                      labelText: 'Purpose',
                      hintText: 'e.g. Turf repair, monthly rent',
                      icon: Icons.assignment_outlined,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      isRequired: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX14,
                      0,
                      AppDimens.paddingX14,
                      AppDimens.paddingX10,
                    ),
                    child: CustomDropdownField<_Venue>(
                      labelText: 'Venue',
                      hintText: 'Select a venue',
                      icon: Icons.stadium_outlined,
                      initialValue: _venue,
                      onChanged: (v) {
                        if (v != null) setState(() => _venue = v);
                      },
                      items: widget.venues
                          .map(
                            (v) => DropdownMenuItem<_Venue>(
                              value: v,
                              child: Text(v.name),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const _RowDivider(),
                  _PickerRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: _formatDate(_date),
                    onTap: _pickDate,
                  ),
                  const _RowDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX14,
                      AppDimens.paddingX12,
                      AppDimens.paddingX14,
                      AppDimens.paddingX14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment method',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingX8),
                        Wrap(
                          spacing: AppDimens.paddingX8,
                          runSpacing: AppDimens.paddingX8,
                          children: _PaymentMethod.values
                              .map(
                                (m) => _Chip(
                                  label: m.label,
                                  selected: _method == m,
                                  onTap: () => setState(() => _method = m),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Note (optional)'),
            _Surface(
              child: CustomTextField(
                controller: _noteCtrl,
                labelText: 'Note',
                hintText: 'Add a remark, invoice ref, etc.',
                icon: Icons.notes_rounded,
                maxLines: 3,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                isRequired: false,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX24),

            ListenableBuilder(
              listenable: Listenable.merge([_amountCtrl, _vendorCtrl]),
              builder: (context, _) => CustomButton(
                text: _canSave
                    ? 'Save expense · ${_Fmt.npr(_amountInt ?? 0)}'
                    : 'Save expense',
                icon: Icons.save_outlined,
                onPressed: _canSave ? _save : null,
                minHeight: AppDimens.sizeX54,
                borderRadius: AppDimens.radiusX14,
                fontSize: AppDimens.fontBodyTextMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
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
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today, ${months[d.month - 1]} ${d.day}';
    }
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.controller,
    required this.focusNode,
    required this.showError,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX14,
          vertical: AppDimens.paddingX20,
        ),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          border: Border.all(
            color: showError
                ? LightColor.redColor.withValues(alpha: 0.5)
                : LightColor.dividerColor,
          ),
          boxShadow: const [
            BoxShadow(
              color: LightColor.shadowColor,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'NPR',
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandsInputFormatter()],
                    textAlign: TextAlign.start,
                    cursorColor: LightColor.secondaryColor,
                    style: textTheme.bodyTextLarge?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: textTheme.bodyTextLarge?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: LightColor.disabledTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              showError
                  ? 'Enter an amount greater than 0'
                  : 'Tap to enter the expense amount',
              style: textTheme.bodyTextSmall?.copyWith(
                color: showError
                    ? LightColor.redColor
                    : LightColor.hintTextColor,
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX14,
          vertical: AppDimens.paddingX14,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: LightColor.secondaryTextColor),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingX8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: LightColor.hintTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
      child: Divider(height: 1, color: LightColor.dividerColor),
    );
  }
}

// ─────────────────────────────────────────────
//  PRIMITIVES
// ─────────────────────────────────────────────

class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.paddingX14),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX2,
        bottom: AppDimens.paddingX8,
      ),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _Surface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX20,
        vertical: AppDimens.paddingX24,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 22,
              color: LightColor.secondaryColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppDimens.paddingX14),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: LightColor.secondaryColor,
                side: const BorderSide(color: LightColor.secondaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX16,
                  vertical: AppDimens.paddingX8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
              ),
              child: Text(
                actionLabel!,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.secondaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Fmt {
  static String npr(int v) =>
      '${v < 0 ? '-' : ''}NPR ${group(v.abs().toString())}';

  /// Groups a digit-only string with thousands separators: 1234567 → 1,234,567.
  static String group(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}

/// Live thousands-separator formatting for the amount field (max 9 digits).
class _ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 9) digits = digits.substring(0, 9);
    if (digits.isEmpty) return TextEditingValue.empty;
    final text = _Fmt.group(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
