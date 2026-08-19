import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_report_model.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';

abstract class ExpensesRepository {
  Future<Either<AppException, VenueCourtsModel>> getVenueCourts();
  Future<Either<AppException, List<ExpenseCategoryModel>>> getCategories();

  /// Fetches the server-computed report (summary + analytics + records) for
  /// the given query params (date_filter, venue_id, payment_method, …).
  Future<Either<AppException, ExpenseReport>> getExpenses(
    Map<String, dynamic> query,
  );
  Future<Either<AppException, ExpenseModel>> addExpense(
    CreateExpenseEntity data,
  );
  Future<Either<AppException, ExpenseModel>> updateExpense(
    String id,
    CreateExpenseEntity data,
  );
  Future<Either<AppException, bool>> deleteExpense(String id);
  Future<Either<AppException, bool>> restoreExpense(ExpenseModel expense);
}
