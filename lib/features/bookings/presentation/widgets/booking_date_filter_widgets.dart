import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_date_picker.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/presentation/utils/booking_search.dart';
import 'package:intl/intl.dart';

/// The trailing control on the search row: opens the date sheet, and carries a
/// dot while a date filter is on so the row says at a glance that the list is
/// narrowed.
class BookingDateFilterButton extends StatelessWidget {
  const BookingDateFilterButton({
    super.key,
    required this.filter,
    required this.onTap,
  });

  final BookingDateFilter filter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool active = filter.isActive;
    final Color accent = LightColor.secondaryColor;
    return Tooltip(
      message: active ? 'Edit date filter' : StringConstants.filterByDate,
      child: Material(
        color: active ? accent.withValues(alpha: 0.10) : LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
        child: InkWell(
          key: const Key('futsal-date-filter-button'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
          child: Container(
            height: AppDimens.sizeX44,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusX6),
              border: Border.all(
                color: active
                    ? accent.withValues(alpha: 0.45)
                    : LightColor.dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.tune_rounded,
                  size: AppDimens.sizeX20,
                  color: active ? accent : LightColor.secondaryTextColor,
                ),
                if (active) ...<Widget>[
                  const SizedBox(width: AppDimens.paddingX6),
                  Container(
                    width: AppDimens.sizeX8,
                    height: AppDimens.sizeX8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The active date filter, with the stepping the mode allows.
///
/// One strip serves all three modes, which is what keeps the section short:
/// a day and a month get the arrows (stepping by a day and by a month
/// respectively — a vendor working through a week does not want the sheet
/// every time), and a range gets its window read out with a clear button.
/// Nothing is shown at all while the filter is off.
class BookingDateFilterStrip extends StatelessWidget {
  const BookingDateFilterStrip({
    super.key,
    required this.filter,
    required this.onStep,
    required this.onEdit,
    required this.onClear,
  });

  final BookingDateFilter filter;

  /// Called with -1 / +1 for the previous / next day or month.
  final ValueChanged<int> onStep;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (!filter.isActive) return const SizedBox.shrink();

    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final Color accent = LightColor.secondaryColor;

    return Container(
      height: AppDimens.sizeX38,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: <Widget>[
          if (filter.canStep)
            _StripArrow(
              buttonKey: const Key('futsal-date-step-previous'),
              icon: Icons.chevron_left_rounded,
              onTap: () => onStep(-1),
            )
          else
            const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              child: InkWell(
                key: const Key('futsal-date-filter-label'),
                onTap: onEdit,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _ModePill(label: filter.modeLabel),
                    const SizedBox(width: AppDimens.paddingX8),
                    Flexible(
                      child: Text(
                        filter.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySubTitle?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (filter.canStep)
            _StripArrow(
              buttonKey: const Key('futsal-date-step-next'),
              icon: Icons.chevron_right_rounded,
              onTap: () => onStep(1),
            )
          else
            const SizedBox(width: AppDimens.paddingX8),
          _StripArrow(
            buttonKey: const Key('futsal-date-filter-clear'),
            icon: Icons.close_rounded,
            tint: accent,
            onTap: onClear,
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX6,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        label.toUpperCase(),
        style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
          color: LightColor.inverseTextColor,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StripArrow extends StatelessWidget {
  const _StripArrow({
    required this.buttonKey,
    required this.icon,
    required this.onTap,
    this.tint,
  });

  final Key buttonKey;
  final IconData icon;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingX4),
          child: Icon(
            icon,
            size: AppDimens.sizeX18,
            color: tint ?? LightColor.primaryTextColor,
          ),
        ),
      ),
    );
  }
}

/// What the date sheet came back with: the window, and the order the rows are
/// listed in. Both are chosen in the same place because both answer "which
/// bookings, in what order" — separating them cost the row a second control.
final class BookingDateFilterResult {
  const BookingDateFilterResult({required this.filter, required this.order});

  final BookingDateFilter filter;
  final BookingDateOrder order;
}

/// Opens the date filter sheet. Returns the chosen filter and order, or null
/// when the sheet was dismissed without applying.
Future<BookingDateFilterResult?> showBookingDateFilterSheet(
  BuildContext context, {
  required BookingDateFilter current,
  required BookingDateOrder currentOrder,
}) {
  return showModalBottomSheet<BookingDateFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: LightColor.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.radiusX20),
      ),
    ),
    builder: (BuildContext context) =>
        _BookingDateFilterSheet(initial: current, initialOrder: currentOrder),
  );
}

/// One sheet for all three ways of narrowing by date.
///
/// The mode selector at the top swaps only the body beneath it, so the three
/// modes are alternatives rather than three filters that could each be half
/// filled in — which is what made the old two-field range sheet ambiguous
/// about whether a single date meant "that day" or "from that day".
class _BookingDateFilterSheet extends StatefulWidget {
  const _BookingDateFilterSheet({
    required this.initial,
    required this.initialOrder,
  });

  final BookingDateFilter initial;
  final BookingDateOrder initialOrder;

  @override
  State<_BookingDateFilterSheet> createState() =>
      _BookingDateFilterSheetState();
}

class _BookingDateFilterSheetState extends State<_BookingDateFilterSheet> {
  static const List<BookingDateMode> _modes = <BookingDateMode>[
    BookingDateMode.all,
    BookingDateMode.day,
    BookingDateMode.month,
    BookingDateMode.range,
  ];

  late BookingDateMode _mode;
  late BookingDateOrder _order;

  /// Each mode keeps its own working value, so flipping between them to
  /// compare does not throw away what was already picked.
  late DateTime _day;
  late DateTime _month;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    final BookingDateFilter initial = widget.initial;
    final DateTime today = DateTime.now();
    _mode = initial.mode;
    _order = widget.initialOrder;
    _day = initial.mode == BookingDateMode.day
        ? initial.anchor
        : DateTime(today.year, today.month, today.day);
    _month = initial.mode == BookingDateMode.month
        ? initial.anchor
        : DateTime(today.year, today.month);
    if (initial.mode == BookingDateMode.range) {
      _from = initial.from;
      _to = initial.to;
    }
  }

  BookingDateFilter get _value => switch (_mode) {
    BookingDateMode.all => const BookingDateFilter.all(),
    BookingDateMode.day => BookingDateFilter.day(_day),
    BookingDateMode.month => BookingDateFilter.month(_month),
    BookingDateMode.range => BookingDateFilter.range(from: _from, to: _to),
  };

  Future<void> _pickDay() async {
    final DateTime? picked = await showCustomDatePicker(
      context,
      type: CustomDatePickerType.anyDate,
      initialDate: _day,
    );
    if (picked == null || !mounted) return;
    setState(() => _day = picked);
  }

  Future<void> _pickRangeEnd({required bool isStart}) async {
    final DateTime? picked = await showCustomDatePicker(
      context,
      type: CustomDatePickerType.anyDate,
      initialDate: (isStart ? _from : _to) ?? DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  void _apply() => Navigator.of(
    context,
  ).pop(BookingDateFilterResult(filter: _value, order: _order));

  /// Clears the window but keeps the order: the order is how the list is read,
  /// not part of what is being filtered out.
  void _clear() => Navigator.of(context).pop(
    BookingDateFilterResult(
      filter: const BookingDateFilter.all(),
      order: _order,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: AppUtils().getPadding(
          left: AppDimens.paddingX20,
          right: AppDimens.paddingX20,
          top: AppDimens.paddingX10,
          bottom: AppDimens.paddingX20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: AppDimens.sizeX40,
                height: AppDimens.sizeX4,
                decoration: BoxDecoration(
                  color: LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    StringConstants.filterByDate,
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: StringConstants.close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX4),
            _ModeSelector(
              modes: _modes,
              selected: _mode,
              onSelected: (BookingDateMode mode) =>
                  setState(() => _mode = mode),
            ),
            const SizedBox(height: AppDimens.paddingX18),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _body(context),
            ),
            const SizedBox(height: AppDimens.paddingX18),
            Text(
              StringConstants.dateOrder,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _OrderButton(
                    buttonKey: const Key('date-sheet-order-newest'),
                    label: 'Newest first',
                    icon: Icons.arrow_downward_rounded,
                    isSelected: _order == BookingDateOrder.descending,
                    onTap: () =>
                        setState(() => _order = BookingDateOrder.descending),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX10),
                Expanded(
                  child: _OrderButton(
                    buttonKey: const Key('date-sheet-order-oldest'),
                    label: 'Oldest first',
                    icon: Icons.arrow_upward_rounded,
                    isSelected: _order == BookingDateOrder.ascending,
                    onTap: () =>
                        setState(() => _order = BookingDateOrder.ascending),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX20),
            Row(
              children: <Widget>[
                TextButton(
                  key: const Key('date-sheet-clear'),
                  onPressed: _clear,
                  child: Text(
                    StringConstants.clear,
                    style: TextStyle(color: LightColor.secondaryTextColor),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX12),
                Expanded(
                  child: SizedBox(
                    height: AppDimens.sizeX42,
                    child: FilledButton(
                      key: const Key('date-sheet-apply'),
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        backgroundColor: LightColor.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX8,
                          ),
                        ),
                      ),
                      child: const Text(StringConstants.applyFilter),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) => switch (_mode) {
    BookingDateMode.all => const _AllModeBody(),
    BookingDateMode.day => _DayModeBody(
      day: _day,
      onPick: _pickDay,
      onQuickPick: (DateTime value) => setState(() => _day = value),
    ),
    BookingDateMode.month => _MonthModeBody(
      month: _month,
      onChanged: (DateTime value) => setState(() => _month = value),
    ),
    BookingDateMode.range => _RangeModeBody(
      from: _from,
      to: _to,
      onPick: _pickRangeEnd,
      onQuickPick: (DateTime start, DateTime end) => setState(() {
        _from = start;
        _to = end;
      }),
    ),
  };
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.modes,
    required this.selected,
    required this.onSelected,
  });

  final List<BookingDateMode> modes;
  final BookingDateMode selected;
  final ValueChanged<BookingDateMode> onSelected;

  static String _label(BookingDateMode mode) => switch (mode) {
    BookingDateMode.all => 'All',
    BookingDateMode.day => 'Day',
    BookingDateMode.month => 'Month',
    BookingDateMode.range => 'Range',
  };

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: modes
            .map((BookingDateMode mode) {
              final bool isSelected = mode == selected;
              return Expanded(
                child: Material(
                  color: isSelected
                      ? LightColor.secondaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  child: InkWell(
                    key: Key('date-mode-${mode.name}'),
                    onTap: () => onSelected(mode),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.paddingX8,
                      ),
                      child: Text(
                        _label(mode),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: isSelected
                              ? LightColor.inverseTextColor
                              : LightColor.secondaryTextColor,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _OrderButton extends StatelessWidget {
  const _OrderButton({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final Key buttonKey;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: isSelected
          ? LightColor.secondaryColor.withValues(alpha: 0.10)
          : LightColor.background,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Container(
          height: AppDimens.sizeX42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: AppDimens.sizeX18,
                color: isSelected
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isSelected
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllModeBody extends StatelessWidget {
  const _AllModeBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.event_available_rounded,
          size: AppDimens.sizeX18,
          color: LightColor.secondaryTextColor,
        ),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: Text(
            'Every booking is shown, whatever its date.',
            style: FutsalTheme.getTextTheme(
              context,
            ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
          ),
        ),
      ],
    );
  }
}

class _DayModeBody extends StatelessWidget {
  const _DayModeBody({
    required this.day,
    required this.onPick,
    required this.onQuickPick,
  });

  final DateTime day;
  final VoidCallback onPick;
  final ValueChanged<DateTime> onQuickPick;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SheetDateField(
          fieldKey: const Key('date-sheet-day'),
          label: 'Day',
          value: day,
          onTap: onPick,
        ),
        const SizedBox(height: AppDimens.paddingX12),
        _QuickPicks(
          picks: <String, VoidCallback>{
            'Today': () => onQuickPick(today),
            'Yesterday': () =>
                onQuickPick(today.subtract(const Duration(days: 1))),
            'Tomorrow': () => onQuickPick(today.add(const Duration(days: 1))),
          },
        ),
      ],
    );
  }
}

/// A year stepper over a grid of the twelve months — quicker than scrolling a
/// day picker when the whole month is what is wanted.
class _MonthModeBody extends StatelessWidget {
  const _MonthModeBody({required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final DateTime now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _StripArrow(
              buttonKey: const Key('date-sheet-year-previous'),
              icon: Icons.chevron_left_rounded,
              onTap: () => onChanged(DateTime(month.year - 1, month.month)),
            ),
            const SizedBox(width: AppDimens.paddingX16),
            Text(
              '${month.year}',
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppDimens.paddingX16),
            _StripArrow(
              buttonKey: const Key('date-sheet-year-next'),
              icon: Icons.chevron_right_rounded,
              onTap: () => onChanged(DateTime(month.year + 1, month.month)),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingX12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDimens.paddingX8,
          crossAxisSpacing: AppDimens.paddingX8,
          childAspectRatio: 2.4,
          children: List<Widget>.generate(12, (int index) {
            final int monthNumber = index + 1;
            final bool isSelected = month.month == monthNumber;
            final bool isThisMonth =
                month.year == now.year && monthNumber == now.month;
            return Material(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              child: InkWell(
                key: Key('date-sheet-month-$monthNumber'),
                onTap: () => onChanged(DateTime(month.year, monthNumber)),
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    border: Border.all(
                      color: isSelected
                          ? LightColor.secondaryColor
                          : isThisMonth
                          ? LightColor.secondaryColor.withValues(alpha: 0.45)
                          : LightColor.dividerColor,
                    ),
                  ),
                  child: Text(
                    DateFormat('MMM').format(DateTime(month.year, monthNumber)),
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: isSelected
                          ? LightColor.inverseTextColor
                          : LightColor.primaryTextColor,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _RangeModeBody extends StatelessWidget {
  const _RangeModeBody({
    required this.from,
    required this.to,
    required this.onPick,
    required this.onQuickPick,
  });

  final DateTime? from;
  final DateTime? to;
  final void Function({required bool isStart}) onPick;
  final void Function(DateTime start, DateTime end) onQuickPick;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _SheetDateField(
                fieldKey: const Key('date-sheet-from'),
                label: StringConstants.fromDate,
                value: from,
                onTap: () => onPick(isStart: true),
              ),
            ),
            const SizedBox(width: AppDimens.paddingX10),
            Expanded(
              child: _SheetDateField(
                fieldKey: const Key('date-sheet-to'),
                label: StringConstants.toDate,
                value: to,
                onTap: () => onPick(isStart: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingX12),
        _QuickPicks(
          picks: <String, VoidCallback>{
            'Last 7 days': () =>
                onQuickPick(today.subtract(const Duration(days: 6)), today),
            'Last 30 days': () =>
                onQuickPick(today.subtract(const Duration(days: 29)), today),
            'This month': () => onQuickPick(
              DateTime(today.year, today.month),
              DateTime(today.year, today.month + 1, 0),
            ),
          },
        ),
      ],
    );
  }
}

/// The shortcuts that cover most of what a vendor actually asks for, so the
/// common cases never need the picker.
class _QuickPicks extends StatelessWidget {
  const _QuickPicks({required this.picks});

  final Map<String, VoidCallback> picks;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Wrap(
      spacing: AppDimens.paddingX8,
      runSpacing: AppDimens.paddingX8,
      children: picks.entries
          .map((MapEntry<String, VoidCallback> entry) {
            return Material(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusX20),
              child: InkWell(
                key: Key(
                  'date-quick-${entry.key.toLowerCase().replaceAll(' ', '-')}',
                ),
                onTap: entry.value,
                borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingX12,
                    vertical: AppDimens.paddingX6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                    border: Border.all(color: LightColor.dividerColor),
                  ),
                  child: Text(
                    entry.key,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _SheetDateField extends StatelessWidget {
  const _SheetDateField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final Key fieldKey;
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  static final DateFormat _format = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.background,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: InkWell(
        key: fieldKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Container(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: textTheme.bodySubTitle?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX4),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: AppDimens.sizeX16,
                    color: LightColor.secondaryColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX6),
                  Expanded(
                    child: Text(
                      value == null ? 'Any' : _format.format(value!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: value == null
                            ? LightColor.hintTextColor
                            : LightColor.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
