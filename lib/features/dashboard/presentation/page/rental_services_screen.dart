import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────

enum _Tab { equipment, active, history }

extension on _Tab {
  String get label => switch (this) {
    _Tab.equipment => 'Equipment',
    _Tab.active => 'Active',
    _Tab.history => 'History',
  };
}

enum _EquipKind {
  football,
  bib,
  gloves,
  cones,
  shinGuards,
  boots,
  bottle,
  towel,
  tacticBoard,
}

extension on _EquipKind {
  String get defaultName => switch (this) {
    _EquipKind.football => 'Football',
    _EquipKind.bib => 'Training bibs',
    _EquipKind.gloves => 'Goalkeeper gloves',
    _EquipKind.cones => 'Cones (set of 10)',
    _EquipKind.shinGuards => 'Shin guards',
    _EquipKind.boots => 'Futsal boots',
    _EquipKind.bottle => 'Water bottle',
    _EquipKind.towel => 'Towel',
    _EquipKind.tacticBoard => 'Tactic board',
  };

  String get label => switch (this) {
    _EquipKind.football => 'Football',
    _EquipKind.bib => 'Bibs',
    _EquipKind.gloves => 'Gloves',
    _EquipKind.cones => 'Cones',
    _EquipKind.shinGuards => 'Shin guards',
    _EquipKind.boots => 'Boots',
    _EquipKind.bottle => 'Bottle',
    _EquipKind.towel => 'Towel',
    _EquipKind.tacticBoard => 'Tactic board',
  };

  IconData get icon => switch (this) {
    _EquipKind.football => Icons.sports_soccer_rounded,
    _EquipKind.bib => Icons.checkroom_rounded,
    _EquipKind.gloves => Icons.back_hand_outlined,
    _EquipKind.cones => Icons.change_history_rounded,
    _EquipKind.shinGuards => Icons.shield_outlined,
    _EquipKind.boots => Icons.directions_run_rounded,
    _EquipKind.bottle => Icons.water_drop_outlined,
    _EquipKind.towel => Icons.dry_cleaning_outlined,
    _EquipKind.tacticBoard => Icons.dashboard_rounded,
  };

  Color get color => switch (this) {
    _EquipKind.football => const Color(0xFF2C7969),
    _EquipKind.bib => const Color(0xFF3B82F6),
    _EquipKind.gloves => const Color(0xFFE5407A),
    _EquipKind.cones => const Color(0xFFE0922A),
    _EquipKind.shinGuards => const Color(0xFF8B5CF6),
    _EquipKind.boots => const Color(0xFF14B8A6),
    _EquipKind.bottle => const Color(0xFF6366F1),
    _EquipKind.towel => const Color(0xFFEF4444),
    _EquipKind.tacticBoard => const Color(0xFF0EA5E9),
  };
}

class _Equipment {
  final String id;
  final _EquipKind kind;
  final String name;
  final int totalUnits;
  final int hourlyRate;
  final int deposit;

  _Equipment({
    required this.id,
    required this.kind,
    required this.name,
    required this.totalUnits,
    required this.hourlyRate,
    required this.deposit,
  });
}

enum _RentalStatus { active, overdue, returned, cancelled }

extension on _RentalStatus {
  String get label => switch (this) {
    _RentalStatus.active => 'Active',
    _RentalStatus.overdue => 'Overdue',
    _RentalStatus.returned => 'Returned',
    _RentalStatus.cancelled => 'Cancelled',
  };
}

class _Rental {
  final String id;
  final String equipmentId;
  final int qty;
  final String customer;
  final String phone;
  final DateTime startedAt;
  final DateTime dueAt;
  DateTime? returnedAt;
  final int totalAmount;
  final int depositAmount;
  _RentalStatus status;

  _Rental({
    required this.id,
    required this.equipmentId,
    required this.qty,
    required this.customer,
    required this.phone,
    required this.startedAt,
    required this.dueAt,
    this.returnedAt,
    required this.totalAmount,
    required this.depositAmount,
    required this.status,
  });
}

// ─────────────────────────────────────────────
//  STATE / DEMO
// ─────────────────────────────────────────────

class _Repo {
  _Repo._(this.equipment, this.rentals);
  final List<_Equipment> equipment;
  final List<_Rental> rentals;

