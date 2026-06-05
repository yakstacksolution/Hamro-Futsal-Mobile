import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/expenses/data/data_source/expenses_data_source.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_footsall/features/expenses/domain/repository/expenses_repository.dart';

final class ExpensesRepositoryImpl extends ExpensesRepository {
  ExpensesRepositoryImpl({ExpensesDataSource? dataSource})
    : _dataSource = dataSource ?? ExpensesLocalDataSourceImpl();

  final ExpensesDataSource _dataSource;

  /// In-memory working copy; the data source is read once and mutations are
  /// applied here until a backend persists them.
  final List<ExpenseModel> _expenses = [];
  bool _loaded = false;

  @override
  Future<Either<AppException, List<VenueModel>>> getVenues() async {
    try {
      return right(await _dataSource.fetchVenues());
    } catch (_) {
      return left(
        DefaultException(errorMessage: 'Could not load venues.', statusCode: 0),
      );
    }
  }

  @override
  Future<Either<AppException, List<CourtModel>>> getCourts() async {
    try {
      return right(await _dataSource.fetchCourts());
    } catch (_) {
      return left(
        DefaultException(errorMessage: 'Could not load courts.', statusCode: 0),
      );
    }
  }

  @override
  Future<Either<AppException, List<ExpenseModel>>> getExpenses() async {
    try {
      if (!_loaded) {
        _expenses
          ..clear()
          ..addAll(await _dataSource.fetchExpenses());
        _loaded = true;
      }
      return right(List.unmodifiable(_expenses));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not load expenses.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, ExpenseModel>> addExpense(
    CreateExpenseEntity data,
  ) async {
    try {
      final expense = data.toModel('u${DateTime.now().microsecondsSinceEpoch}');
      _expenses
        ..add(expense)
        ..sort((a, b) => b.date.compareTo(a.date));
      return right(expense);
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not save the expense.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> deleteExpense(String id) async {
    final lengthBefore = _expenses.length;
    _expenses.removeWhere((e) => e.id == id);
    if (_expenses.length == lengthBefore) {
      return left(
        DefaultException(errorMessage: 'Expense not found.', statusCode: 0),
      );
    }
    return right(true);
  }

  @override
  Future<Either<AppException, bool>> restoreExpense(
    ExpenseModel expense,
  ) async {
    _expenses
      ..add(expense)
      ..sort((a, b) => b.date.compareTo(a.date));
    return right(true);
  }
}
