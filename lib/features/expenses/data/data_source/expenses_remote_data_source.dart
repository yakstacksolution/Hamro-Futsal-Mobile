import 'package:dio/dio.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';

abstract class ExpensesRemoteDataSource {
  Future<Result> getExpenseCategories();
  Future<Result> getVenueCourts();
  Future<Result> getExpenses({Map<String, dynamic>? query});
  Future<Result> createExpense(CreateExpenseEntity data);
}

final class ExpensesRemoteDataSourceImpl extends ExpensesRemoteDataSource {
  @override
  Future<Result> getExpenseCategories() async =>
      await Client.instance().getAuthManager().getExpenseCategories();

  @override
  Future<Result> getVenueCourts() async =>
      await Client.instance().getAuthManager().getDropdownVenueCourts();

  @override
  Future<Result> getExpenses({Map<String, dynamic>? query}) async =>
      await Client.instance().getAuthManager().getExpenses(query: query);

  @override
  Future<Result> createExpense(CreateExpenseEntity data) async {
    final map = data.toApiMap()..removeWhere((_, v) => v == null);

    // Attach the document (image/pdf/doc picked from device files) as a
    // multipart file when present.
    final path = data.documentPath;
    if (path != null && path.isNotEmpty) {
      map['document'] = await MultipartFile.fromFile(
        path,
        filename: path.split('/').last,
      );
    }

    return await Client.instance().getAuthManager().createExpense(
      FormData.fromMap(map),
    );
  }
}
