import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/transactions/data/data_source/transaction_remote_data_source.dart';
import 'package:hamro_futsal/features/transactions/data/model/transaction_history_model.dart';
import 'package:hamro_futsal/features/transactions/domain/repository/transaction_repository.dart';

final class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl({TransactionRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? TransactionRemoteDataSourceImpl();

  final TransactionRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, TransactionHistoryPageModel>>
  getTransactionHistory({
    int page = 1,
    int perPage = 20,
    TransactionDirectionFilter direction = TransactionDirectionFilter.all,
    String type = 'all',
    String search = '',
    TransactionDateRange range = TransactionDateRange.allTime,
  }) async {
    final String query = search.trim();
    final Result response = await _remoteDataSource.getTransactionHistory(
      query: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'direction': direction.query,
        'type': type.isEmpty ? 'all' : type,
        // Omitted entirely when blank — the server treats `search=` as a filter.
        if (query.isNotEmpty) 'search': query,
        // Either bound may be open, so they are sent independently.
        if (range.queryFrom != null) 'date_from': range.queryFrom,
        if (range.queryTo != null) 'date_to': range.queryTo,
      },
    );
    if (response.isError()) return left(ResponseHelper.error(response));

    try {
      return right(
        TransactionHistoryPageModel.fromResponse(response.getValue()),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotLoadTransactionHistory,
          statusCode: 0,
        ),
      );
    }
  }
}
