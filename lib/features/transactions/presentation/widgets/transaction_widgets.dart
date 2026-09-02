import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/transactions/data/model/transaction_history_model.dart';
import 'package:intl/intl.dart';

/// `NPR 1,167` — whole rupees, since the ledger is read at a glance.
String formatTransactionAmount(double amount) =>
    '${StringConstants.npr} ${NumberFormat('#,##0', 'en_US').format(amount)}';

/// Colour for a status label. Statuses are an open vocabulary
/// (`pending_clearance`, `cleared`, `recorded`, `partial`, …), so they are
/// matched by substring rather than enumerated.
///
/// Only genuinely notable states get a hue; everything settled stays neutral,
/// so a long statement is not a wall of colour.
Color transactionStatusColor(String? status) {
  final String value = status?.toLowerCase() ?? '';
  if (value.contains('cancel') ||
      value.contains('fail') ||
      value.contains('reject')) {
    return LightColor.redColor;
  }
  if (value.contains('pend') ||
      value.contains('partial') ||
      value.contains('review')) {
    return LightColor.warningColor;
  }
  if (value.contains('refund')) return LightColor.purpleColor;
  return LightColor.secondaryTextColor;
}

String transactionRangeLabel(TransactionDateRange range) {
  switch (range.filter) {
    case TransactionRangeFilter.all:
      return StringConstants.allTime;
    case TransactionRangeFilter.today:
      return StringConstants.today;
    case TransactionRangeFilter.week:
      return StringConstants.thisWeek;
    case TransactionRangeFilter.month:
      return StringConstants.thisMonth;
    case TransactionRangeFilter.year:
      return StringConstants.thisYear;
    case TransactionRangeFilter.custom:
      final DateFormat format = DateFormat('dd MMM');
      final String from = range.from == null ? '…' : format.format(range.from!);
      final String to = range.to == null ? '…' : format.format(range.to!);
      return '$from – $to';
  }
}

String transactionDirectionLabel(TransactionDirectionFilter direction) =>
    switch (direction) {
      TransactionDirectionFilter.all => StringConstants.allTransactions,
      TransactionDirectionFilter.incoming => StringConstants.incoming,
      TransactionDirectionFilter.outgoing => StringConstants.outgoing,
    };

/// Tabular figures keep every amount in the ledger on the same digit grid, so
/// a column of totals lines up instead of shimmying by a pixel per digit.
const List<FontFeature> _tabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

/// Statement header: a raised card carrying the net figure for the active
/// filters, with the money-in / money-out split as two stats beneath a rule.
///
/// Figures come from the server's `summary`, which covers the whole filtered
/// set rather than the pages loaded so far.
class TransactionSummaryPanel extends StatelessWidget {
  const TransactionSummaryPanel({
    super.key,
    required this.summary,
    required this.rangeLabel,
    required this.fallbackCount,
  });

  final TransactionHistorySummaryModel? summary;
  final String rangeLabel;

  /// Used when the payload carries no `transaction_count`.
  final int fallbackCount;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final double incoming = summary?.incomingTotal ?? 0;
    final double outgoing = summary?.outgoingTotal ?? 0;
    final double net = summary?.netTotal ?? (incoming - outgoing);
    final int count = summary?.transactionCount ?? fallbackCount;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX16,
      ),
      decoration: BoxDecoration(
        color: LightColor.elevatedCardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${StringConstants.netBalance} · $rangeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              _CountBadge(count: count),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX6),
          // Keyed on the value, so a new total cross-fades in rather than
          // flicking from one number to another.
          _FadeOnChange(
            child: Text(
              formatTransactionAmount(net),
              key: ValueKey<double>(net),
              style: textTheme.headingSmall?.copyWith(
                color: net < 0
                    ? LightColor.redColor
                    : LightColor.primaryTextColor,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                fontFeatures: _tabularFigures,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.paddingX12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _SummaryStat(
                    label: StringConstants.incoming,
                    amount: incoming,
                    icon: Icons.south_west_rounded,
                    accent: LightColor.brandTextColor,
                  ),
                ),
                VerticalDivider(
                  width: AppDimens.paddingX16,
                  thickness: 1,
                  color: LightColor.dividerColor,
                ),
                Expanded(
                  child: _SummaryStat(
                    label: StringConstants.outgoing,
                    amount: outgoing,
                    icon: Icons.north_east_rounded,
                    accent: LightColor.redColor,
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

/// How many transactions the active filters match, as a quiet pill.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.sizeX2,
      ),
      decoration: BoxDecoration(
        color: LightColor.sunkenColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        '$count ${StringConstants.transactions.toLowerCase()}',
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// One half of the in/out split: a tinted arrow, its label, and the total.
class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accent,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: AppDimens.sizeX18,
              height: AppDimens.sizeX18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusX6),
              ),
              child: Icon(icon, size: AppDimens.sizeX12, color: accent),
            ),
            const SizedBox(width: AppDimens.sizeX6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sizeX4),
        _FadeOnChange(
          child: Text(
            formatTransactionAmount(amount),
            key: ValueKey<double>(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
              fontFeatures: _tabularFigures,
            ),
          ),
        ),
      ],
    );
  }
}

