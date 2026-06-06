import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_footsall/features/expenses/domain/repository/expenses_repository.dart';

final class ExpensesUseCase {
  const ExpensesUseCase(this.repository);

  final ExpensesRepository repository;

  Future<Either<AppException, VenueCourtsModel>> getVenueCourts() async =>
      await repository.getVenueCourts();

  Future<Either<AppException, List<ExpenseCategoryModel>>>
  getCategories() async => await repository.getCategories();

  Future<Either<AppException, List<ExpenseModel>>> getExpenses() async =>
      await repository.getExpenses();

  Future<Either<AppException, ExpenseModel>> addExpense(
    CreateExpenseEntity data,
  ) async => await repository.addExpense(data);

  Future<Either<AppException, bool>> deleteExpense(String id) async =>
      await repository.deleteExpense(id);

  Future<Either<AppException, bool>> restoreExpense(
    ExpenseModel expense,
  ) async => await repository.restoreExpense(expense);
}
