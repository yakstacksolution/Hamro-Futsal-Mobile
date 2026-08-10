import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/transactions/data/model/transaction_history_model.dart';
import 'package:hamro_footsall/features/transactions/domain/usecase/transaction_usecase.dart';

part 'transaction_history_event.dart';
part 'transaction_history_state.dart';

/// Owns the paginated `GET /auth/transaction-history` list.
///
/// `direction` and `type` are server-side filters, so changing either restarts
/// from page 1; only the page cursor accumulates rows.
class TransactionHistoryBloc
    extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  TransactionHistoryBloc(this._useCase, {int perPage = 20})
    : _perPage = perPage,
      super(const TransactionHistoryState()) {
    on<LoadTransactionHistoryEvent>(_onLoad);
    on<LoadMoreTransactionHistoryEvent>(_onLoadMore);
    on<ChangeTransactionDirectionEvent>(_onChangeDirection);
    on<ChangeTransactionTypeEvent>(_onChangeType);
    on<SearchTransactionsEvent>(_onSearch);
    on<ChangeTransactionRangeEvent>(_onChangeRange);
    on<ClearTransactionFiltersEvent>(_onClearFilters);
  }

  final TransactionUseCase _useCase;
  final int _perPage;

  Future<void> _onLoad(
    LoadTransactionHistoryEvent event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TransactionHistoryStatus.loading,
        isRefreshing: event.isRefresh,
        clearError: true,
      ),
    );

    final Either<AppException, TransactionHistoryPageModel> response =
        await _useCase.getTransactionHistory(
          page: 1,
          perPage: _perPage,
          direction: state.direction,
          type: state.type,
          search: state.search,
          range: state.range,
        );
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: TransactionHistoryStatus.failure,
          isRefreshing: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (TransactionHistoryPageModel page) => emit(
        state.copyWith(
          status: TransactionHistoryStatus.success,
          items: page.items,
          summary: page.summary,
          availableTypes: _typesFrom(page.items),
          page: page.page,
          total: page.total,
          hasReachedMax: !page.hasMore,
          isRefreshing: false,
          isLoadingMore: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreTransactionHistoryEvent event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    // Ignore concurrent requests, end-of-list, and load-more before first load.
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.status != TransactionHistoryStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    final Either<AppException, TransactionHistoryPageModel> response =
        await _useCase.getTransactionHistory(
          page: state.page + 1,
          perPage: _perPage,
          direction: state.direction,
          type: state.type,
          search: state.search,
          range: state.range,
        );
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (TransactionHistoryPageModel page) {
        final List<TransactionHistoryItemModel> merged =
            <TransactionHistoryItemModel>[...state.items, ...page.items];
        emit(
          state.copyWith(
            items: merged,
            summary: page.summary,
            availableTypes: _typesFrom(merged),
            page: page.page,
            total: page.total,
            hasReachedMax: !page.hasMore || page.items.isEmpty,
            isLoadingMore: false,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onChangeDirection(
    ChangeTransactionDirectionEvent event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    if (event.direction == state.direction) return;
    emit(state.copyWith(direction: event.direction));
    add(const LoadTransactionHistoryEvent());
  }

  Future<void> _onChangeType(
    ChangeTransactionTypeEvent event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    if (event.type == state.type) return;
    emit(state.copyWith(type: event.type));
    add(const LoadTransactionHistoryEvent());
  }

  Future<void> _onSearch(
    SearchTransactionsEvent event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    final String query = event.query.trim();
    if (query == state.search) return;
    emit(state.copyWith(search: query));
    add(const LoadTransactionHistoryEvent());
  }

  Future<void> _onChangeRange(
    ChangeTransactionRangeEvent event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    if (event.range == state.range) return;
    emit(state.copyWith(range: event.range));
    add(const LoadTransactionHistoryEvent());
  }

  Future<void> _onClearFilters(
    ClearTransactionFiltersEvent event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    if (!state.hasFilters) return;
    emit(
      state.copyWith(
        direction: TransactionDirectionFilter.all,
        type: 'all',
        search: '',
        range: TransactionDateRange.allTime,
      ),
    );
    add(const LoadTransactionHistoryEvent());
  }

  /// Chip values for the `type` filter.
  ///
  /// The endpoint echoes the applied filters rather than advertising the valid
  /// ones, so the row is seeded with [kKnownTransactionSources] and widened by
  /// whatever `source` values actually turn up. Values already shown are kept,
  /// so filtering to one source never collapses the row.
  List<String> _typesFrom(List<TransactionHistoryItemModel> items) {
    final Set<String> sources = <String>{
      ...kKnownTransactionSources,
      ...state.availableTypes,
      ...items
          .map((TransactionHistoryItemModel item) => item.source ?? '')
          .where((String source) => source.isNotEmpty),
    };
    return sources.toList(growable: false)..sort();
  }
}
