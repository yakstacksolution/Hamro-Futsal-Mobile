import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_footsall/features/expenses/domain/usecase/expenses_usecase.dart';

part 'expenses_event.dart';
part 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  ExpensesBloc(this.useCase) : super(const ExpensesState()) {
    on<LoadExpensesEvent>(_onLoad);
    on<AddExpenseEvent>(_onAdd);
    on<DeleteExpenseEvent>(_onDelete);
    on<RestoreExpenseEvent>(_onRestore);
  }

  final ExpensesUseCase useCase;

  Future<void> _onLoad(
    LoadExpensesEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(
      state.copyWith(status: ExpensesStatus.loading, clearErrorMessage: true),
    );
    final venuesResult = await useCase.getVenues();
    final courtsResult = await useCase.getCourts();
    final expensesResult = await useCase.getExpenses();
    venuesResult.fold(
      (failure) => emit(
        state.copyWith(
          status: ExpensesStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (venues) => courtsResult.fold(
        (failure) => emit(
          state.copyWith(
            status: ExpensesStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        ),
        (courts) => expensesResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ExpensesStatus.failure,
              errorMessage: failure.errorMessage,
            ),
          ),
          (expenses) => emit(
            state.copyWith(
              status: ExpensesStatus.success,
              venues: venues,
              courts: courts,
              expenses: expenses,
              clearErrorMessage: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onAdd(
    AddExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    final result = await useCase.addExpense(event.expense);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (expense) {
        final expenses = [...state.expenses, expense]
          ..sort((a, b) => b.date.compareTo(a.date));
        emit(state.copyWith(expenses: expenses, clearErrorMessage: true));
      },
    );
  }

  Future<void> _onDelete(
    DeleteExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    final result = await useCase.deleteExpense(event.expense.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (_) => emit(
        state.copyWith(
          expenses: state.expenses
              .where((e) => e.id != event.expense.id)
              .toList(),
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onRestore(
    RestoreExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    final result = await useCase.restoreExpense(event.expense);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (_) {
        final expenses = [...state.expenses, event.expense]
          ..sort((a, b) => b.date.compareTo(a.date));
        emit(state.copyWith(expenses: expenses, clearErrorMessage: true));
      },
    );
  }
}
