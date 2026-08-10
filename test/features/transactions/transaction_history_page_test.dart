import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/features/transactions/data/model/transaction_history_model.dart';
import 'package:hamro_footsall/features/transactions/domain/model/booking_transaction.dart';
import 'package:hamro_footsall/features/transactions/domain/repository/transaction_repository.dart';
import 'package:hamro_footsall/features/transactions/presentation/pages/transaction_history_page.dart';

void main() {
  /// The page keeps its own chip row mounted behind the sheet, so sheet
  /// assertions must be scoped to the sheet itself.
  Finder inSheet(String text) => find.descendant(
    of: find.byType(CustomBottomSheet),
    matching: find.text(text),
  );

  /// Scrolls the sheet to the control before tapping it — the sheet's sections
  /// scroll, so on a short viewport a chip can start below the fold.
  Future<void> tapInSheet(WidgetTester tester, String text) async {
    final Finder target = inSheet(text);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  TextButton resetButton(WidgetTester tester) => tester.widget<TextButton>(
    find.ancestor(
      of: inSheet(StringConstants.reset),
      matching: find.byType(TextButton),
    ),
  );

  Widget wrap(TransactionRepository repository) => MaterialApp(
    home: TransactionHistoryPage(
      perspective: TransactionPerspective.futsal,
      repository: repository,
    ),
  );

  group('first load', () {
    testWidgets('requests page 1 unfiltered and renders the rows', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      expect(repository.calls, <_Call>[const _Call()]);
      expect(find.text('Booking income'), findsOneWidget);
      // Date, reference, venue and any commission share one muted meta line.
      expect(
        find.text(
          '02 Oct 2026 · BK-8ZYZNZLN · Dhananjay sport · '
          '${StringConstants.commission} NPR 108',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the summary panel shows server totals, not page totals', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      // net_total 3149.48, incoming_total 14155.48, outgoing_total 11006,
      // transaction_count 11.
      expect(
        find.text('${StringConstants.netBalance} · ${StringConstants.allTime}'),
        findsOneWidget,
      );
      expect(find.text('NPR 3,149'), findsOneWidget);
      expect(
        find.text(
          '${StringConstants.incoming} NPR 14,155'
          '   ·   '
          '${StringConstants.outgoing} NPR 11,006'
          '   ·   11',
        ),
        findsOneWidget,
      );
    });

    testWidgets('each row carries a direction arrow', (
      WidgetTester tester,
    ) async {
      // The fake alternates one booking (incoming) and one expense (outgoing).
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      // Sign and arrow agree.
      expect(find.text('+NPR 1,167'), findsOneWidget);
      expect(find.text('−NPR 1,000'), findsOneWidget);
    });

    testWidgets('the range starts on all time', (WidgetTester tester) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      expect(repository.calls.single.dateFrom, isNull);
      expect(repository.calls.single.dateTo, isNull);
    });
  });

  group('date range', () {
    testWidgets('a preset chip sends date_from and date_to', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(StringConstants.thisMonth));
      await tester.pumpAndSettle();

      final TransactionDateRange expected = TransactionDateRange.of(
        TransactionRangeFilter.month,
      );
      expect(repository.calls.length, 2);
      expect(repository.calls.last.dateFrom, expected.queryFrom);
      expect(repository.calls.last.dateTo, expected.queryTo);
      // Filtering always restarts pagination.
      expect(repository.calls.last.page, 1);
    });

    testWidgets('today narrows both bounds to the same day', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(StringConstants.today));
      await tester.pumpAndSettle();

      expect(repository.calls.last.dateFrom, isNotNull);
      expect(repository.calls.last.dateFrom, repository.calls.last.dateTo);
    });

    testWidgets('the summary label follows the selected range', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      // Selected chip, plus the summary heading. No active-filter line yet,
      // since `all time` is not a filter.
      expect(find.text(StringConstants.allTime), findsOneWidget);
      expect(
        find.text('${StringConstants.netBalance} · ${StringConstants.allTime}'),
        findsOneWidget,
      );

      await tester.tap(find.text(StringConstants.thisYear));
      await tester.pumpAndSettle();

      // Selected chip plus the active-filter summary line.
      expect(find.text(StringConstants.thisYear), findsNWidgets(2));
      expect(
        find.text(
          '${StringConstants.netBalance} · ${StringConstants.thisYear}',
        ),
        findsOneWidget,
      );
    });
  });

  group('filter sheet', () {
    testWidgets('applying a direction refetches from page 1', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      await tapInSheet(tester, StringConstants.incoming);
      await tapInSheet(tester, StringConstants.showTransactions);

      expect(repository.calls.length, 2);
      expect(repository.calls.last.direction, 'incoming');
      expect(repository.calls.last.page, 1);
    });

    testWidgets('applying a type filter sends the source value', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      await tapInSheet(tester, 'Expense');
      await tapInSheet(tester, StringConstants.showTransactions);

      expect(repository.calls.last.type, 'expense');
    });

    testWidgets('reset is inert until something is selected', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      // Nothing is filtered yet, so Reset is disabled.
      expect(resetButton(tester).onPressed, isNull);

      await tapInSheet(tester, StringConstants.thisWeek);

      expect(resetButton(tester).onPressed, isNotNull);
    });

    testWidgets('reset clears the pending selection without applying it', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      await tapInSheet(tester, StringConstants.thisWeek);
      await tapInSheet(tester, StringConstants.reset);
      await tapInSheet(tester, StringConstants.showTransactions);

      // Reset happens inside the sheet, so nothing was ever requested.
      expect(repository.calls.length, 1);
    });

    testWidgets('the custom range reveals both date fields', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      expect(inSheet(StringConstants.startDate), findsNothing);

      await tapInSheet(tester, StringConstants.customRange);

      expect(inSheet(StringConstants.startDate), findsOneWidget);
      expect(inSheet(StringConstants.endDate), findsOneWidget);
      expect(inSheet(StringConstants.selectDate), findsNWidgets(2));
    });

    testWidgets('clear all resets every filter in one request', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(StringConstants.thisMonth));
      await tester.pumpAndSettle();
      expect(repository.calls.length, 2);

      await tester.tap(find.text(StringConstants.clearAll));
      await tester.pumpAndSettle();

      expect(repository.calls.length, 3);
      expect(repository.calls.last, const _Call());
    });
  });

  group('search', () {
    testWidgets('debounces to a single server-side request', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'BK-8');
      expect(repository.calls.length, 1);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(repository.calls.length, 2);
      expect(repository.calls.last.search, 'BK-8');
    });

    testWidgets('clearing drops the server filter', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'BK-8');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(repository.calls.last.search, isEmpty);
      expect(repository.calls.length, 3);
    });
  });

  group('transitions', () {
    testWidgets('a filter change shows progress, then clears it', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository = _FakeTransactionRepository(
        delay: const Duration(milliseconds: 300),
      );

      await tester.pumpWidget(wrap(repository));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);

      await tester.tap(find.text(StringConstants.thisMonth));
      // The range change and the load it queues are separate emits, so let the
      // event loop turn before asserting — but stay inside the fake's delay.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // Previous rows stay on screen, dimmed, while the next query runs.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Booking income'), findsOneWidget);
      expect(
        tester
            .widget<SliverAnimatedOpacity>(find.byType(SliverAnimatedOpacity))
            .opacity,
        lessThan(1),
      );

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('the active-filter row appears only once a filter is set', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository =
          _FakeTransactionRepository();

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.clearAll), findsNothing);

      await tester.tap(find.text(StringConstants.thisMonth));
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.clearAll), findsOneWidget);
    });
  });

  group('pagination', () {
    testWidgets('scrolling to the bottom appends page 2', (
      WidgetTester tester,
    ) async {
      final _FakeTransactionRepository repository = _FakeTransactionRepository(
        itemsPerPage: 20,
        lastPage: 2,
      );

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, -6000),
        6000,
      );
      await tester.pumpAndSettle();

      expect(repository.calls.length, greaterThanOrEqualTo(2));
      expect(repository.calls[1].page, 2);
    });

    testWidgets('a single-page response never asks for page 2', (
      WidgetTester tester,
    ) async {
      // has_more_pages false, matching the live one-page payload.
      final _FakeTransactionRepository repository = _FakeTransactionRepository(
        itemsPerPage: 11,
      );

      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, -6000),
        6000,
      );
      await tester.pumpAndSettle();

      expect(repository.calls.length, 1);
    });
  });

  testWidgets('a first-page failure shows the retry state', (
    WidgetTester tester,
  ) async {
    final _FakeTransactionRepository repository = _FakeTransactionRepository(
      failure: true,
    );

    await tester.pumpWidget(wrap(repository));
    await tester.pumpAndSettle();

    expect(
      find.text(StringConstants.couldNotLoadTransactionHistory),
      findsOneWidget,
    );

    await tester.tap(find.text(StringConstants.retry));
    await tester.pumpAndSettle();

    expect(repository.calls.length, 2);
  });
}

