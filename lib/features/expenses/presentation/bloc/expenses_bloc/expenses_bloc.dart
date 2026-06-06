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
    on<LoadVenueCourtsEvent>(_onLoadVenueCourts);
    on<LoadExpenseCategoriesEvent>(_onLoadCategories);
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAdd);
    on<DeleteExpenseEvent>(_onDelete);
    on<RestoreExpenseEvent>(_onRestore);
  }

  final ExpensesUseCase useCase;

  /// Venues and courts come from the single venue-court API.
  Future<void> _onLoadVenueCourts(
    LoadVenueCourtsEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(state.copyWith(venueCourtsStatus: ExpensesStatus.loading));
    final result = await useCase.getVenueCourts();
    result.fold(
      (failure) =>
          emit(state.copyWith(venueCourtsStatus: ExpensesStatus.failure)),
      (data) => emit(
        state.copyWith(
          venueCourtsStatus: ExpensesStatus.success,
          venues: data.venues,
          courts: data.courts,
        ),
      ),
    );
  }

  /// Categories come from their own API; the create form reads them straight
  /// from this state, so on failure the form offers a retry instead of
  /// falling back to static values.
  Future<void> _onLoadCategories(
    LoadExpenseCategoriesEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(state.copyWith(categoriesStatus: ExpensesStatus.loading));
    final result = await useCase.getCategories();
    result.fold(
      (failure) =>
          emit(state.copyWith(categoriesStatus: ExpensesStatus.failure)),
      (categories) => emit(
        state.copyWith(
          categoriesStatus: ExpensesStatus.success,
          categories: categories,
        ),
      ),
    );
  }

  /// The expenses list comes from the expenses API.
  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(
      state.copyWith(
        expensesStatus: ExpensesStatus.loading,
        clearErrorMessage: true,
      ),
    );
    final result = await useCase.getExpenses();
    result.fold(
      (failure) => emit(
        state.copyWith(
          expensesStatus: ExpensesStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (expenses) => emit(
        state.copyWith(
          expensesStatus: ExpensesStatus.success,
          expenses: expenses,
          clearErrorMessage: true,
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
