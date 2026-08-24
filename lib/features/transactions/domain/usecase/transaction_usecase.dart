import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/transactions/data/model/transaction_history_model.dart';
import 'package:hamro_footsall/features/transactions/domain/repository/transaction_repository.dart';

final class TransactionUseCase {
  const TransactionUseCase(this.repository);

  final TransactionRepository repository;

  Future<Either<AppException, TransactionHistoryPageModel>>
  getTransactionHistory({
    int page = 1,
    int perPage = 20,
    TransactionDirectionFilter direction = TransactionDirectionFilter.all,
    String type = 'all',
    String search = '',
    TransactionDateRange range = TransactionDateRange.allTime,
  }) => repository.getTransactionHistory(
    page: page,
    perPage: perPage,
    direction: direction,
    type: type,
    search: search,
    range: range,
  );
}
