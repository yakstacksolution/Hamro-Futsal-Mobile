import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Custom range date picker shown in a bottom sheet — replaces the default
/// Material `showDateRangePicker` dialog so the look matches the rest of the
/// Expenses screen.
///
/// Returns the chosen [DateTimeRange] via `Navigator.pop`, or null on cancel.
class ExpenseDateRangeSheet extends StatefulWidget {
  const ExpenseDateRangeSheet({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.initialRange,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange? initialRange;

  /// Convenience launcher that applies the shared sheet chrome.
  static Future<DateTimeRange?> show(
    BuildContext context, {
    required DateTime firstDate,
    required DateTime lastDate,
    DateTimeRange? initialRange,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX20),
        ),
      ),
      builder: (_) => ExpenseDateRangeSheet(
        firstDate: firstDate,
        lastDate: lastDate,
        initialRange: initialRange,
      ),
    );
  }

  @override
  State<ExpenseDateRangeSheet> createState() => _ExpenseDateRangeSheetState();
}

class _ExpenseDateRangeSheetState extends State<ExpenseDateRangeSheet> {
  static DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

  late DateTime _first;
  late DateTime _last;
  late DateTime _visibleMonth;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _first = _d(widget.firstDate);
    _last = _d(widget.lastDate);
    _start = widget.initialRange == null
        ? null
        : _d(widget.initialRange!.start);
    _end = widget.initialRange == null ? null : _d(widget.initialRange!.end);
    final anchor = _start ?? _d(DateTime.now());
    _visibleMonth = DateTime(anchor.year, anchor.month);
  }

  bool get _canApply => _start != null;

  bool get _canPrev => DateTime(
    _visibleMonth.year,
    _visibleMonth.month,
  ).isAfter(DateTime(_first.year, _first.month));

  bool get _canNext => DateTime(
    _visibleMonth.year,
    _visibleMonth.month,
  ).isBefore(DateTime(_last.year, _last.month));

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
    HapticFeedback.selectionClick();
  }

  void _onTapDay(DateTime day) {
    HapticFeedback.selectionClick();
    setState(() {
      // Start a fresh range when nothing is pending or a full range exists.
      if (_start == null || _end != null) {
        _start = day;
        _end = null;
        return;
      }
      // Second tap closes the range, swapping if it lands before the start.
      if (day.isBefore(_start!)) {
        _end = _start;
        _start = day;
      } else {
        _end = day;
      }
    });
  }

  void _applyPreset(DateTime start, DateTime end) {
    setState(() {
      _start = _clamp(start);
      _end = _clamp(end);
      _visibleMonth = DateTime(_end!.year, _end!.month);
    });
    HapticFeedback.selectionClick();
  }

  DateTime _clamp(DateTime d) {
    if (d.isBefore(_first)) return _first;
    if (d.isAfter(_last)) return _last;
    return d;
  }

  bool _inRange(DateTime day) =>
      _start != null &&
      _end != null &&
      day.isAfter(_start!) &&
      day.isBefore(_end!);

  bool _isEdge(DateTime day) =>
      (_start != null && day == _start) || (_end != null && day == _end);

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.paddingX20,
          AppDimens.paddingX12,
          AppDimens.paddingX20,
          AppDimens.paddingX16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grab handle.
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimens.paddingX14),
                decoration: BoxDecoration(
                  color: LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            _header(textTheme),
            const SizedBox(height: AppDimens.paddingX14),
            _presets(textTheme),
            const SizedBox(height: AppDimens.paddingX16),
            _monthBar(textTheme),
            const SizedBox(height: AppDimens.paddingX10),
            _weekdayRow(textTheme),
            const SizedBox(height: AppDimens.paddingX4),
            _grid(textTheme),
            const SizedBox(height: AppDimens.paddingX18),
            _actions(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _header(dynamic textTheme) {
    final summary = _start == null
        ? 'Select a start date'
        : _end == null
        ? '${formatShortDate(_start!)} → …'
        : '${formatShortDate(_start!)} → ${formatShortDate(_end!)}';
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConstants.customRange,
              style: textTheme.bodyTextLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              summary,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.close_rounded, color: LightColor.iconGrey),
        ),
      ],
    );
  }

  Widget _presets(dynamic textTheme) {
    final today = _d(DateTime.now());
    final items = <(String, DateTime, DateTime)>[
      ('7 days', today.subtract(const Duration(days: 6)), today),
      ('30 days', today.subtract(const Duration(days: 29)), today),
      ('This month', DateTime(today.year, today.month, 1), today),
      ('This year', DateTime(today.year, 1, 1), today),
    ];
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          final (label, start, end) = items[i];
          final selected = _start == _clamp(start) && _end == _clamp(end);
          return _Pill(
            label: label,
            selected: selected,
            onTap: () => _applyPreset(start, end),
          );
        },
      ),
    );
  }

  Widget _monthBar(dynamic textTheme) {
    const months = [
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
    return Row(
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          enabled: _canPrev,
          onTap: () => _changeMonth(-1),
        ),
        Expanded(
          child: Text(
            '${months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          enabled: _canNext,
          onTap: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _weekdayRow(dynamic textTheme) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: [
        for (final l in labels)
          Expanded(
            child: Center(
              child: Text(
                l,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _grid(dynamic textTheme) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final firstWeekday = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    ).weekday; // Mon = 1 … Sun = 7
    final leadingBlanks = firstWeekday - 1;
    final cells = <Widget>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const Expanded(child: SizedBox.shrink()));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
      cells.add(Expanded(child: _dayCell(date, textTheme)));
    }
    // Pad the final week so the last row keeps 7 equal columns.
    while (cells.length % 7 != 0) {
      cells.add(const Expanded(child: SizedBox.shrink()));
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(Row(children: cells.sublist(i, i + 7)));
    }
    return Column(children: rows);
  }

  Widget _dayCell(DateTime date, dynamic textTheme) {
    final disabled = date.isBefore(_first) || date.isAfter(_last);
    final edge = _isEdge(date);
    final inRange = _inRange(date);
    final isToday = date == _d(DateTime.now());

    Color bg = Colors.transparent;
    Color fg = LightColor.primaryTextColor;
    if (edge) {
      bg = LightColor.secondaryColor;
      fg = LightColor.inverseTextColor;
    } else if (inRange) {
      bg = LightColor.secondaryColor.withValues(alpha: 0.14);
      fg = LightColor.secondaryColor;
    }
    if (disabled) fg = LightColor.dividerColor;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              edge ? AppDimens.radiusX10 : AppDimens.radiusX8,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            onTap: disabled ? null : () => _onTapDay(date),
            child: Center(
              child: Text(
                '${date.day}',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: fg,
                  fontWeight: edge || isToday
                      ? FontWeight.w800
                      : FontWeight.w500,
                  decoration: isToday && !edge
                      ? TextDecoration.underline
                      : null,
                  decorationColor: LightColor.secondaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions(dynamic textTheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: LightColor.secondaryTextColor,
              side: BorderSide(color: LightColor.dividerColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              ),
            ),
            child: const Text(StringConstants.cancel),
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: FilledButton(
            onPressed: _canApply
                ? () => Navigator.of(
                    context,
                  ).pop(DateTimeRange(start: _start!, end: _end ?? _start!))
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: LightColor.secondaryColor,
              foregroundColor: LightColor.inverseTextColor,
              disabledBackgroundColor: LightColor.secondaryColor.withValues(
                alpha: 0.4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              ),
            ),
            child: const Text(StringConstants.apply),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: selected
                  ? LightColor.inverseTextColor
                  : LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? LightColor.primaryTextColor
                : LightColor.dividerColor,
          ),
        ),
      ),
    );
  }
}
