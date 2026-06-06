import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class ExpensesRemoteDataSource {
  Future<Result> getExpenseCategories();
}

final class ExpensesRemoteDataSourceImpl extends ExpensesRemoteDataSource {
  @override
  Future<Result> getExpenseCategories() async =>
      await Client.instance().getAuthManager().getExpenseCategories();
}
