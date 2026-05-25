import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';

enum _Period { day, week, month, custom }

extension on _Period {
  String get label => switch (this) {
    _Period.day => 'Day',
    _Period.week => 'Week',
    _Period.month => 'Month',
    _Period.custom => 'Custom',
  };
}

enum _BookingStatus { completed, confirmed, pending, cancelled }

extension on _BookingStatus {
  String get label => switch (this) {
    _BookingStatus.completed => 'Completed',
    _BookingStatus.confirmed => 'Confirmed',
    _BookingStatus.pending => 'Pending',
    _BookingStatus.cancelled => 'Cancelled',
  };

  Color get color => switch (this) {
    _BookingStatus.completed => LightColor.secondaryColor,
    _BookingStatus.confirmed => LightColor.blueColor,
    _BookingStatus.pending => LightColor.warningColor,
    _BookingStatus.cancelled => LightColor.redColor,
  };
}

class _Futsal {
  final String id;
  final String name;
  final String area;
  final int monthlyOverhead;
  final List<_Court> courts;
  const _Futsal({
    required this.id,
    required this.name,
    required this.area,
    required this.monthlyOverhead,
    required this.courts,
  });
}

class _Court {
  final String id;
  final String futsalId;
  final String name;
  final int hourlyRate;
  const _Court({
    required this.id,
    required this.futsalId,
    required this.name,
    required this.hourlyRate,
  });
}

class _BookingRecord {
  final String id;
  final String futsalId;
  final String courtId;
  final DateTime start;
  final int hours;
  final int amount;
  final _BookingStatus status;
  final String customer;
  const _BookingRecord({
    required this.id,
    required this.futsalId,
    required this.courtId,
    required this.start,
    required this.hours,
    required this.amount,
    required this.status,
    required this.customer,
  });
}

// ─────────────────────────────────────────────
//  DEMO DATA + ANALYTICS
// ─────────────────────────────────────────────

class _DemoData {
  _DemoData._(this.futsals, this.bookings);

  final List<_Futsal> futsals;
  final List<_BookingRecord> bookings;

  static _DemoData generate() {
    const futsals = <_Futsal>[
      _Futsal(
        id: 'f1',
        name: 'Green Turf Arena',
        area: 'Kathmandu',
        monthlyOverhead: 95000,
        courts: [
          _Court(id: 'c1', futsalId: 'f1', name: 'Court A', hourlyRate: 1200),
          _Court(id: 'c2', futsalId: 'f1', name: 'Court B', hourlyRate: 1500),
          _Court(id: 'c3', futsalId: 'f1', name: 'Court C', hourlyRate: 1800),
        ],
      ),
      _Futsal(
        id: 'f2',
        name: 'Capital Futsal',
        area: 'Lalitpur',
        monthlyOverhead: 72000,
        courts: [
          _Court(id: 'c4', futsalId: 'f2', name: 'Court 1', hourlyRate: 1100),
          _Court(id: 'c5', futsalId: 'f2', name: 'Court 2', hourlyRate: 1400),
        ],
      ),
      _Futsal(
        id: 'f3',
        name: 'Champions Court',
        area: 'Bhaktapur',
        monthlyOverhead: 58000,
        courts: [
          _Court(id: 'c6', futsalId: 'f3', name: 'Pitch 1', hourlyRate: 1000),
          _Court(id: 'c7', futsalId: 'f3', name: 'Pitch 2', hourlyRate: 1300),
          _Court(id: 'c8', futsalId: 'f3', name: 'Pitch 3', hourlyRate: 1300),
        ],
      ),
    ];

    final allCourts = <_Court>[for (final f in futsals) ...f.courts];

    const customers = <String>[
      'Aayush Karki',
      'Niraj Shrestha',
      'Samir Tamang',
      'Rohit Rai',
      'Bishal Maharjan',
      'Sunil Lama',
      'Bibek Thapa',
      'Pradeep Adhikari',
      'Kushal Gurung',
      'Rajan Pun',
      'Anil Khatri',
      'Dipesh Bista',
      'Suman KC',
      'Sandip Magar',
      'Yogesh Joshi',
    ];

    final rng = math.Random(42);
    final today = DateTime.now();
    final from = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 89));

    final bookings = <_BookingRecord>[];
    int id = 0;

    for (int day = 0; day < 90; day++) {
      final date = from.add(Duration(days: day));
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.friday;
      final slotsToday = isWeekend ? rng.nextInt(8) + 8 : rng.nextInt(6) + 3;

      for (int i = 0; i < slotsToday; i++) {
        final court = allCourts[rng.nextInt(allCourts.length)];
        final hour = 6 + rng.nextInt(16); // 6 AM – 10 PM
        final hours = rng.nextDouble() < 0.75 ? 1 : 2;
        final start = DateTime(date.year, date.month, date.day, hour);

        final roll = rng.nextDouble();
        final _BookingStatus status;
        if (start.isAfter(today)) {
          status = roll < 0.6
              ? _BookingStatus.confirmed
              : (roll < 0.85
                    ? _BookingStatus.pending
                    : _BookingStatus.cancelled);
        } else {
          status = roll < 0.62
              ? _BookingStatus.completed
              : roll < 0.78
              ? _BookingStatus.confirmed
              : roll < 0.86
              ? _BookingStatus.pending
              : _BookingStatus.cancelled;
        }

        bookings.add(
          _BookingRecord(
            id: 'b${id++}',
            futsalId: court.futsalId,
            courtId: court.id,
            start: start,
            hours: hours,
            amount: court.hourlyRate * hours,
            status: status,
            customer: customers[rng.nextInt(customers.length)],
          ),
        );
      }
    }

    return _DemoData._(futsals, bookings);
  }
}

