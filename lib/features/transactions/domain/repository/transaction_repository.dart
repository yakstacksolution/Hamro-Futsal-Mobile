import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/transactions/data/model/transaction_history_model.dart';

abstract class TransactionRepository {
  /// `GET /auth/transaction-history` — one page of the signed-in vendor's money
  /// movements.
  ///
  /// [direction], [type], [search] and [range] are all applied server-side;
  /// `all` for either filter, an empty [search] and an inactive [range] mean
  /// "do not narrow".
  Future<Either<AppException, TransactionHistoryPageModel>>
  getTransactionHistory({
    int page,
    int perPage,
    TransactionDirectionFilter direction,
    String type,
    String search,
    TransactionDateRange range,
  });
}
