import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_model.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_report_model.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_chart_widgets.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_common.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_record_widgets.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_summary_widgets.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

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
        ExpenseSectionLabel(StringConstants.totalSpend),
        ExpenseHeroCard(report: report),
        const SizedBox(height: AppDimens.paddingX18),
        ExpenseSectionLabel(StringConstants.snapshot),
        ExpenseKpiGrid(report: report),
      ],
    );
  }
}

class ExpenseAnalyticsTab extends StatelessWidget {
  const ExpenseAnalyticsTab({
    super.key,
    required this.report,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  final ExpenseReport report;

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
        // Desktop: the trend and the category breakdown side by side, top
        // aligned; stacked on phones and tablets.
        if (context.isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ExpenseSectionLabel(StringConstants.trend),
                    ExpenseTrendCard(report: report),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ExpenseSectionLabel(StringConstants.byCategory),
                    ExpenseCategoryCard(
                      report: report,
                      selectedCategory: selectedCategory,
                      onSelect: onSelectCategory,
                    ),
                  ],
                ),
              ),
            ],
          )
        else ...[
          ExpenseSectionLabel(StringConstants.trend),
          ExpenseTrendCard(report: report),
          const SizedBox(height: AppDimens.paddingX18),
          ExpenseSectionLabel(StringConstants.byCategory),
          ExpenseCategoryCard(
            report: report,
            selectedCategory: selectedCategory,
            onSelect: onSelectCategory,
          ),
        ],
        if (report.byCourt.isNotEmpty) ...[
          const SizedBox(height: AppDimens.paddingX18),
          ExpenseSectionLabel(StringConstants.byCourt),
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
              categoryLabel == null
                  ? StringConstants.records
                  : StringConstants.recordsForCategory(categoryLabel!),
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