class _Range {
  final DateTime start; // inclusive (00:00)
  final DateTime end; // exclusive (00:00 of next day)
  const _Range(this.start, this.end);

  Duration get span => end.difference(start);
  int get days => span.inDays.clamp(1, 366);

  _Range get previous {
    final s = span;
    return _Range(start.subtract(s), start);
  }
}

class _Analytics {
  _Analytics({
    required this.data,
    required this.period,
    required this.range,
    required this.futsalFilter, // null = all
  });

  final _DemoData data;
  final _Period period;
  final _Range range;
  final String? futsalFilter;

  late final List<_BookingRecord> _scoped = data.bookings.where((b) {
    if (futsalFilter != null && b.futsalId != futsalFilter) return false;
    return !b.start.isBefore(range.start) && b.start.isBefore(range.end);
  }).toList();

  late final List<_BookingRecord> _scopedPrev = data.bookings.where((b) {
    if (futsalFilter != null && b.futsalId != futsalFilter) return false;
    return !b.start.isBefore(range.previous.start) &&
        b.start.isBefore(range.previous.end);
  }).toList();

  bool _isRevenue(_BookingStatus s) =>
      s == _BookingStatus.completed || s == _BookingStatus.confirmed;

  int _revenueOf(List<_BookingRecord> xs) =>
      xs.where((b) => _isRevenue(b.status)).fold(0, (a, b) => a + b.amount);

  int get revenue => _revenueOf(_scoped);
  int get prevRevenue => _revenueOf(_scopedPrev);

  int get expenses {
    // Pro-rate monthly overheads + 8% variable per booking.
    final futsals = futsalFilter == null
        ? data.futsals
        : data.futsals.where((f) => f.id == futsalFilter);
    final overhead = futsals.fold<int>(0, (a, f) => a + f.monthlyOverhead);
    final prorated = (overhead * range.days / 30).round();
    final variable = (revenue * 0.08).round();
    return prorated + variable;
  }

  int get profit => revenue - expenses;

  int get totalBookings => _scoped.length;
  int get cancelled =>
      _scoped.where((b) => b.status == _BookingStatus.cancelled).length;
  int get completed =>
      _scoped.where((b) => b.status == _BookingStatus.completed).length;
  int get confirmed =>
      _scoped.where((b) => b.status == _BookingStatus.confirmed).length;
  int get pending =>
      _scoped.where((b) => b.status == _BookingStatus.pending).length;

  double get cancelRate => totalBookings == 0 ? 0 : cancelled / totalBookings;

  int get hoursPlayed =>
      _scoped.where((b) => _isRevenue(b.status)).fold(0, (a, b) => a + b.hours);

