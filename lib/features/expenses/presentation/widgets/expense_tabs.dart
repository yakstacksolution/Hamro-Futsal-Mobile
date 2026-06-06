import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/models/expense_analytics.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_chart_widgets.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_record_widgets.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_summary_widgets.dart';

/// "How am I doing?" — hero total + KPI snapshot.
class ExpenseOverviewTab extends StatelessWidget {
  const ExpenseOverviewTab({
    super.key,
    required this.analytics,
    required this.venues,
  });

  final ExpenseAnalytics analytics;
  final List<VenueModel> venues;

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
        ExpenseHeroCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        ExpenseSectionLabel('Snapshot'),
        ExpenseKpiGrid(analytics: analytics, venues: venues),
      ],
    );
  }
}

/// "Where is money going?" — trend chart + category breakdown.
class ExpenseAnalyticsTab extends StatelessWidget {
  const ExpenseAnalyticsTab({
    super.key,
    required this.analytics,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  final ExpenseAnalytics analytics;

  /// Selected server category id.
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
        ExpenseTrendCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        ExpenseSectionLabel('By category'),
        ExpenseCategoryCard(
          analytics: analytics,
          selectedCategory: selectedCategory,
          onSelect: onSelectCategory,
        ),
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
