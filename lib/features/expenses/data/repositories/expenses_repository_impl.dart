import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/expenses/data/data_source/expenses_data_source.dart';
import 'package:hamro_footsall/features/expenses/data/data_source/expenses_remote_data_source.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_footsall/features/expenses/domain/repository/expenses_repository.dart';

final class ExpensesRepositoryImpl extends ExpensesRepository {
  ExpensesRepositoryImpl({
    ExpensesDataSource? dataSource,
    ExpensesRemoteDataSource? remoteDataSource,
  }) : _dataSource = dataSource ?? ExpensesLocalDataSourceImpl(),
       _remoteDataSource = remoteDataSource ?? ExpensesRemoteDataSourceImpl();

  final ExpensesDataSource _dataSource;
  final ExpensesRemoteDataSource _remoteDataSource;

  /// In-memory working copy; the data source is read once and mutations are
  /// applied here until a backend persists them.
  final List<ExpenseModel> _expenses = [];
  bool _loaded = false;

  /// Venues and courts come from the same endpoint, so they are fetched
  /// together as a single result.
  @override
  Future<Either<AppException, VenueCourtsModel>> getVenueCourts() async {
    try {
      return right(
        VenueCourtsModel(
          venues: await _dataSource.fetchVenues(),
          courts: await _dataSource.fetchCourts(),
        ),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not load venues and courts.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<ExpenseCategoryModel>>>
  getCategories() async {
    final response = await _remoteDataSource.getExpenseCategories();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(_extractCategories(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse expense categories from server.',
          statusCode: 0,
        ),
      );
    }
  }

  /// Accepts `[...]`, `{data: [...]}`, `{expense_categories: [...]}` or any
  /// of those nested inside each other, and tolerates both object items and
  /// plain string items.
  List<ExpenseCategoryModel> _extractCategories(dynamic payload) {
    return _findCategoryList(payload, depth: 0)
        .map((item) {
          if (item is Map) {
            return ExpenseCategoryModel.fromJson(
              Map<String, dynamic>.from(item),
            );
          }
          final name = item?.toString().trim() ?? '';
          return ExpenseCategoryModel(id: name, name: name);
        })
        .where((c) => c.name.isNotEmpty)
        .toList(growable: false);
  }

  List<dynamic> _findCategoryList(dynamic node, {required int depth}) {
    if (node is List) return node;
    if (node is Map && depth < 3) {
      for (final key in const [
        'data',
        'expense_categories',
        'expenseCategories',
        'categories',
        'items',
        'results',
      ]) {
        final dynamic child = node[key];
        if (child == null) continue;
        final found = _findCategoryList(child, depth: depth + 1);
        if (found.isNotEmpty) return found;
      }
    }
    return const [];
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
