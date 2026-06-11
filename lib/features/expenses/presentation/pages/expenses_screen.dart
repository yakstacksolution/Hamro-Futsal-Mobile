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
import 'package:hamro_footsall/features/expenses/presentation/models/expense_filter.dart';
import 'package:hamro_footsall/features/expenses/presentation/pages/create_expense_page.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_date_range_sheet.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_details_sheet.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_filter_widgets.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_tabs.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expenses_page_loading_widget.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpensesBloc(ExpensesUseCase(ExpensesRepositoryImpl()))
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

  /// Cash / Online (null = all). Server-side `payment_method` filter.
  PaymentMethod? _paymentMethod;

  /// Selected server category id (from `/expense-categories`). Applied
  /// client-side to the Records list — the API has no category filter.
  String? _categoryFilter;
  DateTimeRange? _customRange;

  /// Builds the server query from the current chips and refetches so the
  /// server recomputes the summary, analytics and records.
  void _applyFilter() {
    final f = ExpenseFilter(
      period: _period,
      customRange: _period == ExpensePeriod.custom && _customRange != null
          ? (start: _customRange!.start, end: _customRange!.end)
          : null,
      venueId: _venueId,
      paymentMethod: _paymentMethod,
    );
    // Silent: keep the chips and current data on screen while the server
    // recomputes, instead of flashing the full-page loader on every tap.
    context.read<ExpensesBloc>().add(LoadExpensesEvent(filter: f, silent: true));
  }

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
    final picked = await ExpenseDateRangeSheet.show(
      context,
      initialRange: _customRange,
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _period = ExpensePeriod.custom;
      });
      _applyFilter();
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
        child: BlocConsumer<ExpensesBloc, ExpensesState>(
          // Mutation failures (e.g. create-expense API errors) only set
          // errorMessage — surface them as a snack so they aren't silent.
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage,
          listener: (context, state) => AppUtils().showSnackBar(
            context,
            MsgType.error,
            state.errorMessage!,
          ),
          builder: (context, state) {
            if (state.expensesStatus == ExpensesStatus.initial ||
                state.expensesStatus == ExpensesStatus.loading) {
              return const ExpensesPageLoadingWidget();
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
    final report = state.report;

    // Category is the only client-side filter (the API has no category
    // param): it narrows the Records list and highlights the breakdown.
    final records = _categoryFilter == null
        ? state.expenses
        : state.expenses
              .where((e) => e.categoryId == _categoryFilter)
              .toList();

    final hasFilters =
        _categoryFilter != null ||
        _venueId != null ||
        _paymentMethod != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                count: report.summary.entries,
                total: report.summary.totalSpend,
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
                    _applyFilter();
                  }
                },
                onEditCustom: _pickRange,
              ),
              const SizedBox(height: AppDimens.paddingX10),
              ExpenseVenueFilter(
                venues: state.venues,
                selectedId: _venueId,
                onChange: (id) {
                  setState(() => _venueId = id);
                  _applyFilter();
                },
              ),
              const SizedBox(height: AppDimens.paddingX10),
              ExpensePaymentFilter(
                selected: _paymentMethod,
                onChange: (m) {
                  setState(() => _paymentMethod = m);
                  _applyFilter();
                },
              ),
              const SizedBox(height: AppDimens.paddingX10),
              ExpenseCategoryFilterRow(
                categories: state.categories,
                selected: _categoryFilter,
                onChange: (c) => setState(() => _categoryFilter = c),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingX8),
        // Slim refresh bar — fades in during a silent filter refetch so the
        // chips and current data stay put instead of flashing a full loader.
        SizedBox(
          height: 2,
          child: AnimatedOpacity(
            opacity: state.refreshing ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(LightColor.secondaryColor),
            ),
          ),
        ),
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
        const SizedBox(height: AppDimens.paddingX12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Each tab cross-fades when fresh data lands (keyed on
              // reportVersion), so switching filters glides instead of jumping.
              _fadeOnRefresh(
                key: ValueKey('overview-${state.reportVersion}'),
                child: ExpenseOverviewTab(report: report),
              ),
              _fadeOnRefresh(
                key: ValueKey('analytics-${state.reportVersion}'),
                child: ExpenseAnalyticsTab(
                  report: report,
                  selectedCategory: _categoryFilter,
                  onSelectCategory: (c) => setState(() => _categoryFilter = c),
                ),
              ),
              _fadeOnRefresh(
                // Also re-keyed on the client-side category filter.
                key: ValueKey(
                  'records-${state.reportVersion}-$_categoryFilter',
                ),
                child: ExpenseRecordsTab(
                  expenses: records,
                  venues: state.venues,
                  courts: state.courts,
                  categoryLabel: _categoryFilter == null
                      ? null
                      : state.categories
                            .where((c) => c.id == _categoryFilter)
                            .firstOrNull
                            ?.name,
                  hasFilters: hasFilters,
                  onTap: _showExpenseDetails,
                  onAdd: _openCreate,
                  onClearFilters: () {
                    setState(() {
                      _categoryFilter = null;
                      _venueId = null;
                      _paymentMethod = null;
                    });
                    _applyFilter();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Cross-fades [child] whenever its [key] changes (i.e. when a new report
  /// arrives or the category filter changes), with a slight upward drift for
  /// a polished settle-in.
  Widget _fadeOnRefresh({required Key key, required Widget child}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (c, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(anim),
          child: c,
        ),
      ),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      child: KeyedSubtree(key: key, child: child),
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
    AppUtils().showSnackBar(
      context,
      MsgType.success,
      'Expense added · ${ExpenseFmt.npr(created.amount)}',
    );
  }

  Future<void> _showExpenseDetails(ExpenseModel expense) async {
    final bloc = context.read<ExpensesBloc>();
    // Names come straight from the API response when present.
    final venueName =
        expense.venueName ??
        bloc.state.venues
            .firstWhere(
              (v) => v.id == expense.venueId,
              orElse: () => const VenueModel(id: '?', name: '—'),
            )
            .name;
    final courtName =
        expense.courtName ??
        (expense.courtId == null
            ? null
            : bloc.state.courts
                  .where((c) => c.id == expense.courtId)
                  .firstOrNull
                  ?.name);
    final action = await showModalBottomSheet<String>(
      context: context,
      // The sheet can grow tall when a document image is attached.
      isScrollControlled: true,
      backgroundColor: LightColor.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX20),
        ),
      ),
      // Share the bloc so the sheet can render the API category image.
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: ExpenseDetailsSheet(
          expense: expense,
          venueName: venueName,
          courtName: courtName,
        ),
      ),
    );
    if (!mounted) return;
    if (action == ExpenseDetailsSheet.editAction) {
      await _openEdit(expense);
    } else if (action == ExpenseDetailsSheet.deleteAction) {
      bloc.add(DeleteExpenseEvent(expense));
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'Expense deleted · ${ExpenseFmt.npr(expense.amount)}',
      );
    }
  }

  /// Opens the create form prefilled with [expense] and applies the edits.
  Future<void> _openEdit(ExpenseModel expense) async {
    final bloc = context.read<ExpensesBloc>();
    final venues = bloc.state.venues;
    if (venues.isEmpty) return;
    final updated = await Navigator.of(context).push<CreateExpenseEntity>(
      MaterialPageRoute<CreateExpenseEntity>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CreateExpensePage(
            venues: venues,
            courts: bloc.state.courts,
            initial: expense,
          ),
        ),
      ),
    );
    if (updated == null || !mounted) return;
    bloc.add(UpdateExpenseEvent(expense.id, updated));
    AppUtils().showSnackBar(
      context,
      MsgType.success,
      'Expense updated · ${ExpenseFmt.npr(updated.amount)}',
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
