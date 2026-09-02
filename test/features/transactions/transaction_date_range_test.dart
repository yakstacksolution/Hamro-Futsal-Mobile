import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/transactions/data/model/transaction_history_model.dart';

void main() {
  // A Thursday, mid-month, mid-year — so every preset has a distinct answer.
  final DateTime now = DateTime(2026, 7, 16, 19, 24);

  group('TransactionDateRange.of', () {
    test('all time sends no bounds', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.all,
        now: now,
      );
      expect(range.isActive, isFalse);
      expect(range.queryFrom, isNull);
      expect(range.queryTo, isNull);
    });

    test('today is a single day, with the time of day dropped', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.today,
        now: now,
      );
      expect(range.queryFrom, '2026-07-16');
      expect(range.queryTo, '2026-07-16');
    });

    test('week runs from Monday through today', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.week,
        now: now,
      );
      // 16 July 2026 is a Thursday; that week's Monday is the 13th.
      expect(range.queryFrom, '2026-07-13');
      expect(range.queryTo, '2026-07-16');
    });

    test('week starting on a Monday keeps that Monday', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.week,
        now: DateTime(2026, 7, 13),
      );
      expect(range.queryFrom, '2026-07-13');
    });

    test('month runs from the 1st', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.month,
        now: now,
      );
      expect(range.queryFrom, '2026-07-01');
      expect(range.queryTo, '2026-07-16');
    });

    test('year runs from January 1st', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.year,
        now: now,
      );
      expect(range.queryFrom, '2026-01-01');
      expect(range.queryTo, '2026-07-16');
    });

    test('custom keeps the picked bounds and zero-pads them', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.custom,
        from: DateTime(2026, 3, 5),
        to: DateTime(2026, 9, 9),
      );
      expect(range.isActive, isTrue);
      expect(range.queryFrom, '2026-03-05');
      expect(range.queryTo, '2026-09-09');
    });

    test('a backwards custom pick is swapped into order', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.custom,
        from: DateTime(2026, 9, 9),
        to: DateTime(2026, 3, 5),
      );
      expect(range.queryFrom, '2026-03-05');
      expect(range.queryTo, '2026-09-09');
    });

    test('a half-open custom range sends only the bound that was picked', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.custom,
        from: DateTime(2026, 3, 5),
      );
      expect(range.queryFrom, '2026-03-05');
      expect(range.queryTo, isNull);
    });

    test('custom with neither bound falls back to all time', () {
      final TransactionDateRange range = TransactionDateRange.of(
        TransactionRangeFilter.custom,
      );
      expect(range.isActive, isFalse);
    });
  });
}
