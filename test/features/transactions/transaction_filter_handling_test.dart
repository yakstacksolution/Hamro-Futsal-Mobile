import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/transactions/data/model/transaction_history_model.dart';
import 'package:hamro_footsall/features/transactions/domain/repository/transaction_repository.dart';
import 'package:hamro_footsall/features/transactions/domain/usecase/transaction_usecase.dart';
import 'package:hamro_footsall/features/transactions/presentation/bloc/transaction_history_bloc/transaction_history_bloc.dart';

void main() {
  TransactionHistoryBloc blocFor(_FakeRepository repository) =>
      TransactionHistoryBloc(TransactionUseCase(repository), perPage: 2);

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  group('applying the filter sheet', () {
    test('moves three filters in a single request', () async {
      final _FakeRepository repository = _FakeRepository();
      final TransactionHistoryBloc bloc = blocFor(repository);

      bloc.add(const LoadTransactionHistoryEvent());
      await settle();
      expect(repository.calls.length, 1);

      bloc.add(
        ApplyTransactionFiltersEvent(
          direction: TransactionDirectionFilter.incoming,
          type: 'expense',
          range: TransactionDateRange.of(TransactionRangeFilter.month),
        ),
      );
      await settle();

      // One round trip carrying all three, not one per filter.
      expect(repository.calls.length, 2);
      expect(repository.calls.last.direction, 'incoming');
      expect(repository.calls.last.type, 'expense');
      expect(repository.calls.last.dateFrom, isNotNull);
      expect(repository.calls.last.page, 1);

      await bloc.close();
    });

    test('re-applying the same filters costs nothing', () async {
      final _FakeRepository repository = _FakeRepository();
      final TransactionHistoryBloc bloc = blocFor(repository);

      bloc.add(const LoadTransactionHistoryEvent());
      await settle();

      bloc.add(
        const ApplyTransactionFiltersEvent(
          direction: TransactionDirectionFilter.all,
          type: 'all',
          range: TransactionDateRange.allTime,
        ),
      );
      await settle();

      expect(repository.calls.length, 1);

      await bloc.close();
    });
  });

  group('a filter change during pagination', () {
    test('discards the page that was already in flight', () async {
      // Page 2 is held long enough for the filter change to overtake it.
      final _FakeRepository repository = _FakeRepository(
        lastPage: 3,
        delayFor: (int page) =>
            page == 2 ? const Duration(milliseconds: 120) : Duration.zero,
      );
      final TransactionHistoryBloc bloc = blocFor(repository);

      bloc.add(const LoadTransactionHistoryEvent());
      await settle();
      expect(bloc.state.items.length, 2);

      bloc.add(const LoadMoreTransactionHistoryEvent());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.isLoadingMore, isTrue);

      // The user filters while page 2 is still on the wire.
      bloc.add(
        const ChangeTransactionDirectionEvent(
          TransactionDirectionFilter.incoming,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));

      // Only the freshly filtered page 1 survives: the stale page must not be
      // appended, and must not drag its own cursor along with it.
      expect(bloc.state.items.length, 2);
      expect(bloc.state.page, 1);
      expect(bloc.state.isLoadingMore, isFalse);
      expect(
        bloc.state.items.every(
          (TransactionHistoryItemModel item) => item.id.contains('p1'),
        ),
        isTrue,
        reason: 'page 2 rows leaked into the filtered list',
      );

      await bloc.close();
    });

    test('the spinner does not outlive the discarded page', () async {
      final _FakeRepository repository = _FakeRepository(
        lastPage: 3,
        delayFor: (int page) =>
            page == 2 ? const Duration(milliseconds: 120) : Duration.zero,
      );
      final TransactionHistoryBloc bloc = blocFor(repository);

      bloc.add(const LoadTransactionHistoryEvent());
      await settle();
      bloc.add(const LoadMoreTransactionHistoryEvent());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const SearchTransactionsEvent('BK-8'));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(bloc.state.isLoadingMore, isFalse);

      await bloc.close();
    });
  });

  group('summary', () {
    test(
      'a filtered result with no summary drops the previous totals',
      () async {
        final _FakeRepository repository = _FakeRepository();
        final TransactionHistoryBloc bloc = blocFor(repository);

        bloc.add(const LoadTransactionHistoryEvent());
        await settle();
        expect(bloc.state.summary, isNotNull);

        // The next query matches nothing, so the server sends no summary block.
        repository.includeSummary = false;
        bloc.add(const ChangeTransactionTypeEvent('expense'));
        await settle();

        // Keeping it would report the old filter's totals over the new rows.
        expect(bloc.state.summary, isNull);

        await bloc.close();
      },
    );
  });

  group('a failed filter change', () {
    test('keeps the previous rows and reports failure', () async {
      final _FakeRepository repository = _FakeRepository();
      final TransactionHistoryBloc bloc = blocFor(repository);

      bloc.add(const LoadTransactionHistoryEvent());
      await settle();

      repository.failing = true;
      bloc.add(const ChangeTransactionTypeEvent('expense'));
      await settle();

      expect(bloc.state.status, TransactionHistoryStatus.failure);
      expect(bloc.state.items, isNotEmpty);
      expect(bloc.state.errorMessage, 'network down');

      // Pagination stays blocked on a failed list — which is why the footer
      // retries the reload rather than the next page.
      bloc.add(const LoadMoreTransactionHistoryEvent());
      await settle();
      expect(repository.calls.last.page, 1);

      // Retrying the reload does re-issue the filtered request.
      repository.failing = false;
      final int before = repository.calls.length;
      bloc.add(const LoadTransactionHistoryEvent());
      await settle();

      expect(repository.calls.length, before + 1);
      expect(repository.calls.last.type, 'expense');
      expect(bloc.state.status, TransactionHistoryStatus.success);

      await bloc.close();
    });
  });
}

