import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_footsall/features/expenses/domain/usecase/expenses_usecase.dart';
import 'package:hamro_footsall/features/expenses/presentation/bloc/expenses_bloc/expenses_bloc.dart';
import 'package:hamro_footsall/features/expenses/presentation/models/expense_analytics.dart';
import 'package:hamro_footsall/features/expenses/presentation/pages/create_expense_page.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_details_sheet.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_filter_widgets.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_tabs.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ExpensesBloc(ExpensesUseCase(ExpensesRepositoryImpl()))
            ..add(const LoadVenueCourtsEvent())
            ..add(const LoadExpenseCategoriesEvent())
            ..add(const LoadExpensesEvent()),
      child: const _ExpensesView(),
    );
  }
}

class _ExpensesView extends StatefulWidget {
  const _ExpensesView();

  @override
  State<_ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<_ExpensesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  ExpensePeriod _period = ExpensePeriod.week;
  String? _venueId;
  ExpenseCategory? _categoryFilter;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ExpenseRange _resolvedRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case ExpensePeriod.today:
        return ExpenseRange(today, today.add(const Duration(days: 1)));
      case ExpensePeriod.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return ExpenseRange(start, start.add(const Duration(days: 7)));
      case ExpensePeriod.month:
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 1);
        return ExpenseRange(start, end);
      case ExpensePeriod.year:
        final start = DateTime(today.year, 1, 1);
        final end = DateTime(today.year + 1, 1, 1);
        return ExpenseRange(start, end);
      case ExpensePeriod.custom:
        final r = _customRange;
        if (r == null) {
          final start = today.subtract(const Duration(days: 13));
          return ExpenseRange(start, today.add(const Duration(days: 1)));
        }
        return ExpenseRange(
          DateTime(r.start.year, r.start.month, r.start.day),
          DateTime(
            r.end.year,
            r.end.month,
            r.end.day,
          ).add(const Duration(days: 1)),
        );
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          _customRange ??
          DateTimeRange(
            start: today.subtract(const Duration(days: 13)),
            end: today,
          ),
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: LightColor.secondaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _period = ExpensePeriod.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Expenses'),

      floatingActionButton: SizedBox(
        height: 44,
        child: FloatingActionButton.extended(
          onPressed: _openCreate,
          backgroundColor: LightColor.secondaryColor,
          foregroundColor: LightColor.whiteColor,
          elevation: 0,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(
            'New Expense',
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.whiteColor,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ExpensesBloc, ExpensesState>(
          builder: (context, state) {
            if (state.expensesStatus == ExpensesStatus.initial ||
                state.expensesStatus == ExpensesStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: LightColor.secondaryColor,
                ),
              );
            }
            if (state.expensesStatus == ExpensesStatus.failure &&
                state.expenses.isEmpty) {
              return _LoadError(
                message: state.errorMessage ?? 'Could not load expenses.',
                onRetry: () => context.read<ExpensesBloc>()
                  ..add(const LoadVenueCourtsEvent())
                  ..add(const LoadExpensesEvent()),
              );
            }
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExpensesState state) {
    final range = _resolvedRange();
    final analytics = ExpenseAnalytics(
      expenses: state.expenses,
      period: _period,
      range: range,
      venueFilter: _venueId,
      categoryFilter: _categoryFilter,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Shared filters — pinned above the tabs so they apply everywhere.
        Padding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX20,
            top: AppDimens.paddingX4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExpenseContextLine(
                range: range,
                count: analytics.count,
                total: analytics.total,
              ),
              const SizedBox(height: AppDimens.paddingX12),
              ExpensePeriodChips(
                period: _period,
                customRange: _customRange,
                onPeriod: (p) {
                  if (p == ExpensePeriod.custom) {
                    _pickRange();
                  } else {
                    setState(() => _period = p);
                  }
                },
                onEditCustom: _pickRange,
              ),
              const SizedBox(height: AppDimens.paddingX10),
              ExpenseVenueFilter(
                venues: state.venues,
                selectedId: _venueId,
                onChange: (id) => setState(() => _venueId = id),
              ),
              const SizedBox(height: AppDimens.paddingX10),
              // Category filter is shared — it scopes every tab
              // (totals, KPIs, charts and records) consistently.
              ExpenseCategoryFilterRow(
                selected: _categoryFilter,
                onChange: (c) => setState(() => _categoryFilter = c),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingX8),
        TabBar(
          controller: _tabController,
          labelColor: LightColor.secondaryColor,
          unselectedLabelColor: LightColor.secondaryTextColor,
          indicatorColor: LightColor.secondaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: LightColor.dividerColor,
          labelStyle: FutsalTheme.getTextTheme(
            context,
          ).bodyTextSmall?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: FutsalTheme.getTextTheme(
            context,
          ).bodyTextSmall?.copyWith(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Overview', height: 40),
            Tab(text: 'Analytics', height: 40),
            Tab(text: 'Records', height: 40),
          ],
        ),
        // Breathing room between the tab bar and tab content.
        const SizedBox(height: AppDimens.paddingX12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ExpenseOverviewTab(analytics: analytics, venues: state.venues),
              ExpenseAnalyticsTab(
                analytics: analytics,
                selectedCategory: _categoryFilter,
                onSelectCategory: (c) => setState(() => _categoryFilter = c),
              ),
              ExpenseRecordsTab(
                expenses: analytics.scoped,
                venues: state.venues,
                categoryFilter: _categoryFilter,
                hasFilters: _categoryFilter != null || _venueId != null,
                onTap: _showExpenseDetails,
                onAdd: _openCreate,
                onClearFilters: () => setState(() {
                  _categoryFilter = null;
                  _venueId = null;
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openCreate() async {
    final bloc = context.read<ExpensesBloc>();
    final venues = bloc.state.venues;
    if (venues.isEmpty) return;
    final created = await Navigator.of(context).push<CreateExpenseEntity>(
      MaterialPageRoute<CreateExpenseEntity>(
        // Share the bloc with the new route so the category dropdown can
        // read (and retry) the expense categories fetched from the API.
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CreateExpensePage(venues: venues, courts: bloc.state.courts),
        ),
      ),
    );
    if (created == null || !mounted) return;
    bloc.add(AddExpenseEvent(created));
    _showSnack(
      'Expense added · ${ExpenseFmt.npr(created.amount)}',
      background: LightColor.secondaryColor,
    );
  }

  Future<void> _showExpenseDetails(ExpenseModel expense) async {
    final bloc = context.read<ExpensesBloc>();
    final venueName = bloc.state.venues
        .firstWhere(
          (v) => v.id == expense.venueId,
          orElse: () => const VenueModel(id: '?', name: '—'),
        )
        .name;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: LightColor.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX20),
        ),
      ),
      builder: (_) =>
          ExpenseDetailsSheet(expense: expense, venueName: venueName),
    );
    if (action == ExpenseDetailsSheet.deleteAction && mounted) {
      bloc.add(DeleteExpenseEvent(expense));
      _showSnack(
        'Expense deleted · ${ExpenseFmt.npr(expense.amount)}',
        background: LightColor.redColor,
        action: SnackBarAction(
          label: 'Undo',
          textColor: LightColor.whiteColor,
          onPressed: () => bloc.add(RestoreExpenseEvent(expense)),
        ),
      );
    }
  }

  void _showSnack(
    String message, {
    required Color background,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.whiteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          margin: const EdgeInsets.all(AppDimens.paddingX16),
          duration: action == null
              ? const Duration(seconds: 2)
              : const Duration(seconds: 4),
          action: action,
        ),
      );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: LightColor.iconGrey,
            ),
            const SizedBox(height: AppDimens.paddingX12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: LightColor.secondaryColor,
                side: const BorderSide(color: LightColor.secondaryColor),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
