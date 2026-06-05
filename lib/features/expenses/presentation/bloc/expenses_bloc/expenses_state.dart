part of 'expenses_bloc.dart';

enum ExpensesStatus { initial, loading, success, failure }

final class ExpensesState extends Equatable {
  const ExpensesState({
    this.status = ExpensesStatus.initial,
    this.venues = const [],
    this.courts = const [],
    this.expenses = const [],
    this.errorMessage,
  });

  final ExpensesStatus status;
  final List<VenueModel> venues;
  final List<CourtModel> courts;
  final List<ExpenseModel> expenses;
  final String? errorMessage;

  ExpensesState copyWith({
    ExpensesStatus? status,
    List<VenueModel>? venues,
    List<CourtModel>? courts,
    List<ExpenseModel>? expenses,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ExpensesState(
      status: status ?? this.status,
      venues: venues ?? this.venues,
      courts: courts ?? this.courts,
      expenses: expenses ?? this.expenses,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, venues, courts, expenses, errorMessage];
}