/// One recorded request, so tests assert on the wire values.
class _Call {
  const _Call({
    this.page = 1,
    this.direction = 'all',
    this.type = 'all',
    this.search = '',
    this.dateFrom,
    this.dateTo,
  });

  final int page;
  final String direction;
  final String type;
  final String search;
  final String? dateFrom;
  final String? dateTo;

  @override
  bool operator ==(Object other) =>
      other is _Call &&
      other.page == page &&
      other.direction == direction &&
      other.type == type &&
      other.search == search &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo;

  @override
  int get hashCode =>
      Object.hash(page, direction, type, search, dateFrom, dateTo);

  @override
  String toString() =>
      'page=$page direction=$direction type=$type search=$search '
      'from=$dateFrom to=$dateTo';
}

final class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository({
    this.itemsPerPage = 2,
    this.lastPage = 1,
    this.failure = false,
    this.delay = Duration.zero,
  });

  final int itemsPerPage;
  final int lastPage;
  final bool failure;

  /// Holds the response so a test can observe the in-flight state.
  final Duration delay;

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

    if (delay > Duration.zero) await Future<void>.delayed(delay);

    if (failure) {
      return left(
        DefaultException(errorMessage: 'network down', statusCode: 0),
      );
    }

    return right(
      TransactionHistoryPageModel.fromResponse(<String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{
          'filters': <String, dynamic>{
            'direction': direction.query,
            'type': type,
            'search': search.isEmpty ? null : search,
            'date_from': range.queryFrom,
            'date_to': range.queryTo,
          },
          'summary': <String, dynamic>{
            'incoming_total': 14155.48,
            'outgoing_total': 11006,
            'net_total': 3149.48,
            'transaction_count': 11,
          },
          'items': <Map<String, dynamic>>[
            for (int index = 0; index < itemsPerPage; index++)
              _row(page: page, index: index),
          ],
          'pagination': <String, dynamic>{
            'current_page': page,
            'last_page': lastPage,
            'per_page': perPage,
            'total': itemsPerPage * lastPage,
            'has_more_pages': page < lastPage,
          },
        },
      }),
    );
  }

  /// Alternates booking / expense rows so both sources are represented.
  Map<String, dynamic> _row({required int page, required int index}) {
    final bool isBooking = index.isEven;
    return <String, dynamic>{
      'id': isBooking
          ? 'booking-${page * 100 + index}'
          : 'expense-${page * 100 + index}',
      'source': isBooking ? 'booking' : 'expense',
      'direction': isBooking ? 'incoming' : 'outgoing',
      'title': isBooking ? 'Booking income' : 'Bill',
      'reference': index == 0 && page == 1
          ? 'BK-8ZYZNZLN'
          : '${isBooking ? 'BK' : 'EXP'}-P${page}I$index',
      'amount': isBooking ? 1166.62 : 1000,
      'gross_amount': isBooking ? 1275 : 1000,
      'commission_amount': isBooking ? 108.38 : 0,
      'status': isBooking ? 'pending_clearance' : 'recorded',
      'payment_status': isBooking ? 'partial' : null,
      'booking_status': isBooking ? 'confirmed' : null,
      if (!isBooking) 'payment_method': 'cash',
      'transaction_date': '2026-10-02',
      'created_at': '2026-07-16 19:24:06',
      'venue': <String, dynamic>{
        'id': 1,
        'name': 'Dhananjay sport',
        'address': 'Nagarjun Municipality Nepal',
      },
      'meta': isBooking
          ? <String, dynamic>{'booking_id': page * 100 + index}
          : <String, dynamic>{'expense_id': page * 100 + index, 'note': 'Hi'},
      'sort_at': 1790878500,
    };
  }
}