  static _Repo seed() {
    final equipment = <_Equipment>[
      _Equipment(
        id: 'eq1',
        kind: _EquipKind.football,
        name: 'Football · size 5',
        totalUnits: 12,
        hourlyRate: 100,
        deposit: 500,
      ),
      _Equipment(
        id: 'eq2',
        kind: _EquipKind.bib,
        name: 'Training bibs (set of 10)',
        totalUnits: 6,
        hourlyRate: 80,
        deposit: 400,
      ),
      _Equipment(
        id: 'eq3',
        kind: _EquipKind.gloves,
        name: 'Goalkeeper gloves',
        totalUnits: 5,
        hourlyRate: 120,
        deposit: 600,
      ),
      _Equipment(
        id: 'eq4',
        kind: _EquipKind.cones,
        name: 'Training cones (10)',
        totalUnits: 4,
        hourlyRate: 60,
        deposit: 300,
      ),
      _Equipment(
        id: 'eq5',
        kind: _EquipKind.shinGuards,
        name: 'Shin guards',
        totalUnits: 10,
        hourlyRate: 50,
        deposit: 250,
      ),
      _Equipment(
        id: 'eq6',
        kind: _EquipKind.boots,
        name: 'Futsal boots',
        totalUnits: 8,
        hourlyRate: 150,
        deposit: 800,
      ),
      _Equipment(
        id: 'eq7',
        kind: _EquipKind.bottle,
        name: 'Water bottle',
        totalUnits: 20,
        hourlyRate: 20,
        deposit: 100,
      ),
      _Equipment(
        id: 'eq8',
        kind: _EquipKind.towel,
        name: 'Towel',
        totalUnits: 15,
        hourlyRate: 25,
        deposit: 100,
      ),
    ];

    const customers = <(String, String)>[
      ('Aayush Karki', '98410-12233'),
      ('Niraj Shrestha', '98411-44556'),
      ('Samir Tamang', '98412-22118'),
      ('Rohit Rai', '98413-99001'),
      ('Bishal Maharjan', '98414-78890'),
      ('Sunil Lama', '98415-30210'),
      ('Pradeep Adhikari', '98416-45987'),
    ];

    final rng = math.Random(11);
    final now = DateTime.now();
    final rentals = <_Rental>[];
    int id = 0;

    // Active / overdue right now
    for (int i = 0; i < 5; i++) {
      final eq = equipment[rng.nextInt(equipment.length)];
      final qty = 1 + rng.nextInt(3);
      final started = now.subtract(
        Duration(minutes: 15 + rng.nextInt(60 * 2)),
      );
      final dueIn = -30 + rng.nextInt(120); // some overdue
      final dueAt = now.add(Duration(minutes: dueIn));
      final hours = math
          .max(1, dueAt.difference(started).inMinutes / 60)
          .ceil();
      final amount = eq.hourlyRate * qty * hours;
      final customer = customers[rng.nextInt(customers.length)];
      rentals.add(_Rental(
        id: 'r${id++}',
        equipmentId: eq.id,
        qty: qty,
        customer: customer.$1,
        phone: customer.$2,
        startedAt: started,
        dueAt: dueAt,
        totalAmount: amount,
        depositAmount: eq.deposit * qty,
        status:
            dueAt.isBefore(now) ? _RentalStatus.overdue : _RentalStatus.active,
      ));
    }

    // Past returned over last 14 days
    for (int d = 1; d <= 14; d++) {
      final perDay = rng.nextInt(3);
      for (int i = 0; i < perDay; i++) {
        final day = now.subtract(Duration(days: d));
        final eq = equipment[rng.nextInt(equipment.length)];
        final qty = 1 + rng.nextInt(3);
        final started = DateTime(day.year, day.month, day.day,
            8 + rng.nextInt(12), rng.nextInt(60));
        final hours = 1 + rng.nextInt(3);
        final dueAt = started.add(Duration(hours: hours));
        final returnedAt = dueAt.add(
          Duration(minutes: rng.nextBool() ? -10 : 15),
        );
        final amount = eq.hourlyRate * qty * hours;
        final customer = customers[rng.nextInt(customers.length)];
        rentals.add(_Rental(
          id: 'r${id++}',
          equipmentId: eq.id,
          qty: qty,
          customer: customer.$1,
          phone: customer.$2,
          startedAt: started,
          dueAt: dueAt,
          returnedAt: returnedAt,
          totalAmount: amount,
          depositAmount: eq.deposit * qty,
          status: _RentalStatus.returned,
        ));
      }
    }
    rentals.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return _Repo._(equipment, rentals);
  }

