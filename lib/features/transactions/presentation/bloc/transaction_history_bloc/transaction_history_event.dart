part of 'transaction_history_bloc.dart';

sealed class TransactionHistoryEvent extends Equatable {
  const TransactionHistoryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads (or reloads) the first page with the current filters.
///
/// [isRefresh] keeps the already-rendered list on screen while the request is
/// in flight, so pull-to-refresh does not flash a skeleton.
final class LoadTransactionHistoryEvent extends TransactionHistoryEvent {
  const LoadTransactionHistoryEvent({this.isRefresh = false});

  final bool isRefresh;

  @override
  List<Object?> get props => <Object?>[isRefresh];
}

/// Appends the next page. Ignored while a page is in flight or the list ended.
final class LoadMoreTransactionHistoryEvent extends TransactionHistoryEvent {
  const LoadMoreTransactionHistoryEvent();
}

/// Changes the `direction` filter and refetches from page 1.
final class ChangeTransactionDirectionEvent extends TransactionHistoryEvent {
  const ChangeTransactionDirectionEvent(this.direction);

  final TransactionDirectionFilter direction;

  @override
  List<Object?> get props => <Object?>[direction];
}

/// Changes the `type` filter and refetches from page 1.
final class ChangeTransactionTypeEvent extends TransactionHistoryEvent {
  const ChangeTransactionTypeEvent(this.type);

  /// A `source` value from the server, or `all` for no filtering.
  final String type;

  @override
  List<Object?> get props => <Object?>[type];
}

/// Changes the `date_from` / `date_to` window and refetches from page 1.
final class ChangeTransactionRangeEvent extends TransactionHistoryEvent {
  const ChangeTransactionRangeEvent(this.range);

  final TransactionDateRange range;

  @override
  List<Object?> get props => <Object?>[range];
}

/// Resets every filter (direction, type, range, search) in one request.
final class ClearTransactionFiltersEvent extends TransactionHistoryEvent {
  const ClearTransactionFiltersEvent();
}

/// Changes the `search` filter and refetches from page 1.
///
/// The caller debounces keystrokes; the bloc issues one request per event.
final class SearchTransactionsEvent extends TransactionHistoryEvent {
  const SearchTransactionsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}
