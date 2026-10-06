part of 'expenses_bloc.dart';

sealed class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadVenueCourtsEvent extends ExpensesEvent {
  const LoadVenueCourtsEvent();
}

final class LoadExpenseCategoriesEvent extends ExpensesEvent {
  const LoadExpenseCategoriesEvent();
}

final class LoadExpensesEvent extends ExpensesEvent {
  const LoadExpensesEvent({this.silent = false, this.filter});
  final bool silent;
  final ExpenseFilter? filter;

  @override
  List<Object?> get props => [silent, filter];
}

final class AddExpenseEvent extends ExpensesEvent {
  const AddExpenseEvent(this.expense);
  final CreateExpenseEntity expense;

  @override
  List<Object?> get props => [expense];
}

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
