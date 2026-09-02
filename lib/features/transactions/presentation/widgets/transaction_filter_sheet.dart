import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_date_range_sheet.dart';
import 'package:hamro_futsal/features/transactions/data/model/transaction_history_model.dart';
import 'package:hamro_futsal/features/transactions/presentation/widgets/transaction_widgets.dart';
import 'package:intl/intl.dart';

/// Everything the user chose in the filter sheet, returned in one object so the
/// caller issues a single refetch rather than one per control.
class TransactionFilterSelection {
  const TransactionFilterSelection({
    required this.direction,
    required this.type,
    required this.range,
  });

  final TransactionDirectionFilter direction;
  final String type;
  final TransactionDateRange range;
}

/// Opens the calendar range sheet and resolves to the picked window, or null
/// when the user backs out.
///
/// Deliberately the same sheet the Expenses screen uses, so a custom range is
/// picked the same way everywhere. It lives under `features/expenses` only
/// because that is where it was first needed.
Future<TransactionDateRange?> pickTransactionDateRange({
  required BuildContext context,
  required TransactionDateRange current,
}) async {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final bool hasCustom =
      current.filter == TransactionRangeFilter.custom &&
      current.from != null &&
      current.to != null;

  final DateTimeRange? picked = await ExpenseDateRangeSheet.show(
    context,
    initialRange: hasCustom
        ? DateTimeRange(start: current.from!, end: current.to!)
        : null,
    // A statement only ever looks backwards, so the window cannot run past
    // today; three years back covers any ledger worth scrolling.
    firstDate: DateTime(today.year - 3, today.month, today.day),
    lastDate: today,
  );
  if (picked == null) return null;

  return TransactionDateRange.of(
    TransactionRangeFilter.custom,
    from: picked.start,
    to: picked.end,
  );
}

/// Opens the filter sheet. Resolves to null when dismissed without applying.
Future<TransactionFilterSelection?> showTransactionFilterSheet({
  required BuildContext context,
  required TransactionDirectionFilter direction,
  required String type,
  required TransactionDateRange range,
  required List<String> availableTypes,
}) {
  return showAppBottomSheet<TransactionFilterSelection>(
    context: context,
    builder: (BuildContext sheetContext) => _TransactionFilterSheet(
      direction: direction,
      type: type,
      range: range,
      availableTypes: availableTypes,
    ),
  );
}

class _TransactionFilterSheet extends StatefulWidget {
  const _TransactionFilterSheet({
    required this.direction,
    required this.type,
    required this.range,
    required this.availableTypes,
  });

  final TransactionDirectionFilter direction;
  final String type;
  final TransactionDateRange range;
  final List<String> availableTypes;

  @override
  State<_TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
  late TransactionDirectionFilter _direction = widget.direction;
  late String _type = widget.type;

  /// The chosen preset, kept separate from the resolved window: `custom` with no
  /// dates yet resolves to "all time", so storing only the resolved range would
  /// un-select the Custom chip and hide the date fields the user just asked for.
  late TransactionRangeFilter _rangeFilter = widget.range.filter;

  /// Held separately so switching to a preset and back keeps the picked dates.
  DateTime? _customFrom;
  DateTime? _customTo;

  @override
  void initState() {
    super.initState();
    if (widget.range.filter == TransactionRangeFilter.custom) {
      _customFrom = widget.range.from;
      _customTo = widget.range.to;
    }
  }

  bool get _isCustom => _rangeFilter == TransactionRangeFilter.custom;

  bool get _hasSelection =>
      _direction != TransactionDirectionFilter.all ||
      _type != 'all' ||
      _rangeFilter != TransactionRangeFilter.all;

  /// The window this sheet would apply right now.
  TransactionDateRange get _resolvedRange => _isCustom
      ? TransactionDateRange.of(
          TransactionRangeFilter.custom,
          from: _customFrom,
          to: _customTo,
        )
      : TransactionDateRange.of(_rangeFilter);

