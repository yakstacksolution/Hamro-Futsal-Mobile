import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_model.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_report_model.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_chart_widgets.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_common.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_record_widgets.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_summary_widgets.dart';

/// "How am I doing?" — hero total + KPI snapshot, straight from the
/// server-computed [ExpenseReport.summary].
class ExpenseOverviewTab extends StatelessWidget {
  const ExpenseOverviewTab({super.key, required this.report});

  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('expenses_overview'),
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        top: AppDimens.paddingX4,
        bottom: AppDimens.paddingX20,
      ),
      children: [
        ExpenseSectionLabel('Total spend'),
        ExpenseHeroCard(report: report),
        const SizedBox(height: AppDimens.paddingX18),
        ExpenseSectionLabel('Snapshot'),
        ExpenseKpiGrid(report: report),
      ],
    );
  }
}

/// "Where is money going?" — trend chart + category breakdown, from the
/// server-computed [ExpenseReport.trend] and [ExpenseReport.byCategory].
class ExpenseAnalyticsTab extends StatelessWidget {
  const ExpenseAnalyticsTab({
    super.key,
    required this.report,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  final ExpenseReport report;

  /// Selected server category id (client-side highlight only).
  final String? selectedCategory;
  final ValueChanged<String?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('expenses_analytics'),
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        top: AppDimens.paddingX4,
        bottom: AppDimens.paddingX20,
      ),
      children: [
        ExpenseSectionLabel('Trend'),
        ExpenseTrendCard(report: report),
        const SizedBox(height: AppDimens.paddingX18),
        ExpenseSectionLabel('By category'),
        ExpenseCategoryCard(
          report: report,
          selectedCategory: selectedCategory,
          onSelect: onSelectCategory,
        ),
        if (report.byCourt.isNotEmpty) ...[
          const SizedBox(height: AppDimens.paddingX18),
          ExpenseSectionLabel('By court'),
          ExpenseCourtCard(report: report),
        ],
      ],
    );
  }
}

class ExpenseRecordsTab extends StatelessWidget {
  const ExpenseRecordsTab({
    super.key,
    required this.expenses,
    required this.venues,
    this.courts = const [],
    required this.categoryLabel,
    required this.hasFilters,
    required this.onTap,
    required this.onAdd,
    required this.onClearFilters,
  });

  final List<ExpenseModel> expenses;
  final List<VenueModel> venues;
  final List<CourtModel> courts;

  final String? categoryLabel;
  final bool hasFilters;
  final ValueChanged<ExpenseModel> onTap;
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
            child: ExpenseSectionLabel(
              categoryLabel == null ? 'Records' : 'Records · $categoryLabel',
            ),
          ),
        ),
        ExpenseRecordsSliver(
          expenses: expenses,
          venues: venues,
          courts: courts,
          hasFilters: hasFilters,
          onTap: onTap,
          onAdd: onAdd,
          onClearFilters: onClearFilters,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.paddingX20)),
      ],
    );
  }
}
