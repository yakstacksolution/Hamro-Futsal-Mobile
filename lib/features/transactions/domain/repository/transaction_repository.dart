import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/transactions/data/model/transaction_history_model.dart';

abstract class TransactionRepository {
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
