import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_model.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_report_model.dart';
import 'package:hamro_futsal/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_futsal/features/expenses/domain/usecase/expenses_usecase.dart';
import 'package:hamro_futsal/features/expenses/presentation/models/expense_filter.dart';

part 'expenses_event.dart';
part 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  ExpensesBloc(this.useCase) : super(const ExpensesState()) {
    on<LoadVenueCourtsEvent>(_onLoadVenueCourts);
    on<LoadExpenseCategoriesEvent>(_onLoadCategories);
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAdd);
    on<UpdateExpenseEvent>(_onUpdate);
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

  /// The server-computed report (summary + analytics + records) comes from
  /// the expenses API, scoped by the current [ExpenseFilter]. Changing a
  /// filter re-dispatches this event with the new filter so the server
  /// recomputes everything.
  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    final filter = event.filter ?? state.filter;
    if (!event.silent) {
      emit(
        state.copyWith(
          filter: filter,
          expensesStatus: ExpensesStatus.loading,
          clearErrorMessage: true,
        ),
      );
    } else {
      // Keep the current data on screen and flag the slim refresh bar; the
      // chip selection updates instantly, the content cross-fades on arrival.
      emit(state.copyWith(filter: filter, refreshing: true));
    }
    final result = await useCase.getExpenses(filter.toQuery());
    result.fold(
      (failure) => emit(
        // A failed silent refresh keeps the current data on screen.
        event.silent
            ? state.copyWith(
                refreshing: false,
                errorMessage: failure.errorMessage,
              )
            : state.copyWith(
                expensesStatus: ExpensesStatus.failure,
                errorMessage: failure.errorMessage,
              ),
      ),
      (report) => emit(
        state.copyWith(
          expensesStatus: ExpensesStatus.success,
          refreshing: false,
          report: report,
          reportVersion: state.reportVersion + 1,
          expenses: report.records,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  /// Creates the expense, then immediately reflects it in [ExpensesState]
  /// so overview, analytics and records update at once — followed by a
  /// silent refetch to reconcile with the server's canonical record.
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
        emit(
          state.copyWith(
            // Ensure the list is visible even if the very first load had
            // failed before this create succeeded.
            expensesStatus: ExpensesStatus.success,
            expenses: expenses,
            clearErrorMessage: true,
          ),
        );
        // Background re-sync: replaces the optimistic entry with the
        // server's version (real id, server-side category fields).
        add(const LoadExpensesEvent(silent: true));
      },
    );
  }

  Future<void> _onUpdate(
    UpdateExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    final result = await useCase.updateExpense(event.id, event.expense);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (updated) {
        final expenses =
            state.expenses.map((e) => e.id == updated.id ? updated : e).toList()
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
