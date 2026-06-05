part of 'expenses_bloc.dart';

sealed class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadExpensesEvent extends ExpensesEvent {
  const LoadExpensesEvent();
}

final class AddExpenseEvent extends ExpensesEvent {
  const AddExpenseEvent(this.expense);
  final CreateExpenseEntity expense;

  @override
  List<Object?> get props => [expense];
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