  double get occupancy {
    // 16 open hours/day × courts in scope × days
    final futsals = futsalFilter == null
        ? data.futsals
        : data.futsals.where((f) => f.id == futsalFilter);
    final courtCount = futsals.fold<int>(0, (a, f) => a + f.courts.length);
    final capacity = courtCount * 16 * range.days;
    if (capacity == 0) return 0;
    return (hoursPlayed / capacity).clamp(0.0, 1.0);
  }

  int get avgBookingValue {
    final paid = _scoped.where((b) => _isRevenue(b.status)).toList();
    if (paid.isEmpty) return 0;
    return (paid.fold(0, (a, b) => a + b.amount) / paid.length).round();
  }

  /// Daily revenue series for the chart (one bucket per day in range).
  List<int> get dailySeries {
    final out = List<int>.filled(range.days, 0);
    for (final b in _scoped) {
      if (!_isRevenue(b.status)) continue;
      final dayIdx = b.start.difference(range.start).inDays;
      if (dayIdx >= 0 && dayIdx < out.length) out[dayIdx] += b.amount;
    }
    return out;
  }

  Map<_BookingStatus, int> get statusBreakdown {
    final m = <_BookingStatus, int>{
      for (final s in _BookingStatus.values) s: 0,
    };
    for (final b in _scoped) {
      m[b.status] = (m[b.status] ?? 0) + 1;
    }
    return m;
  }

  List<_FutsalRow> get futsalLeaderboard {
    final out = <_FutsalRow>[];
    for (final f in data.futsals) {
      if (futsalFilter != null && f.id != futsalFilter) continue;
      final scoped = _scoped.where((b) => b.futsalId == f.id);
      final rev = scoped
          .where((b) => _isRevenue(b.status))
          .fold(0, (a, b) => a + b.amount);
      final book = scoped.length;
      final hours = scoped
          .where((b) => _isRevenue(b.status))
          .fold(0, (a, b) => a + b.hours);
      final capacity = f.courts.length * 16 * range.days;
      final util = capacity == 0 ? 0.0 : (hours / capacity).clamp(0.0, 1.0);
      out.add(
        _FutsalRow(futsal: f, revenue: rev, bookings: book, occupancy: util),
      );
    }
    out.sort((a, b) => b.revenue.compareTo(a.revenue));
    return out;
  }

  List<_CourtRow> get courtLeaderboard {
    final out = <_CourtRow>[];
    for (final f in data.futsals) {
      if (futsalFilter != null && f.id != futsalFilter) continue;
      for (final c in f.courts) {
        final scoped = _scoped.where((b) => b.courtId == c.id);
        final rev = scoped
            .where((b) => _isRevenue(b.status))
            .fold(0, (a, b) => a + b.amount);
        final book = scoped.length;
        out.add(
          _CourtRow(court: c, futsalName: f.name, revenue: rev, bookings: book),
        );
      }
    }
    out.sort((a, b) => b.revenue.compareTo(a.revenue));
    return out;
  }

  List<_CustomerRow> get topCustomers {
    final acc = <String, _CustomerRow>{};
    for (final b in _scoped) {
      if (!_isRevenue(b.status)) continue;
      final row = acc.putIfAbsent(
        b.customer,
        () => _CustomerRow(name: b.customer, bookings: 0, spent: 0),
      );
      acc[b.customer] = _CustomerRow(
        name: row.name,
        bookings: row.bookings + 1,
        spent: row.spent + b.amount,
      );
    }
    final out = acc.values.toList()..sort((a, b) => b.spent.compareTo(a.spent));
    return out.take(5).toList();
  }
}

class _FutsalRow {
  final _Futsal futsal;
  final int revenue;
  final int bookings;
  final double occupancy;
  const _FutsalRow({
    required this.futsal,
    required this.revenue,
    required this.bookings,
    required this.occupancy,
  });
}

class _CourtRow {
  final _Court court;
  final String futsalName;
  final int revenue;
  final int bookings;
  const _CourtRow({
    required this.court,
    required this.futsalName,
    required this.revenue,
    required this.bookings,
  });
}