/// Cross-fades its child whenever the child's key changes.
class _FadeOnChange extends StatelessWidget {
  const _FadeOnChange({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      // Both figures are single lines, so the outgoing one is not laid out
      // beside the incoming one.
      layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[...previous, if (current != null) current],
      ),
      child: child,
    );
  }
}

/// Search field plus the filter button.
class TransactionSearchBar extends StatelessWidget {
  const TransactionSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onOpenFilters,
    required this.activeFilterCount,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    final bool active = activeFilterCount > 0;
    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: AppDimens.sizeX44,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: FutsalTheme.getTextTheme(context).bodyTextSmall,
              decoration: InputDecoration(
                isDense: true,
                hintText: StringConstants.searchTransactions,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: AppDimens.sizeX18,
                  color: LightColor.secondaryTextColor,
                ),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: onClear,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.close_rounded,
                          size: AppDimens.sizeX16,
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                filled: true,
                fillColor: LightColor.elevatedCardColor,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  borderSide: BorderSide(color: LightColor.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  borderSide: BorderSide(color: LightColor.dividerColor),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.sizeX8),
        // Outlined rather than filled — a filter control should not compete
        // with the content it filters.
        OutlinedButton.icon(
          onPressed: onOpenFilters,
          icon: Icon(
            Icons.tune_rounded,
            size: AppDimens.sizeX16,
            color: active
                ? LightColor.secondaryColor
                : LightColor.secondaryTextColor,
          ),
          label: Text(
            active
                ? '${StringConstants.filters} ($activeFilterCount)'
                : StringConstants.filters,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: active
                  ? LightColor.secondaryColor
                  : LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            // Material pads the tap target to 48 by default, which overflows
            // the 44-high search row it sits in.
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(0, AppDimens.sizeX44),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX12,
            ),
            backgroundColor: LightColor.elevatedCardColor,
            side: BorderSide(
              color: active
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Quick-access date-range chips. `Custom` opens the filter sheet, where the
/// two dates are picked.
class TransactionRangeChips extends StatelessWidget {
  const TransactionRangeChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TransactionDateRange selected;
  final void Function(TransactionRangeFilter filter) onSelected;

  static const List<TransactionRangeFilter> _order = <TransactionRangeFilter>[
    TransactionRangeFilter.all,
    TransactionRangeFilter.today,
    TransactionRangeFilter.week,
    TransactionRangeFilter.month,
    TransactionRangeFilter.year,
    TransactionRangeFilter.custom,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _order.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimens.sizeX6),
        itemBuilder: (BuildContext context, int index) {
          final TransactionRangeFilter filter = _order[index];
          final bool isSelected = filter == selected.filter;
          return TransactionFilterChip(
            label: filter == TransactionRangeFilter.custom && isSelected
                ? transactionRangeLabel(selected)
                : _presetLabel(filter),
            selected: isSelected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }

  String _presetLabel(TransactionRangeFilter filter) => switch (filter) {
    TransactionRangeFilter.all => StringConstants.allTime,
    TransactionRangeFilter.today => StringConstants.today,
    TransactionRangeFilter.week => StringConstants.thisWeek,
    TransactionRangeFilter.month => StringConstants.thisMonth,
    TransactionRangeFilter.year => StringConstants.thisYear,
    TransactionRangeFilter.custom => StringConstants.customRange,
  };
}

/// Understated pill shared by the range row and the filter sheet: a tinted
/// outline when selected, plain surface otherwise.
class TransactionFilterChip extends StatelessWidget {
  const TransactionFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX6,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? LightColor.secondaryColor.withValues(alpha: 0.08)
                : LightColor.elevatedCardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            style:
                textTheme.bodyTextSmall?.copyWith(
                  color: selected
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ) ??
                const TextStyle(),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

/// Month label above each group of rows — an overline, so it reads as a
/// divider between blocks rather than as another row.
class TransactionSectionHeader extends StatelessWidget {
  const TransactionSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimens.paddingX20,
        bottom: AppDimens.paddingX10,
        left: AppDimens.paddingX4,
      ),
      child: Text(
        title.toUpperCase(),
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.hintTextColor,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// One statement row: description on the left, signed amount on the right.
///
/// Rows in a month sit on one continuous card, so [isFirst] / [isLast] round
/// only the outer edges of the group.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.item,
    this.onTap,
    this.showDivider = true,
    this.isFirst = true,
    this.isLast = true,
  });

  final TransactionHistoryItemModel item;
  final VoidCallback? onTap;

  /// The last row in a group drops its divider.
  final bool showDivider;

  final bool isFirst;
  final bool isLast;

  /// Icon width plus its gutter — dividers start where the text does.
  static const double _dividerIndent =
      AppDimens.paddingX14 + AppDimens.sizeX40 + AppDimens.sizeX12;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final Color amountColor = item.isIncoming
        ? LightColor.brandTextColor
        : LightColor.redColor;
    final BorderRadius radius = BorderRadius.vertical(
      top: Radius.circular(isFirst ? AppDimens.radiusX14 : 0),
      bottom: Radius.circular(isLast ? AppDimens.radiusX14 : 0),
    );

    return Material(
      color: LightColor.elevatedCardColor,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX14,
                vertical: AppDimens.paddingX14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _DirectionIcon(isIncoming: item.isIncoming),
                  const SizedBox(width: AppDimens.sizeX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextMedium?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sizeX4),
                        // Everything secondary on one muted line, so a row is
                        // two lines regardless of which fields the source
                        // carries.
                        Text(
                          _metaLine(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.secondaryTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                            height: 1.35,
                          ),
                        ),
                        // Colour is spent only on states that need attention;
                        // cleared and recorded rows stay entirely neutral.
                        if (item.statusLabel.isNotEmpty &&
                            _isNotable(item.status)) ...<Widget>[
                          const SizedBox(height: AppDimens.sizeX6),
                          _StatusBadge(
                            label: item.statusLabel,
                            color: transactionStatusColor(item.status),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX12),
                  Text(
                    '${item.isIncoming ? '+' : '−'}'
                    '${formatTransactionAmount(item.amount)}',
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                      fontFeatures: _tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              indent: _dividerIndent,
              color: LightColor.dividerColor,
            ),
        ],
      ),
    );
  }

  /// `02 Oct 2026 · BK-8ZYZNZLN · Dhananjay sport · Fee NPR 108`
  String _metaLine(TransactionHistoryItemModel item) => <String>[
    if (item.date != null) DateFormat('dd MMM yyyy').format(item.date!),
    if (item.reference != null && item.reference!.isNotEmpty) item.reference!,
    if (item.venueName != null && item.venueName!.isNotEmpty) item.venueName!,
    if (item.hasCommission)
      '${StringConstants.commission} '
          '${formatTransactionAmount(item.commissionAmount!)}',
  ].join(' · ');

  /// Settled rows need no status line; only exceptions do.
  bool _isNotable(String? status) =>
      transactionStatusColor(status) != LightColor.secondaryTextColor;
}

/// Exception states (pending, failed, refunded) as a tinted pill, so they read
/// as a badge on the row rather than as a third line of prose.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX6,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX4),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: color,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Money-in / money-out arrow.
///
/// Direction is carried three ways — this arrow, the amount's sign, and its
/// colour — so it survives both colour-blindness and a greyscale screenshot.
class _DirectionIcon extends StatelessWidget {
  const _DirectionIcon({required this.isIncoming});

  final bool isIncoming;

  @override
  Widget build(BuildContext context) {
    final Color accent = isIncoming
        ? LightColor.brandTextColor
        : LightColor.redColor;

    return Container(
      width: AppDimens.sizeX40,
      height: AppDimens.sizeX40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Icon(
        // Down-left into the account, up-right out of it.
        isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
        size: AppDimens.sizeX18,
        color: accent,
        semanticLabel: isIncoming
            ? StringConstants.incoming
            : StringConstants.outgoing,
      ),
    );
  }
}
