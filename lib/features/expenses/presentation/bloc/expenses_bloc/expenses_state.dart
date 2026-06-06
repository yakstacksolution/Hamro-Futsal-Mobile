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
  final String? errorMessage;

  ExpensesState copyWith({
    ExpensesStatus? venueCourtsStatus,
    ExpensesStatus? categoriesStatus,
    ExpensesStatus? expensesStatus,
    List<VenueModel>? venues,
    List<CourtModel>? courts,
    List<ExpenseCategoryModel>? categories,
    List<ExpenseModel>? expenses,
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
    errorMessage,
  ];
}