class _CustomerRow {
  final String name;
  final int bookings;
  final int spent;
  const _CustomerRow({
    required this.name,
    required this.bookings,
    required this.spent,
  });
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late final _DemoData _data;
  _Period _period = _Period.month;
  String? _futsalId; // null = all
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _data = _DemoData.generate();
  }

  _Range _resolvedRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case _Period.day:
        return _Range(today, today.add(const Duration(days: 1)));
      case _Period.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return _Range(start, start.add(const Duration(days: 7)));
      case _Period.month:
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 1);
        return _Range(start, end);
      case _Period.custom:
        final r = _customRange;
        if (r == null) {
          final start = today.subtract(const Duration(days: 6));
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
            start: today.subtract(const Duration(days: 6)),
            end: today,
          ),
      firstDate: today.subtract(const Duration(days: 89)),
      lastDate: today.add(const Duration(days: 90)),
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
      futsalFilter: _futsalId,
    );

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Overview', showBack: true),
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
            _RangeHeader(
              range: range,
              period: _period,
              futsalCount: _data.futsals.length,
              courtCount: _data.futsals.fold<int>(
                0,
                (a, f) => a + f.courts.length,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
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
            const SizedBox(height: AppDimens.paddingX12),
            _VenueFilter(
              futsals: _data.futsals,
              selectedId: _futsalId,
              onChange: (id) => setState(() => _futsalId = id),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Net earnings'),
            _HeroEarningsCard(analytics: analytics),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Snapshot'),
            _KpiGrid(analytics: analytics),
            const SizedBox(height: AppDimens.paddingX12),
            _ProfitCard(analytics: analytics),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Revenue trend'),
            _RevenueTrendCard(analytics: analytics),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Booking statuses'),
            _StatusBreakdownCard(analytics: analytics),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Performance by venue'),
            _VenuePerformanceCard(analytics: analytics),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Top courts'),
            _TopCourtsCard(analytics: analytics),
            const SizedBox(height: AppDimens.paddingX18),

            _SectionLabel('Top customers'),
            _TopCustomersCard(analytics: analytics),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HEADER + FILTERS
// ─────────────────────────────────────────────

class _RangeHeader extends StatelessWidget {
  const _RangeHeader({
    required this.range,
    required this.period,
    required this.futsalCount,
    required this.courtCount,
  });

  final _Range range;
  final _Period period;
  final int futsalCount;
  final int courtCount;

  static const _months = [
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

  String _fmt(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}${d.year != DateTime.now().year ? ', ${d.year}' : ''}';

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final endLabel = range.end.subtract(const Duration(days: 1));
    final sameDay = range.days == 1;
    final label = sameDay
        ? _fmt(range.start)
        : '${_fmt(range.start)} – ${_fmt(endLabel)}';
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX4),
      child: Text(
        '$label · $futsalCount venues · $courtCount courts',
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
      children: _Period.values
          .map(
            (p) => _Chip(
              label: p == _Period.custom && customRange != null
                  ? '${customRange!.duration.inDays + 1}d'
                  : p.label,
              selected: period == p,
              icon: p == _Period.custom ? Icons.date_range_outlined : null,
              onTap: () {
                if (p == _Period.custom && period == _Period.custom) {
                  onEditCustom();
                } else {
                  onPeriod(p);
                }
              },
            ),
          )
          .toList(),
    );
  }
}

class _VenueFilter extends StatelessWidget {
  const _VenueFilter({
    required this.futsals,
    required this.selectedId,
    required this.onChange,
  });

  final List<_Futsal> futsals;
  final String? selectedId;
  final ValueChanged<String?> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: futsals.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _Chip(
              label: 'All venues',
              selected: selectedId == null,
              onTap: () => onChange(null),
            );
          }
          final f = futsals[i - 1];
          return _Chip(
            label: f.name,
            selected: selectedId == f.id,
            onTap: () => onChange(f.id),
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
        onTap: onTap,
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
//  HERO + KPI
// ─────────────────────────────────────────────

class _HeroEarningsCard extends StatelessWidget {
  const _HeroEarningsCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final delta = analytics.revenue - analytics.prevRevenue;
    final pct = analytics.prevRevenue == 0
        ? null
        : (delta / analytics.prevRevenue) * 100;
    final up = delta >= 0;
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
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Text(
                'Net revenue',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (pct != null) _TrendPill(value: pct, up: up),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            _Fmt.npr(analytics.revenue),
            style: textTheme.bodyTextLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'vs ${_Fmt.npr(analytics.prevRevenue)} previous period',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          SizedBox(
            height: 56,
            child: CustomPaint(
              size: Size.infinite,
              painter: _SparklinePainter(
                values: analytics.dailySeries,
                color: LightColor.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.value, required this.up});
  final double value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final color = up ? LightColor.secondaryColor : LightColor.redColor;
    final bg = up
        ? LightColor.secondaryColor.withValues(alpha: 0.10)
        : LightColor.redLightColor;
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

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});
  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.fold<int>(0, math.max);
    if (maxV == 0) return;
    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final path = Path();
    final fill = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - (values[i] / maxV) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final items = <_Kpi>[
      _Kpi(
        icon: Icons.calendar_month_rounded,
        label: 'Total bookings',
        value: '${analytics.totalBookings}',
        sub: '${analytics.confirmed + analytics.completed} paid',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.cancel_outlined,
        label: 'Cancelled',
        value: '${analytics.cancelled}',
        sub: '${(analytics.cancelRate * 100).toStringAsFixed(1)}% of bookings',
        accent: LightColor.redColor,
      ),
      _Kpi(
        icon: Icons.payments_outlined,
        label: 'Revenue',
        value: _Fmt.npr(analytics.revenue),
        sub: 'Avg ${_Fmt.npr(analytics.avgBookingValue)} / booking',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.receipt_long_outlined,
        label: 'Expenses',
        value: _Fmt.npr(analytics.expenses),
        sub: 'Overheads + processing',
        accent: LightColor.warningColor,
      ),
      _Kpi(
        icon: Icons.timer_outlined,
        label: 'Hours played',
        value: '${analytics.hoursPlayed}h',
        sub: 'Across all paid slots',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.stadium_outlined,
        label: 'Occupancy',
        value: '${(analytics.occupancy * 100).round()}%',
        sub: 'Of available court hours',
        accent: LightColor.secondaryColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppDimens.paddingX10;
        final w = (constraints.maxWidth - spacing) / 2;
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

class _ProfitCard extends StatelessWidget {
  const _ProfitCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final profitable = analytics.profit >= 0;
    final margin = analytics.revenue == 0
        ? 0.0
        : analytics.profit / analytics.revenue;
    final color = profitable ? LightColor.secondaryColor : LightColor.redColor;

    return _Surface(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            ),
            child: Icon(
              profitable
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net profit',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _Fmt.npr(analytics.profit),
                  style: textTheme.bodyTextLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Margin',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(margin * 100).toStringAsFixed(1)}%',
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REVENUE TREND
// ─────────────────────────────────────────────

class _RevenueTrendCard extends StatelessWidget {
  const _RevenueTrendCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final values = analytics.dailySeries;
    final maxV = values.fold<int>(0, math.max);
    final avg = values.isEmpty
        ? 0
        : (values.reduce((a, b) => a + b) / values.length).round();

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Daily revenue',
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
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarChartPainter(
                values: values,
                color: LightColor.secondaryColor,
                trackColor: LightColor.dividerColor,
                maxV: maxV == 0 ? 1 : maxV,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Row(
            children: [
              Text(
                _shortDate(analytics.range.start),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              const Spacer(),
              Text(
                _shortDate(
                  analytics.range.end.subtract(const Duration(days: 1)),
                ),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortDate(DateTime d) {
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
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.color,
    required this.trackColor,
    required this.maxV,
  });

  final List<int> values;
  final Color color;
  final Color trackColor;
  final int maxV;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final n = values.length;
    final gap = n > 31 ? 1.0 : 2.0;
    final barW = (size.width - gap * (n - 1)) / n;
    final radius = math.min(barW / 2, 4.0);

    final trackPaint = Paint()..color = trackColor.withValues(alpha: 0.4);
    final barPaint = Paint()..color = color;

    for (int i = 0; i < n; i++) {
      final x = i * (barW + gap);
      // Track (full height)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, barW, size.height),
          Radius.circular(radius),
        ),
        trackPaint,
      );
      // Filled portion
      final h = (values[i] / maxV) * size.height;
      if (h > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - h, barW, h),
            Radius.circular(radius),
          ),
          barPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.values != values || old.maxV != maxV || old.color != color;
}

// ─────────────────────────────────────────────
//  STATUS BREAKDOWN
// ─────────────────────────────────────────────

class _StatusBreakdownCard extends StatelessWidget {
  const _StatusBreakdownCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final breakdown = analytics.statusBreakdown;
    final total = breakdown.values.fold<int>(0, (a, b) => a + b);

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Status mix',
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const Spacer(),
              Text(
                '$total bookings',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? Container(color: LightColor.dividerColor)
                  : Row(
                      children: _BookingStatus.values
                          .map(
                            (s) => Expanded(
                              flex: breakdown[s] ?? 0,
                              child: Container(color: s.color),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          ..._BookingStatus.values.map((s) {
            final n = breakdown[s] ?? 0;
            final pct = total == 0 ? 0.0 : n / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.paddingX8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX8),
                  Expanded(
                    child: Text(
                      s.label,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '$n  ·  ${(pct * 100).toStringAsFixed(1)}%',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  VENUE / COURT / CUSTOMER TABLES
// ─────────────────────────────────────────────

class _VenuePerformanceCard extends StatelessWidget {
  const _VenuePerformanceCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final rows = analytics.futsalLeaderboard;
    if (rows.isEmpty) return const _EmptyMicro(text: 'No venue activity.');

    return _Surface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _VenueRow(row: rows[i]),
            if (i < rows.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
                child: Divider(height: 1, color: LightColor.dividerColor),
              ),
          ],
        ],
      ),
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.row});
  final _FutsalRow row;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX14,
        symmetricVertical: AppDimens.paddingX12,
      ),
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
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.stadium_outlined,
                  color: LightColor.secondaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.futsal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    Text(
                      '${row.futsal.area} · ${row.futsal.courts.length} courts · ${row.bookings} bookings',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _Fmt.npr(row.revenue),
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: LightColor.primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Row(
            children: [
              Expanded(
                child: _MiniBar(
                  fraction: row.occupancy,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Text(
                '${(row.occupancy * 100).round()}%',
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w700,
                  color: LightColor.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 6,
        color: LightColor.dividerColor.withValues(alpha: 0.5),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      ),
    );
  }
}

class _TopCourtsCard extends StatelessWidget {
  const _TopCourtsCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final rows = analytics.courtLeaderboard.take(5).toList();
    if (rows.isEmpty) return const _EmptyMicro(text: 'No court activity.');

    final maxV = rows.first.revenue.clamp(1, 1 << 30);
    final textTheme = FutsalTheme.getTextTheme(context);

    return _Surface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX14,
                symmetricVertical: AppDimens.paddingX12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LightColor.background,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                      border: Border.all(color: LightColor.dividerColor),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.secondaryTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].court.name,
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        Text(
                          '${rows[i].futsalName} · ${rows[i].bookings} bookings',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _MiniBar(
                          fraction: rows[i].revenue / maxV,
                          color: LightColor.secondaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Text(
                    _Fmt.npr(rows[i].revenue),
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
                child: Divider(height: 1, color: LightColor.dividerColor),
              ),
          ],
        ],
      ),
    );
  }
}

class _TopCustomersCard extends StatelessWidget {
  const _TopCustomersCard({required this.analytics});
  final _Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final rows = analytics.topCustomers;
    if (rows.isEmpty) return const _EmptyMicro(text: 'No customer activity.');

    final textTheme = FutsalTheme.getTextTheme(context);

    return _Surface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX14,
                symmetricVertical: AppDimens.paddingX12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                    ),
                    child: Text(
                      _initials(rows[i].name),
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LightColor.secondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].name,
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        Text(
                          '${rows[i].bookings} bookings',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _Fmt.npr(rows[i].spent),
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
                child: Divider(height: 1, color: LightColor.dividerColor),
              ),
          ],
        ],
      ),
    );
  }

  String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
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

class _EmptyMicro extends StatelessWidget {
  const _EmptyMicro({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX10),
          child: Text(
            text,
            style: FutsalTheme.getTextTheme(
              context,
            ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
          ),
        ),
      ),
    );
  }
}

class _Fmt {
  static String npr(int v) {
    final neg = v < 0;
    final s = v.abs().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${neg ? '-' : ''}NPR ${buf.toString()}';
  }
}
