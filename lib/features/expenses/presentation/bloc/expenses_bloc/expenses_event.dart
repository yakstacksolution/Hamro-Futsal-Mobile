part of 'expenses_bloc.dart';

sealed class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads venues and their courts (single venue-court API).
final class LoadVenueCourtsEvent extends ExpensesEvent {
  const LoadVenueCourtsEvent();
}

/// Loads expense categories (categories API).
final class LoadExpenseCategoriesEvent extends ExpensesEvent {
  const LoadExpenseCategoriesEvent();
}

/// Loads the expenses list (expenses API).
///
/// With [silent] the list is refreshed in the background — no loading
/// spinner and no failure screen; used to re-sync after a mutation.
final class LoadExpensesEvent extends ExpensesEvent {
  const LoadExpensesEvent({this.silent = false});
  final bool silent;

  @override
  List<Object?> get props => [silent];
}

final class AddExpenseEvent extends ExpensesEvent {
  const AddExpenseEvent(this.expense);
  final CreateExpenseEntity expense;

  @override
  List<Object?> get props => [expense];
}

/// Replaces the expense with [id] using the edited form values.
final class UpdateExpenseEvent extends ExpensesEvent {
  const UpdateExpenseEvent(this.id, this.expense);
  final String id;
  final CreateExpenseEntity expense;

  @override
  List<Object?> get props => [id, expense];
}

final class DeleteExpenseEvent extends ExpensesEvent {
  const DeleteExpenseEvent(this.expense);
  final ExpenseModel expense;

  @override
  List<Object?> get props => [expense];
}

final class RestoreExpenseEvent extends ExpensesEvent {
  const RestoreExpenseEvent(this.expense);
  final ExpenseModel expense;

  @override
  List<Object?> get props => [expense];
}