  int activeQtyFor(String equipId) {
    int q = 0;
    for (final r in rentals) {
      if (r.equipmentId == equipId &&
          (r.status == _RentalStatus.active ||
              r.status == _RentalStatus.overdue)) {
        q += r.qty;
      }
    }
    return q;
  }

  _Equipment? equipmentById(String id) {
    for (final e in equipment) {
      if (e.id == id) return e;
    }
    return null;
  }
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class RentalServicesScreen extends StatefulWidget {
  const RentalServicesScreen({super.key});

  @override
  State<RentalServicesScreen> createState() => _RentalServicesScreenState();
}

class _RentalServicesScreenState extends State<RentalServicesScreen> {
  late final _Repo _repo;
  _Tab _tab = _Tab.equipment;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _repo = _Repo.seed();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      // Re-check overdue statuses periodically.
      final now = DateTime.now();
      bool changed = false;
      for (final r in _repo.rentals) {
        if (r.status == _RentalStatus.active && r.dueAt.isBefore(now)) {
          r.status = _RentalStatus.overdue;
          changed = true;
        }
      }
      if (changed && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _onRentCount => _repo.rentals
      .where((r) =>
          r.status == _RentalStatus.active ||
          r.status == _RentalStatus.overdue)
      .fold(0, (a, r) => a + r.qty);

  int get _availableCount {
    int total = 0;
    for (final e in _repo.equipment) {
      total += e.totalUnits - _repo.activeQtyFor(e.id);
    }
    return math.max(0, total);
  }

  int get _todaysEarnings {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    int sum = 0;
    for (final r in _repo.rentals) {
      if (r.startedAt.isBefore(start)) continue;
      if (r.status == _RentalStatus.cancelled) continue;
      sum += r.totalAmount;
    }
    return sum;
  }

  int _tabCount(_Tab t) => switch (t) {
    _Tab.equipment => _repo.equipment.length,
    _Tab.active => _repo.rentals
        .where((r) =>
            r.status == _RentalStatus.active ||
            r.status == _RentalStatus.overdue)
        .length,
    _Tab.history => _repo.rentals
        .where((r) =>
            r.status == _RentalStatus.returned ||
            r.status == _RentalStatus.cancelled)
        .length,
  };

  Future<void> _openAddEquipment() async {
    final created = await Navigator.of(context).push<_Equipment>(
      MaterialPageRoute<_Equipment>(
        builder: (_) => const _AddEquipmentPage(),
      ),
    );
    if (!mounted || created == null) return;
    setState(() => _repo.equipment.add(created));
    _toast('Equipment added · ${created.name}');
  }

  Future<void> _openNewRental() async {
    if (_repo.equipment.isEmpty) {
      _toast('Add equipment first');
      return;
    }
    final created = await Navigator.of(context).push<_Rental>(
      MaterialPageRoute<_Rental>(
        builder: (_) => _NewRentalPage(repo: _repo),
      ),
    );
    if (!mounted || created == null) return;
    setState(() {
      _repo.rentals.insert(0, created);
      _tab = _Tab.active;
    });
    _toast('Rental started for ${created.customer}');
  }

  void _returnRental(_Rental r) {
    setState(() {
      r.status = _RentalStatus.returned;
      r.returnedAt = DateTime.now();
    });
    _toast('Marked returned · ${r.customer}');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            msg,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Rental Services'),
      floatingActionButton: _tab == _Tab.history
          ? null
          : FloatingActionButton.extended(
              onPressed:
                  _tab == _Tab.equipment ? _openAddEquipment : _openNewRental,
              backgroundColor: LightColor.secondaryColor,
              foregroundColor: LightColor.whiteColor,
              elevation: 2,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                _tab == _Tab.equipment ? 'Add equipment' : 'New rental',
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: LightColor.whiteColor,
                    ),
              ),
            ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimens.paddingX4),
            _SubtitleLine(
              available: _availableCount,
              onRent: _onRentCount,
              earnings: _todaysEarnings,
            ),
            const SizedBox(height: AppDimens.paddingX12),
            _SegmentRow(
              selected: _tab,
              countFor: _tabCount,
              onChanged: (t) => setState(() => _tab = t),
            ),
            const SizedBox(height: AppDimens.paddingX10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                child: switch (_tab) {
                  _Tab.equipment => _EquipmentList(
                      key: const ValueKey('e'),
                      repo: _repo,
                    ),
                  _Tab.active => _RentalList(
                      key: const ValueKey('a'),
                      repo: _repo,
                      onlyOpen: true,
                      onReturn: _returnRental,
                    ),
                  _Tab.history => _RentalList(
                      key: const ValueKey('h'),
                      repo: _repo,
                      onlyOpen: false,
                      onReturn: _returnRental,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HEADER / SEGMENT
// ─────────────────────────────────────────────

class _SubtitleLine extends StatelessWidget {
  const _SubtitleLine({
    required this.available,
    required this.onRent,
    required this.earnings,
  });

  final int available;
  final int onRent;
  final int earnings;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX20),
      child: Row(
        children: [
          Expanded(
            child: _StatPill(
              label: 'Available',
              value: '$available',
              color: LightColor.secondaryColor,
              icon: Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: _StatPill(
              label: 'On rent',
              value: '$onRent',
              color: LightColor.warningColor,
              icon: Icons.outbox_rounded,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: _StatPill(
              label: 'Today',
              value: _Fmt.nprShort(earnings),
              color: LightColor.blueColor,
              icon: Icons.payments_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX10,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                Text(
                  label,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.selected,
    required this.countFor,
    required this.onChanged,
  });

  final _Tab selected;
  final int Function(_Tab) countFor;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX20),
        itemCount: _Tab.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (context, index) {
          final tab = _Tab.values[index];
          return _Chip(
            label: tab.label,
            count: countFor(tab),
            selected: tab == selected,
            onTap: () => onChanged(tab),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

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
              if (count > 0) ...[
                const SizedBox(width: AppDimens.paddingX6),
                Text(
                  '$count',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: selected
                        ? LightColor.whiteColor.withValues(alpha: 0.7)
                        : LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
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
//  EQUIPMENT LIST
// ─────────────────────────────────────────────

class _EquipmentList extends StatelessWidget {
  const _EquipmentList({super.key, required this.repo});
  final _Repo repo;

  @override
  Widget build(BuildContext context) {
    if (repo.equipment.isEmpty) {
      return const _Empty(
        icon: Icons.inventory_2_outlined,
        title: 'No equipment yet',
        body: 'Add items to start renting them out.',
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX20,
        AppDimens.paddingX4,
        AppDimens.paddingX20,
        AppDimens.paddingX50 + AppDimens.paddingX20,
      ),
      itemCount: repo.equipment.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.paddingX10),
      itemBuilder: (_, i) {
        final e = repo.equipment[i];
        final rented = repo.activeQtyFor(e.id);
        final available = math.max(0, e.totalUnits - rented);
        final pct = e.totalUnits == 0 ? 0.0 : rented / e.totalUnits;
        return _EquipmentTile(
          equipment: e,
          available: available,
          rented: rented,
          utilisation: pct,
        );
      },
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({
    required this.equipment,
    required this.available,
    required this.rented,
    required this.utilisation,
  });

  final _Equipment equipment;
  final int available;
  final int rented;
  final double utilisation;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final color = equipment.kind.color;
    final outOfStock = available == 0;

    return Container(
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
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                ),
                child: Icon(equipment.kind.icon, color: color, size: 22),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${equipment.kind.label} · ${_Fmt.npr(equipment.hourlyRate)}/hr · Deposit ${_Fmt.npr(equipment.deposit)}',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: outOfStock
                      ? LightColor.redLightColor
                      : color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                ),
                child: Text(
                  outOfStock ? 'Out of stock' : '$available available',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: outOfStock ? LightColor.redColor : color,
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Row(
            children: [
              _MiniStat(label: 'Total', value: '${equipment.totalUnits}'),
              const SizedBox(width: AppDimens.paddingX16),
              _MiniStat(
                label: 'On rent',
                value: '$rented',
                accent: rented > 0 ? LightColor.warningColor : null,
              ),
              const SizedBox(width: AppDimens.paddingX16),
              _MiniStat(label: 'Available', value: '$available'),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: LightColor.dividerColor.withValues(alpha: 0.5),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: utilisation.clamp(0.0, 1.0),
                child: Container(color: color),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          Text(
            '${(utilisation * 100).round()}% of stock currently rented',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.bodyTextMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: accent ?? LightColor.primaryTextColor,
          ),
        ),
        Text(
          label,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.hintTextColor,
            fontSize: AppDimens.fontBodySubTitle,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  RENTAL LIST
// ─────────────────────────────────────────────

class _RentalList extends StatelessWidget {
  const _RentalList({
    super.key,
    required this.repo,
    required this.onlyOpen,
    required this.onReturn,
  });

  final _Repo repo;
  final bool onlyOpen;
  final ValueChanged<_Rental> onReturn;

  @override
  Widget build(BuildContext context) {
    final rentals = repo.rentals.where((r) {
      if (onlyOpen) {
        return r.status == _RentalStatus.active ||
            r.status == _RentalStatus.overdue;
      }
      return r.status == _RentalStatus.returned ||
          r.status == _RentalStatus.cancelled;
    }).toList();

    if (rentals.isEmpty) {
      return _Empty(
        icon: onlyOpen ? Icons.outbox_rounded : Icons.history_rounded,
        title: onlyOpen ? 'No active rentals' : 'No history yet',
        body: onlyOpen
            ? 'Start a new rental from the button below.'
            : 'Returned rentals will appear here.',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX20,
        AppDimens.paddingX4,
        AppDimens.paddingX20,
        AppDimens.paddingX50 + AppDimens.paddingX20,
      ),
      itemCount: rentals.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.paddingX10),
      itemBuilder: (_, i) {
        final r = rentals[i];
        return _RentalTile(
          rental: r,
          equipment: repo.equipmentById(r.equipmentId),
          onReturn: () => onReturn(r),
        );
      },
    );
  }
}

class _RentalTile extends StatefulWidget {
  const _RentalTile({
    required this.rental,
    required this.equipment,
    required this.onReturn,
  });

  final _Rental rental;
  final _Equipment? equipment;
  final VoidCallback onReturn;

  @override
  State<_RentalTile> createState() => _RentalTileState();
}

class _RentalTileState extends State<_RentalTile> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.rental.status == _RentalStatus.active ||
        widget.rental.status == _RentalStatus.overdue) {
      _ticker = Timer.periodic(
        const Duration(seconds: 30),
        (_) {
          if (mounted) setState(() {});
        },
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatRemaining(Duration d, {required bool overdue}) {
    final m = d.inMinutes.abs();
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final mm = m % 60;
    return mm == 0 ? '${h}h' : '${h}h ${mm}m';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final r = widget.rental;
    final eq = widget.equipment;
    final color = eq?.kind.color ?? LightColor.secondaryColor;
    final icon = eq?.kind.icon ?? Icons.inventory_2_outlined;
    final isOpen = r.status == _RentalStatus.active ||
        r.status == _RentalStatus.overdue;
    final overdue = r.status == _RentalStatus.overdue;
    final now = DateTime.now();
    final remaining = r.dueAt.difference(now);
    final settled = r.returnedAt != null;

    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(
          color: overdue
              ? LightColor.redColor.withValues(alpha: 0.30)
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
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX14,
        AppDimens.paddingX14,
        AppDimens.paddingX14,
        AppDimens.paddingX8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${eq?.name ?? 'Equipment'} · ×${r.qty}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${r.customer} · ${r.phone}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              _StatusBadge(status: r.status),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          if (isOpen)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX10,
                vertical: AppDimens.paddingX8,
              ),
              decoration: BoxDecoration(
                color: overdue
                    ? LightColor.redLightColor
                    : LightColor.secondaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              child: Row(
                children: [
                  Icon(
                    overdue
                        ? Icons.warning_amber_rounded
                        : Icons.timer_outlined,
                    size: 14,
                    color: overdue
                        ? LightColor.redColor
                        : LightColor.secondaryColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX6),
                  Text(
                    overdue ? 'Overdue by' : 'Returns in',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: overdue
                          ? LightColor.redColor
                          : LightColor.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimens.fontBodySubTitle,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatRemaining(remaining, overdue: overdue),
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: overdue
                          ? LightColor.redColor
                          : LightColor.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppDimens.paddingX10),
          Row(
            children: [
              _RentalMeta(
                icon: Icons.play_arrow_rounded,
                label: 'Started',
                value: _Fmt.timeAt(r.startedAt),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              _RentalMeta(
                icon: Icons.stop_circle_outlined,
                label: settled ? 'Returned' : 'Due',
                value: settled
                    ? _Fmt.timeAt(r.returnedAt!)
                    : _Fmt.timeAt(r.dueAt),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Row(
            children: [
              _RentalMeta(
                icon: Icons.payments_outlined,
                label: 'Charge',
                value: _Fmt.npr(r.totalAmount),
                emphasised: true,
              ),
              const SizedBox(width: AppDimens.paddingX10),
              _RentalMeta(
                icon: Icons.savings_outlined,
                label: 'Deposit',
                value: _Fmt.npr(r.depositAmount),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          const Divider(
            height: 1,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
          if (isOpen)
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.phone_outlined,
                    label: 'Call',
                    onTap: () {},
                  ),
                ),
                Container(
                  width: 1,
                  height: 18,
                  color: LightColor.dividerColor,
                ),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Mark returned',
                    emphasised: true,
                    onTap: widget.onReturn,
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    r.status == _RentalStatus.returned
                        ? Icons.check_circle_rounded
                        : Icons.cancel_outlined,
                    size: AppDimens.sizeX16,
                    color: LightColor.hintTextColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX6),
                  Text(
                    r.status == _RentalStatus.returned
                        ? 'Returned · ${_Fmt.timeAt(r.returnedAt ?? r.dueAt)}'
                        : 'Cancelled',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RentalMeta extends StatelessWidget {
  const _RentalMeta({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX10,
          vertical: AppDimens.paddingX8,
        ),
        decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          border: Border.all(color: LightColor.dividerColor),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: emphasised
                  ? LightColor.secondaryColor
                  : LightColor.secondaryTextColor,
            ),
            const SizedBox(width: AppDimens.paddingX6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: AppDimens.fontBodySubTitle,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: emphasised
                          ? LightColor.secondaryColor
                          : LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final _RentalStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (status) {
      _RentalStatus.active => (
          LightColor.secondaryColor,
          LightColor.secondaryColor.withValues(alpha: 0.10),
        ),
      _RentalStatus.overdue => (LightColor.redColor, LightColor.redLightColor),
      _RentalStatus.returned => (
          LightColor.hintTextColor,
          LightColor.dividerColor,
        ),
      _RentalStatus.cancelled => (
          LightColor.hintTextColor,
          LightColor.dividerColor,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        status.label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final color = emphasised
        ? LightColor.secondaryColor
        : LightColor.secondaryTextColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimens.sizeX16, color: color),
            const SizedBox(width: AppDimens.paddingX6),
            Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: color,
                fontWeight: emphasised ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY
// ─────────────────────────────────────────────

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: LightColor.secondaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              title,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ADD EQUIPMENT
// ─────────────────────────────────────────────

class _AddEquipmentPage extends StatefulWidget {
  const _AddEquipmentPage();

  @override
  State<_AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<_AddEquipmentPage> {
  final _nameCtrl = TextEditingController();
  final _unitsCtrl = TextEditingController(text: '5');
  final _rateCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();

  _EquipKind? _kind;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_nameCtrl, _unitsCtrl, _rateCtrl, _depositCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitsCtrl.dispose();
    _rateCtrl.dispose();
    _depositCtrl.dispose();
    super.dispose();
  }

  int? _asInt(TextEditingController c) {
    final raw = c.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  bool get _canSave =>
      _kind != null &&
      _nameCtrl.text.trim().isNotEmpty &&
      (_asInt(_unitsCtrl) ?? 0) > 0 &&
      (_asInt(_rateCtrl) ?? 0) > 0;

  void _save() {
    setState(() => _submitted = true);
    if (!_canSave) return;
    final eq = _Equipment(
      id: 'eq${DateTime.now().millisecondsSinceEpoch}',
      kind: _kind!,
      name: _nameCtrl.text.trim(),
      totalUnits: _asInt(_unitsCtrl)!,
      hourlyRate: _asInt(_rateCtrl)!,
      deposit: _asInt(_depositCtrl) ?? 0,
    );
    Navigator.of(context).pop(eq);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: 'Add equipment',
        actions: [
          TextButton(
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
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX20,
            AppDimens.paddingX4,
            AppDimens.paddingX20,
            AppDimens.paddingX28,
          ),
          children: [
            const SizedBox(height: AppDimens.paddingX4),
            Text(
              'Add a new item to your rental inventory.',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            const _SectionLabel('Item type'),
            _SurfaceCard(
              child: CustomDropdownField<_EquipKind>(
                labelText: 'Type',
                hintText: 'Select equipment type',
                icon: Icons.category_outlined,
                initialValue: _kind,
                autovalidateMode: _submitted
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                validator: (v) => v == null ? 'Pick a type' : null,
                onChanged: (v) {
                  setState(() {
                    _kind = v;
                    if (_nameCtrl.text.trim().isEmpty && v != null) {
                      _nameCtrl.text = v.defaultName;
                    }
                  });
                },
                items: _EquipKind.values
                    .map(
                      (k) => DropdownMenuItem<_EquipKind>(
                        value: k,
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: k.color.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusX6),
                              ),
                              child: Icon(k.icon, size: 13, color: k.color),
                            ),
                            const SizedBox(width: AppDimens.paddingX8),
                            Text(k.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            const _SectionLabel('Details'),
            _SurfaceCard(
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
                      controller: _nameCtrl,
                      labelText: 'Display name',
                      hintText: 'e.g. Football · size 5',
                      icon: Icons.label_outline_rounded,
                      textCapitalization: TextCapitalization.sentences,
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
                    child: CustomTextField(
                      controller: _unitsCtrl,
                      labelText: 'Total units',
                      hintText: 'Total quantity in stock',
                      icon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
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
                    child: CustomTextField(
                      controller: _rateCtrl,
                      labelText: 'Hourly rate (NPR)',
                      hintText: 'Charge per unit per hour',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      isRequired: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX14,
                      0,
                      AppDimens.paddingX14,
                      AppDimens.paddingX14,
                    ),
                    child: CustomTextField(
                      controller: _depositCtrl,
                      labelText: 'Deposit (NPR, optional)',
                      hintText: 'Refundable security deposit',
                      icon: Icons.savings_outlined,
                      keyboardType: TextInputType.number,
                      isRequired: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX24),

            CustomButton(
              text: 'Save equipment',
              icon: Icons.save_outlined,
              onPressed: _canSave ? _save : null,
              minHeight: AppDimens.sizeX54,
              borderRadius: AppDimens.radiusX14,
              fontSize: AppDimens.fontBodyTextMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NEW RENTAL
// ─────────────────────────────────────────────

class _NewRentalPage extends StatefulWidget {
  const _NewRentalPage({required this.repo});
  final _Repo repo;

  @override
  State<_NewRentalPage> createState() => _NewRentalPageState();
}

class _NewRentalPageState extends State<_NewRentalPage> {
  final _customerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');

  _Equipment? _equipment;
  int _hours = 1;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_customerCtrl, _phoneCtrl, _qtyCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _phoneCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  int get _qty {
    final raw = _qtyCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  int get _availableForSelected {
    final e = _equipment;
    if (e == null) return 0;
    final rented = widget.repo.activeQtyFor(e.id);
    return math.max(0, e.totalUnits - rented);
  }

  bool get _canSave =>
      _equipment != null &&
      _customerCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _qty > 0 &&
      _qty <= _availableForSelected &&
      _hours > 0;

  int get _charge {
    final e = _equipment;
    if (e == null) return 0;
    return e.hourlyRate * _qty * _hours;
  }

  int get _deposit {
    final e = _equipment;
    if (e == null) return 0;
    return e.deposit * _qty;
  }

  void _save() {
    setState(() => _submitted = true);
    if (!_canSave) return;
    final now = DateTime.now();
    final rental = _Rental(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      equipmentId: _equipment!.id,
      qty: _qty,
      customer: _customerCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      startedAt: now,
      dueAt: now.add(Duration(hours: _hours)),
      totalAmount: _charge,
      depositAmount: _deposit,
      status: _RentalStatus.active,
    );
    Navigator.of(context).pop(rental);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final available = _availableForSelected;
    final qtyTooHigh = _equipment != null && _qty > available;

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: 'New rental',
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: Text(
              'Start',
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: _canSave
                    ? LightColor.secondaryColor
                    : LightColor.disabledTextColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX20,
            AppDimens.paddingX4,
            AppDimens.paddingX20,
            AppDimens.paddingX28,
          ),
          children: [
            const SizedBox(height: AppDimens.paddingX4),
            Text(
              'Hand over equipment and start a rental timer.',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            const _SectionLabel('Equipment'),
            _SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDropdownField<_Equipment>(
                    labelText: 'Item',
                    hintText: 'Select equipment',
                    icon: Icons.inventory_2_outlined,
                    initialValue: _equipment,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    validator: (v) => v == null ? 'Pick an item' : null,
                    onChanged: (v) => setState(() {
                      _equipment = v;
                      final av = _availableForSelected;
                      if (_qty > av) _qtyCtrl.text = av > 0 ? '1' : '0';
                    }),
                    items: widget.repo.equipment
                        .map(
                          (e) => DropdownMenuItem<_Equipment>(
                            value: e,
                            child: Text('${e.name} · ${_Fmt.npr(e.hourlyRate)}/hr'),
                          ),
                        )
                        .toList(),
                  ),
                  if (_equipment != null) ...[
                    const SizedBox(height: AppDimens.paddingX10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: available > 0
                                ? LightColor.secondaryColor.withValues(
                                    alpha: 0.10,
                                  )
                                : LightColor.redLightColor,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusX20),
                          ),
                          child: Text(
                            available > 0
                                ? '$available available'
                                : 'Out of stock',
                            style: textTheme.bodyTextSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: AppDimens.fontBodySubTitle,
                              color: available > 0
                                  ? LightColor.secondaryColor
                                  : LightColor.redColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingX8),
                        Text(
                          'Deposit ${_Fmt.npr(_equipment!.deposit)} / unit',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            const _SectionLabel('Quantity & duration'),
            _SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _qtyCtrl,
                          labelText: 'Quantity',
                          hintText: 'Units',
                          icon: Icons.format_list_numbered_rounded,
                          keyboardType: TextInputType.number,
                          isRequired: false,
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX10),
                      Expanded(
                        child: CustomDropdownField<int>(
                          labelText: 'Hours',
                          icon: Icons.timer_outlined,
                          initialValue: _hours,
                          onChanged: (v) {
                            if (v != null) setState(() => _hours = v);
                          },
                          items: const [1, 2, 3, 4, 6, 8]
                              .map(
                                (h) => DropdownMenuItem<int>(
                                  value: h,
                                  child: Text('$h hour${h == 1 ? '' : 's'}'),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  if (qtyTooHigh) ...[
                    const SizedBox(height: AppDimens.paddingX8),
                    Text(
                      'Only $available unit${available == 1 ? '' : 's'} available.',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.redColor,
                        fontWeight: FontWeight.w600,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            const _SectionLabel('Customer'),
            _SurfaceCard(
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
                      controller: _customerCtrl,
                      labelText: 'Name',
                      hintText: 'Renter name',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      isRequired: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX14,
                      0,
                      AppDimens.paddingX14,
                      AppDimens.paddingX14,
                    ),
                    child: CustomTextField(
                      controller: _phoneCtrl,
                      labelText: 'Phone',
                      hintText: '9XX-XXXXXXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isRequired: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            const _SectionLabel('Summary'),
            _SurfaceCard(
              child: Column(
                children: [
                  _SumRow(
                    label: _equipment == null
                        ? 'Rate'
                        : '${_Fmt.npr(_equipment!.hourlyRate)} × $_qty × ${_hours}h',
                    value: _Fmt.npr(_charge),
                  ),
                  const SizedBox(height: AppDimens.paddingX8),
                  _SumRow(
                    label: 'Deposit (refundable)',
                    value: _Fmt.npr(_deposit),
                    muted: true,
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: LightColor.dividerColor,
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingX12,
                      vertical: AppDimens.paddingX10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          LightColor.secondaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Collect now',
                          style: textTheme.bodyTextSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.secondaryColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _Fmt.npr(_charge + _deposit),
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: LightColor.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX24),
            CustomButton(
              text: 'Start rental',
              icon: Icons.play_arrow_rounded,
              onPressed: _canSave ? _save : null,
              minHeight: AppDimens.sizeX54,
              borderRadius: AppDimens.radiusX14,
              fontSize: AppDimens.fontBodyTextMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  const _SumRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: muted
                  ? LightColor.hintTextColor
                  : LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyTextSmall?.copyWith(
            color:
                muted ? LightColor.hintTextColor : LightColor.primaryTextColor,
            fontWeight: muted ? FontWeight.w600 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  PRIMITIVES
// ─────────────────────────────────────────────

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
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

class _Fmt {
  static String npr(int v) {
    final s = v.abs().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${v < 0 ? '-' : ''}NPR ${buf.toString()}';
  }

  static String nprShort(int v) {
    if (v >= 100000) return 'NPR ${(v / 1000).toStringAsFixed(1)}k';
    if (v >= 1000) return 'NPR ${(v / 1000).toStringAsFixed(1)}k';
    return 'NPR $v';
  }

  static String timeAt(DateTime d) {
    final h12 = d.hour == 0
        ? 12
        : (d.hour > 12 ? d.hour - 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final p = d.hour < 12 ? 'AM' : 'PM';
    final now = DateTime.now();
    final sameDay =
        d.year == now.year && d.month == now.month && d.day == now.day;
    if (sameDay) return '$h12:$m $p';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day} · $h12:$m $p';
  }
}