class _Call {
  const _Call({
    required this.page,
    required this.direction,
    required this.type,
    required this.search,
    this.dateFrom,
    this.dateTo,
  });

  final int page;
  final String direction;
  final String type;
  final String search;
  final String? dateFrom;
  final String? dateTo;
}

final class _FakeRepository implements TransactionRepository {
  _FakeRepository({this.lastPage = 1, Duration Function(int page)? delayFor})
    : _delayFor = delayFor ?? ((int _) => Duration.zero);

  final int lastPage;
  final Duration Function(int page) _delayFor;

  bool failing = false;
  bool includeSummary = true;

  final List<_Call> calls = <_Call>[];

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
    calls.add(
      _Call(
        page: page,
        direction: direction.query,
        type: type,
        search: search,
        dateFrom: range.queryFrom,
        dateTo: range.queryTo,
      ),
    );

    final Duration delay = _delayFor(page);
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    if (failing) {
      return left(
        DefaultException(errorMessage: 'network down', statusCode: 0),
      );
    }

    return right(
      TransactionHistoryPageModel.fromResponse(<String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{
          if (includeSummary)
            'summary': <String, dynamic>{
              'incoming_total': 100,
              'outgoing_total': 40,
              'net_total': 60,
              'transaction_count': 2,
            },
          'items': <Map<String, dynamic>>[
            for (int index = 0; index < 2; index++)
              <String, dynamic>{
                // The page is encoded in the id so a leaked page is visible.
                'id': 'txn-p$page-i$index',
                'source': 'booking',
                'direction': 'incoming',
                'title': 'Booking income',
                'amount': 100,
                'status': 'cleared',
                'transaction_date': '2026-10-02',
              },
          ],
          'pagination': <String, dynamic>{
            'current_page': page,
            'last_page': lastPage,
            'per_page': perPage,
            'total': 2 * lastPage,
            'has_more_pages': page < lastPage,
          },
        },
      }),
    );
  }
}
