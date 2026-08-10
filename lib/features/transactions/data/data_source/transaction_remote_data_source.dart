import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class TransactionRemoteDataSource {
  Future<Result> getTransactionHistory({Map<String, dynamic>? query});
}

final class TransactionRemoteDataSourceImpl
    extends TransactionRemoteDataSource {
  @override
  Future<Result> getTransactionHistory({Map<String, dynamic>? query}) async =>
      await Client.instance().getAuthManager().getTransactionHistory(
        query: query,
      );
}
