import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_date_picker.dart';
import 'package:hamro_footsall/features/transactions/data/model/transaction_history_model.dart';
import 'package:hamro_footsall/features/transactions/presentation/widgets/transaction_widgets.dart';
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

  void _selectRange(TransactionRangeFilter filter) {
    setState(() => _rangeFilter = filter);
  }

  Future<void> _pickCustomDate({required bool isStart}) async {
    final DateTime? picked = await showCustomDatePicker(
      context,
      title: isStart ? StringConstants.startDate : StringConstants.endDate,
      initialDate: (isStart ? _customFrom : _customTo) ?? DateTime.now(),
      // A ledger only ever looks backwards.
      maxDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _customFrom = picked;
      } else {
        _customTo = picked;
      }
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
          const _GrabHandle(),
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
                    _ChipWrap(
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
                  _ChipWrap(
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

                  // Grows and shrinks with the Custom chip rather than
                  // appearing instantly.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _isCustom
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: AppDimens.paddingX12,
                            ),
                            child: _CustomRangeFields(
                              from: _customFrom,
                              to: _customTo,
                              onPickStart: () => _pickCustomDate(isStart: true),
                              onPickEnd: () => _pickCustomDate(isStart: false),
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

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppDimens.sizeX36,
        height: AppDimens.sizeX4,
        margin: const EdgeInsets.only(bottom: AppDimens.paddingX16),
        decoration: BoxDecoration(
          color: LightColor.dividerColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX4),
        ),
      ),
    );
  }
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

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.sizeX8,
      runSpacing: AppDimens.sizeX8,
      children: children,
    );
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

/// The two bounds of a custom window, with an arrow between them and a hint
/// while the range is still half-open.
class _CustomRangeFields extends StatelessWidget {
  const _CustomRangeFields({
    required this.from,
    required this.to,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final DateTime? from;
  final DateTime? to;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    // One bound picked but not the other: still valid on the wire, so this is a
    // hint rather than an error.
    final bool halfOpen = (from == null) != (to == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _DateField(
                label: StringConstants.startDate,
                value: from,
                onTap: onPickStart,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX8,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: AppDimens.sizeX14,
                color: LightColor.hintTextColor,
              ),
            ),
            Expanded(
              child: _DateField(
                label: StringConstants.endDate,
                value: to,
                onTap: onPickEnd,
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: halfOpen
              ? Padding(
                  padding: const EdgeInsets.only(top: AppDimens.paddingX8),
                  child: Text(
                    from == null
                        ? StringConstants.pickAStartDateHint
                        : StringConstants.pickAnEndDateHint,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: AppDimens.fontBodySubTitle,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Tappable date box for one bound of the custom range.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final bool isSet = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX12,
          vertical: AppDimens.paddingX10,
        ),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          border: Border.all(
            color: isSet ? LightColor.secondaryColor : LightColor.dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontSize: AppDimens.fontBodySubTitle,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX2),
            Row(
              children: <Widget>[
                Icon(
                  Icons.event_rounded,
                  size: AppDimens.sizeX14,
                  color: isSet
                      ? LightColor.secondaryColor
                      : LightColor.hintTextColor,
                ),
                const SizedBox(width: AppDimens.sizeX6),
                Expanded(
                  child: Text(
                    isSet
                        ? DateFormat('dd MMM yyyy').format(value!)
                        : StringConstants.selectDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: isSet
                          ? LightColor.primaryTextColor
                          : LightColor.hintTextColor,
                      fontWeight: isSet ? FontWeight.w600 : FontWeight.w500,
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
}
