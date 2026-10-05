import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/date_time/app_date_format.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/dashboard_layout.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_model.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_report_model.dart';
import 'package:hamro_futsal/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_chart_widgets.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_common.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_summary_widgets.dart';

/// Widest the expenses dashboard grows before centring in the window.
const double kExpenseDashboardMaxWidth = 1280;

/// Tablet / desktop Expenses: one scrolling dashboard instead of the phone's
/// three tabs — header with the primary action, a filter bar, total spend
/// beside the KPI cards, the trend beside the category split, spend by court,
/// and the records as a table. Desktop pairs sections; tablet stacks them.
class ExpenseDashboard extends StatelessWidget {
  const ExpenseDashboard({
    super.key,
    required this.report,
    required this.records,
    this.venues = const <VenueModel>[],
    this.courts = const <CourtModel>[],
    required this.contextLine,
    required this.filters,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.categoryLabel,
    required this.hasFilters,
    required this.onAdd,
    required this.onTapRecord,
    required this.onClearFilters,
    this.isRefreshing = false,
  });

  final ExpenseReport report;
  final List<ExpenseModel> records;

  /// Name lookups for records the API returned without nested names.
  final List<VenueModel> venues;
  final List<CourtModel> courts;

  /// "Sep 28 – Oct 4 · 9 entries · NPR 12,300" under the title.
  final Widget contextLine;

  /// Period / method dropdowns, venue chips and category chips.
  final Widget filters;
  final String? selectedCategory;
  final ValueChanged<String?> onSelectCategory;
  final String? categoryLabel;
  final bool hasFilters;
  final VoidCallback onAdd;
  final ValueChanged<ExpenseModel> onTapRecord;
  final VoidCallback onClearFilters;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final bool desktop = context.isDesktop;
    final textTheme = FutsalTheme.getTextTheme(context);

    const Widget gap = SizedBox(height: AppDimens.paddingX24);

