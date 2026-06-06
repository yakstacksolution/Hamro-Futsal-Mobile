import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/expenses/data/data_source/expenses_remote_data_source.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_footsall/features/expenses/domain/repository/expenses_repository.dart';

final class ExpensesRepositoryImpl extends ExpensesRepository {
  ExpensesRepositoryImpl({ExpensesRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ExpensesRemoteDataSourceImpl();

  final ExpensesRemoteDataSource _remoteDataSource;

  final List<ExpenseModel> _expenses = [];

  @override
  Future<Either<AppException, VenueCourtsModel>> getVenueCourts() async {
    final response = await _remoteDataSource.getVenueCourts();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(_extractVenueCourts(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse venues and courts from server.',
          statusCode: 0,
        ),
      );
    }
  }

  VenueCourtsModel _extractVenueCourts(dynamic payload) {
    final venues = <VenueModel>[];
    final courts = <CourtModel>[];
    final items = _findList(
      payload,
      keys: const [
        'data',
        'venues',
        'venue_courts',
        'venueCourts',
        'items',
        'results',
      ],
      depth: 0,
    );
    for (final item in items) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final id = (map['id'] ?? map['venue_id'] ?? '').toString();
      final name = (map['name'] ?? map['venue_name'] ?? map['title'] ?? '')
          .toString()
          .trim();
      if (id.isEmpty || name.isEmpty) continue;
      venues.add(VenueModel(id: id, name: name));

      final dynamic rawCourts =
          map['courts'] ?? map['venue_courts'] ?? map['venueCourts'];
      if (rawCourts is! List) continue;
      for (final c in rawCourts) {
        if (c is! Map) continue;
        final cm = Map<String, dynamic>.from(c);
        final courtId = (cm['id'] ?? cm['court_id'] ?? '').toString();
        final courtName = (cm['name'] ?? cm['court_name'] ?? cm['title'] ?? '')
            .toString()
            .trim();
        if (courtId.isEmpty || courtName.isEmpty) continue;
        courts.add(
          CourtModel(
            id: courtId,
            name: courtName,
            // Fall back to the parent venue when the court doesn't carry one.
            venueId: (cm['venue_id'] ?? id).toString(),
          ),
        );
      }
    }
    return VenueCourtsModel(venues: venues, courts: courts);
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

  List<ExpenseCategoryModel> _extractCategories(dynamic payload) {
    return _findList(
          payload,
          keys: const [
            'data',
            'expense_categories',
            'expenseCategories',
            'categories',
            'items',
            'results',
          ],
          depth: 0,
        )
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

  /// Walks [keys] up to 3 levels deep until a non-empty list is found.
  List<dynamic> _findList(
    dynamic node, {
    required List<String> keys,
    required int depth,
  }) {
    if (node is List) return node;
    if (node is Map && depth < 3) {
      for (final key in keys) {
        final dynamic child = node[key];
        if (child == null) continue;
        final found = _findList(child, keys: keys, depth: depth + 1);
        if (found.isNotEmpty) return found;
      }
    }
    return const [];
  }

  @override
  Future<Either<AppException, List<ExpenseModel>>> getExpenses() async {
    final response = await _remoteDataSource.getExpenses();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final items = _findList(
        response.getValue(),
        keys: const ['data', 'expenses', 'items', 'results'],
        depth: 0,
      );
      _expenses
        ..clear()
        ..addAll(
          items.whereType<Map>().map(
            (e) => ExpenseModel.fromApiJson(Map<String, dynamic>.from(e)),
          ),
        )
        ..sort((a, b) => b.date.compareTo(a.date));
      return right(List.unmodifiable(_expenses));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse expenses from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, ExpenseModel>> addExpense(
    CreateExpenseEntity data,
  ) async {
    final response = await _remoteDataSource.createExpense(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final id =
          _extractId(response.getValue()) ??
          'u${DateTime.now().microsecondsSinceEpoch}';
      final expense = data.toModel(id);
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

  /// Applied to the in-memory copy only for now — wire to the update
  /// endpoint (mirroring [addExpense]) once the backend route exists.
  @override
  Future<Either<AppException, ExpenseModel>> updateExpense(
    String id,
    CreateExpenseEntity data,
  ) async {
    final i = _expenses.indexWhere((e) => e.id == id);
    if (i < 0) {
      return left(
        DefaultException(errorMessage: 'Expense not found.', statusCode: 0),
      );
    }
    final updated = data.toModel(id);
    _expenses
      ..[i] = updated
      ..sort((a, b) => b.date.compareTo(a.date));
    return right(updated);
  }

  /// Pulls the created expense id out of `{...}`, `{data: {...}}` or
  /// `{expense: {...}}` shaped responses.
  String? _extractId(dynamic payload) {
    if (payload is! Map) return null;
    final dynamic direct = payload['id'];
    if (direct != null) return direct.toString();
    for (final key in const ['data', 'expense']) {
      final id = _extractId(payload[key]);
      if (id != null) return id;
    }
    return null;
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