  Future<void> _selectRange(TransactionRangeFilter filter) async {
    if (filter == TransactionRangeFilter.custom) {
      await _pickCustomRange();
      return;
    }
    setState(() => _rangeFilter = filter);
  }

  /// Same calendar sheet as the chip row on the page behind this one, so a
  /// custom window is always picked the same way.
  Future<void> _pickCustomRange() async {
    final TransactionDateRange? picked = await pickTransactionDateRange(
      context: context,
      current: _resolvedRange,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _rangeFilter = TransactionRangeFilter.custom;
      _customFrom = picked.from;
      _customTo = picked.to;
    });
  }

  void _reset() {
    setState(() {
      _direction = TransactionDirectionFilter.all;
      _type = 'all';
      _rangeFilter = TransactionRangeFilter.all;
      _customFrom = null;
      _customTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The sheet must survive a short viewport (small phones, landscape, or the
    // custom date fields being revealed), so the sections scroll between a
    // fixed header and a fixed action button.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Header(onReset: _hasSelection ? _reset : null),
          const SizedBox(height: AppDimens.sizeX12),
          Divider(height: AppDimens.sizeX1, color: LightColor.dividerColor),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SectionLabel(StringConstants.direction),
                  _DirectionSegments(
                    selected: _direction,
                    onChanged: (TransactionDirectionFilter filter) =>
                        setState(() => _direction = filter),
                  ),

                  if (widget.availableTypes.isNotEmpty) ...<Widget>[
                    const _SectionLabel(StringConstants.type),
                    _ChipGrid(
                      children: <Widget>[
                        for (final String option in <String>[
                          'all',
                          ...widget.availableTypes,
                        ])
                          TransactionFilterChip(
                            label: option == 'all'
                                ? StringConstants.allTransactions
                                : TxnParse.humanize(option),
                            selected: option == _type,
                            onTap: () => setState(() => _type = option),
                          ),
                      ],
                    ),
                  ],

                  const _SectionLabel(StringConstants.dateRange),
                  _ChipGrid(
                    children: TransactionRangeFilter.values
                        .map(
                          (TransactionRangeFilter filter) =>
                              TransactionFilterChip(
                                label: _rangeLabel(filter),
                                selected: filter == _rangeFilter,
                                onTap: () => _selectRange(filter),
                              ),
                        )
                        .toList(growable: false),
                  ),

                  // Reads back the picked window and re-opens the calendar,
                  // so the Custom chip is not a dead end once it is set.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _isCustom
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: AppDimens.paddingX12,
                            ),
                            child: _CustomRangeSummary(
                              from: _customFrom,
                              to: _customTo,
                              onEdit: _pickCustomRange,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: AppDimens.sizeX20),
                ],
              ),
            ),
          ),
          Divider(height: AppDimens.sizeX1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.sizeX16),
          CustomButton(
            text: StringConstants.showTransactions,
            widthFactor: 1,
            onPressed: () => Navigator.of(context).pop(
              TransactionFilterSelection(
                direction: _direction,
                type: _type,
                range: _resolvedRange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rangeLabel(TransactionRangeFilter filter) => switch (filter) {
    TransactionRangeFilter.all => StringConstants.allTime,
    TransactionRangeFilter.today => StringConstants.today,
    TransactionRangeFilter.week => StringConstants.thisWeek,
    TransactionRangeFilter.month => StringConstants.thisMonth,
    TransactionRangeFilter.year => StringConstants.thisYear,
    TransactionRangeFilter.custom => StringConstants.customRange,
  };
}

class _Header extends StatelessWidget {
  const _Header({required this.onReset});

  /// Null disables the reset action, so it reads as unavailable when there is
  /// nothing to clear.
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final bool enabled = onReset != null;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            StringConstants.filters,
            style: textTheme.bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onReset,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX8,
            ),
            minimumSize: Size.zero,
          ),
          child: Text(
            StringConstants.reset,
            style: textTheme.bodyTextSmall?.copyWith(
              color: enabled
                  ? LightColor.secondaryColor
                  : LightColor.disabledTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimens.paddingX18,
        bottom: AppDimens.paddingX10,
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Options laid out two per row.
///
/// A [Wrap] packed a variable number of chips onto each line, so the same
/// sheet looked different for every set of labels; a fixed grid keeps the two
/// columns aligned down both sections. An odd last item takes one column and
/// leaves the other empty rather than stretching across.
class _ChipGrid extends StatelessWidget {
  const _ChipGrid({required this.children});

  final List<Widget> children;

  static const int _columns = 2;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];

    for (int i = 0; i < children.length; i += _columns) {
      final List<Widget> cells = children.skip(i).take(_columns).toList();
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : AppDimens.paddingX8),
          // IntrinsicHeight so both columns match the taller chip; `stretch`
          // alone would ask for infinite height inside the scrolling column.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int column = 0; column < _columns; column++) ...<Widget>[
                  if (column > 0) const SizedBox(width: AppDimens.sizeX8),
                  Expanded(
                    child: column < cells.length
                        ? cells[column]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

/// Direction is mutually exclusive with exactly three options, so it gets a
/// segmented control rather than loose chips.
class _DirectionSegments extends StatelessWidget {
  const _DirectionSegments({required this.selected, required this.onChanged});

  final TransactionDirectionFilter selected;
  final ValueChanged<TransactionDirectionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.sunkenColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: TransactionDirectionFilter.values
            .map((TransactionDirectionFilter filter) {
              final bool isSelected = filter == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(filter),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.paddingX8,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? LightColor.cardColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                      border: Border.all(
                        color: isSelected
                            ? LightColor.dividerColor
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (filter !=
                            TransactionDirectionFilter.all) ...<Widget>[
                          Icon(
                            filter == TransactionDirectionFilter.incoming
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            size: AppDimens.sizeX12,
                            color: _segmentColor(filter, isSelected),
                          ),
                          const SizedBox(width: AppDimens.sizeX4),
                        ],
                        Flexible(
                          child: Text(
                            transactionDirectionLabel(filter),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: _segmentColor(filter, isSelected),
                              fontSize: AppDimens.fontBodySubTitle,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  /// Selected in/out segments carry the same green/red the rows use, so the
  /// filter and the data it produces speak one colour language.
  Color _segmentColor(TransactionDirectionFilter filter, bool isSelected) {
    if (!isSelected) return LightColor.secondaryTextColor;
    return switch (filter) {
      TransactionDirectionFilter.all => LightColor.primaryTextColor,
      TransactionDirectionFilter.incoming => LightColor.brandTextColor,
      TransactionDirectionFilter.outgoing => LightColor.redColor,
    };
  }
}

/// Reads back the window the calendar returned, and re-opens it on tap.
///
/// Replaces the pair of single-date fields this sheet used to reveal: the
/// range is now picked on one calendar, so there is nothing left to type in —
/// only something to confirm.
class _CustomRangeSummary extends StatelessWidget {
  const _CustomRangeSummary({
    required this.from,
    required this.to,
    required this.onEdit,
  });

  final DateTime? from;
  final DateTime? to;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final DateFormat format = DateFormat('dd MMM yyyy');
    final bool isSet = from != null || to != null;
    final String label = switch ((from, to)) {
      (final DateTime a?, final DateTime b?) when a == b => format.format(a),
      (final DateTime a?, final DateTime b?) =>
        '${format.format(a)}  →  ${format.format(b)}',
      (final DateTime a?, null) => '${format.format(a)}  →  …',
      (null, final DateTime b?) => '…  →  ${format.format(b)}',
      _ => StringConstants.selectDate,
    };

    return Material(
      color: LightColor.elevatedCardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: isSet
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_rounded,
                size: AppDimens.sizeX16,
                color: isSet
                    ? LightColor.secondaryColor
                    : LightColor.hintTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: isSet
                        ? LightColor.primaryTextColor
                        : LightColor.hintTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Text(
                StringConstants.change,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
