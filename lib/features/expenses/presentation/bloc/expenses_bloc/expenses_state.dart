part of 'expenses_bloc.dart';

enum ExpensesStatus { initial, loading, success, failure }

final class ExpensesState extends Equatable {
  const ExpensesState({
    this.venueCourtsStatus = ExpensesStatus.initial,
    this.categoriesStatus = ExpensesStatus.initial,
    this.expensesStatus = ExpensesStatus.initial,
    this.venues = const [],
    this.courts = const [],
    this.categories = const [],
    this.expenses = const [],
    this.report = ExpenseReport.empty,
    this.filter = const ExpenseFilter(),
    this.refreshing = false,
    this.reportVersion = 0,
    this.errorMessage,
  });

  /// Venues + courts come from one API, categories from another and the
  /// expenses list from a third — each fetch tracks its own status so a
  /// failure in one never blocks the others.
  final ExpensesStatus venueCourtsStatus;
  final ExpensesStatus categoriesStatus;
  final ExpensesStatus expensesStatus;
  final List<VenueModel> venues;
  final List<CourtModel> courts;
  final List<ExpenseCategoryModel> categories;
  final List<ExpenseModel> expenses;

  /// Server-computed summary + analytics for the Overview/Analytics tabs.
  final ExpenseReport report;

  /// The active server-side filter (date_filter, venue, payment method).
  final ExpenseFilter filter;

  /// True while a silent filter refetch is in flight — drives the slim
  /// refresh bar without tearing down the current data.
  final bool refreshing;

  /// Bumped on every successful load so the UI can cross-fade content
  /// exactly when fresh data arrives (not when the filter chip is tapped).
  final int reportVersion;
  final String? errorMessage;

  ExpensesState copyWith({
    ExpensesStatus? venueCourtsStatus,
    ExpensesStatus? categoriesStatus,
    ExpensesStatus? expensesStatus,
    List<VenueModel>? venues,
    List<CourtModel>? courts,
    List<ExpenseCategoryModel>? categories,
    List<ExpenseModel>? expenses,
    ExpenseReport? report,
    ExpenseFilter? filter,
    bool? refreshing,
    int? reportVersion,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ExpensesState(
      venueCourtsStatus: venueCourtsStatus ?? this.venueCourtsStatus,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      expensesStatus: expensesStatus ?? this.expensesStatus,
      venues: venues ?? this.venues,
      courts: courts ?? this.courts,
      categories: categories ?? this.categories,
      expenses: expenses ?? this.expenses,
      report: report ?? this.report,
      filter: filter ?? this.filter,
      refreshing: refreshing ?? this.refreshing,
      reportVersion: reportVersion ?? this.reportVersion,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    venueCourtsStatus,
    categoriesStatus,
    expensesStatus,
    venues,
    courts,
    categories,
    expenses,
    report,
    filter,
    refreshing,
    reportVersion,
    errorMessage,
  ];
}