    return ListView(
      key: const PageStorageKey<String>('expenses_dashboard'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX24,
        AppDimens.paddingX16,
        AppDimens.paddingX24,
        AppDimens.paddingX40,
      ),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: kExpenseDashboardMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ── Header: title, summary, primary action ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Expenses',
                            style: textTheme.headingSmall?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppDimens.paddingX4),
                          contextLine,
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingX16),
                    SizedBox(
                      height: AppDimens.sizeX48,
                      child: CustomButton(
                        text: 'New expense',
                        icon: Icons.add_rounded,
                        minWidth: 150,
                        onPressed: onAdd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingX16),
                _FilterBar(isLoading: isRefreshing, child: filters),
                gap,

                // ── Snapshot: the four figures in one row ──
                const DashboardSectionLabel('Snapshot'),
                ExpenseKpiGrid(report: report, columns: 4),
                gap,

                // ── Total spend beside where it went by court ──
                if (report.byCourt.isNotEmpty)
                  DashboardPair(
                    stacked: !desktop,
                    leftLabel: 'Total spend',
                    left: ExpenseHeroCard(report: report),
                    rightLabel: 'By court',
                    right: ExpenseCourtCard(report: report),
                  )
                else ...<Widget>[
                  const DashboardSectionLabel('Total spend'),
                  ExpenseHeroCard(report: report),
                ],
                gap,

                // ── Trend beside the category split, equal heights ──
                DashboardPair(
                  stacked: !desktop,
                  leftLabel: 'Trend',
                  left: ExpenseTrendCard(report: report),
                  rightLabel: 'By category',
                  right: ExpenseCategoryCard(
                    report: report,
                    selectedCategory: selectedCategory,
                    onSelect: onSelectCategory,
                  ),
                ),
                gap,

                // ── Records ──
                DashboardSectionLabel(
                  categoryLabel == null
                      ? 'Records'
                      : 'Records · $categoryLabel',
                ),
                records.isEmpty
                    ? ExpenseEmptyState(
                        title: hasFilters
                            ? 'No matching records'
                            : 'No records yet',
                        message: hasFilters
                            ? 'Try a different period, venue or category.'
                            : 'Expenses you add will show up here.',
                        actionLabel: hasFilters
                            ? 'Clear filters'
                            : 'Add expense',
                        onAction: hasFilters ? onClearFilters : onAdd,
                      )
                    : _RecordsTable(
                        records: records,
                        venues: venues,
                        courts: courts,
                        onTap: onTapRecord,
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.child, required this.isLoading});

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            child: child,
          ),
          SizedBox(
            height: 2,
            child: isLoading
                ? const LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    color: LightColor.secondaryColor,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Records as a table: date, category, description, where, method, amount.
/// A row opens the expense, as a card does on the phone.
class _RecordsTable extends StatelessWidget {
  const _RecordsTable({
    required this.records,
    required this.venues,
    required this.courts,
    required this.onTap,
  });

  final List<ExpenseModel> records;
  final List<VenueModel> venues;
  final List<CourtModel> courts;
  final ValueChanged<ExpenseModel> onTap;

  static const int _fDate = 2;
  static const int _fCategory = 3;
  static const int _fDescription = 4;
  static const int _fWhere = 3;
  static const int _fMethod = 2;
  static const int _fAmount = 2;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final TextStyle? head = textTheme.bodyMiniSubTitle?.copyWith(
      color: LightColor.hintTextColor,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    Widget headCell(String t, int flex, {TextAlign align = TextAlign.start}) =>
        Expanded(
          flex: flex,
          child: Text(t.toUpperCase(), textAlign: align, style: head),
        );

    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: LightColor.inputFillColor,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX16,
              vertical: AppDimens.paddingX10,
            ),
            child: Row(
              children: <Widget>[
                headCell('Date', _fDate),
                headCell('Category', _fCategory),
                headCell('Description', _fDescription),
                headCell('Venue · Court', _fWhere),
                headCell('Method', _fMethod),
                headCell('Amount', _fAmount, align: TextAlign.end),
              ],
            ),
          ),
          for (int i = 0; i < records.length; i++) ...<Widget>[
            if (i > 0) Divider(height: 1, color: LightColor.dividerColor),
            _RecordRow(
              expense: records[i],
              venueName:
                  records[i].venueName ??
                  venues
                      .where((VenueModel v) => v.id == records[i].venueId)
                      .firstOrNull
                      ?.name,
              courtName:
                  records[i].courtName ??
                  courts
                      .where((CourtModel c) => c.id == records[i].courtId)
                      .firstOrNull
                      ?.name,
              date: AppDateFormat.format(records[i].date, 'd MMM y'),
              onTap: () => onTap(records[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordRow extends StatefulWidget {
  const _RecordRow({
    required this.expense,
    this.venueName,
    this.courtName,
    required this.date,
    required this.onTap,
  });

  final ExpenseModel expense;
  final String? venueName;
  final String? courtName;
  final String date;
  final VoidCallback onTap;

  @override
  State<_RecordRow> createState() => _RecordRowState();
}

class _RecordRowState extends State<_RecordRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final ExpenseModel e = widget.expense;
    final String category = e.categoryDetail?.name.trim().isNotEmpty == true
        ? e.categoryDetail!.name.trim()
        : e.category.label;
    final String description = <String>[
      e.vendor.trim(),
      (e.note ?? '').trim(),
    ].firstWhere((String s) => s.isNotEmpty, orElse: () => '—');
    final String where = <String>[
      (widget.venueName ?? '').trim(),
      (widget.courtName ?? '').trim(),
    ].where((String s) => s.isNotEmpty).join(' · ');
    final TextStyle? body = textTheme.bodyTextSmall?.copyWith(
      color: LightColor.primaryTextColor,
    );
    final TextStyle? muted = textTheme.bodyTextSmall?.copyWith(
      color: LightColor.secondaryTextColor,
    );

    Widget cell(String t, int flex, TextStyle? style) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: AppDimens.paddingX8),
        child: Text(
          t,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: _hover
            ? LightColor.secondaryColor.withValues(alpha: 0.04)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX16,
              vertical: AppDimens.paddingX14,
            ),
            child: Row(
              children: <Widget>[
                cell(widget.date, _RecordsTable._fDate, muted),
                Expanded(
                  flex: _RecordsTable._fCategory,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: e.category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX8),
                      Expanded(
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                cell(description, _RecordsTable._fDescription, body),
                cell(where.isEmpty ? '—' : where, _RecordsTable._fWhere, muted),
                cell(e.method.label, _RecordsTable._fMethod, muted),
                Expanded(
                  flex: _RecordsTable._fAmount,
                  child: Text(
                    '- ${ExpenseFmt.npr(e.amount)}',
                    textAlign: TextAlign.end,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.redColor,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
