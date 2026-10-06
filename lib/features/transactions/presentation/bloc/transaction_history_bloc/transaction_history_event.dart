part of 'transaction_history_bloc.dart';

sealed class TransactionHistoryEvent extends Equatable {
  const TransactionHistoryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class LoadTransactionHistoryEvent extends TransactionHistoryEvent {
  const LoadTransactionHistoryEvent({this.isRefresh = false});

  final bool isRefresh;

  @override
  List<Object?> get props => <Object?>[isRefresh];
}

final class LoadMoreTransactionHistoryEvent extends TransactionHistoryEvent {
  const LoadMoreTransactionHistoryEvent();
}

final class ChangeTransactionDirectionEvent extends TransactionHistoryEvent {
  const ChangeTransactionDirectionEvent(this.direction);

  final TransactionDirectionFilter direction;

  @override
  List<Object?> get props => <Object?>[direction];
}

final class ChangeTransactionTypeEvent extends TransactionHistoryEvent {
  const ChangeTransactionTypeEvent(this.type);

  final String type;

  @override
  List<Object?> get props => <Object?>[type];
}

final class ChangeTransactionRangeEvent extends TransactionHistoryEvent {
  const ChangeTransactionRangeEvent(this.range);

  final TransactionDateRange range;

  @override
  List<Object?> get props => <Object?>[range];
}

final class ApplyTransactionFiltersEvent extends TransactionHistoryEvent {
  const ApplyTransactionFiltersEvent({
    required this.direction,
    required this.type,
    required this.range,
  });

  final TransactionDirectionFilter direction;
  final String type;
  final TransactionDateRange range;

  @override
  List<Object?> get props => <Object?>[direction, type, range];
}

final class ClearTransactionFiltersEvent extends TransactionHistoryEvent {
  const ClearTransactionFiltersEvent();
}

final class SearchTransactionsEvent extends TransactionHistoryEvent {
  const SearchTransactionsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}
