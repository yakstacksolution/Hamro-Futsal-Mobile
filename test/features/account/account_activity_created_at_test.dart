import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';

void main() {
  group('AccountEntryModel created_at', () {
    test('reads created_at alongside the business date', () {
      final AccountEntryModel entry = AccountEntryModel.fromJson(
        <String, dynamic>{
          'type': 'platform_commission',
          'title': 'Platform commission',
          'reference': 'BK-OPSV83GK',
          'date': '2026-09-11 15:00:00',
          'created_at': '2026-09-12 09:24:11',
          'amount': 0.5,
          'direction': 'debit',
          'venue_name': "I'm going to delete this onee",
        },
      );

      expect(entry.date, DateTime.parse('2026-09-11 15:00:00').toLocal());
      expect(entry.createdAt, DateTime.parse('2026-09-12 09:24:11').toLocal());
      expect(entry.occurredAt, entry.date);
      expect(entry.isCredit, isFalse);
      expect(entry.amount, 0.5);
    });

    // The live payload has no created_at yet, so the row must still carry a
    // usable moment.
    test('leaves created_at null when the endpoint omits it', () {
      final AccountEntryModel entry = AccountEntryModel.fromJson(
        <String, dynamic>{
          'type': 'booking_payment',
          'title': 'Venue booking payment',
          'date': '2026-09-11 15:00:00',
          'amount': 50,
          'direction': 'credit',
        },
      );

      expect(entry.createdAt, isNull);
      expect(entry.occurredAt, DateTime.parse('2026-09-11 15:00:00').toLocal());
    });

    // A row that only has created_at still shows a date instead of nothing.
    test('falls back to created_at when there is no date', () {
      final AccountEntryModel entry = AccountEntryModel.fromJson(
        <String, dynamic>{
          'type': 'settlement',
          'title': 'Settlement payout',
          'created_at': '2026-09-12 09:24:11',
          'amount': 900,
        },
      );

      expect(entry.date, isNull);
      expect(entry.occurredAt, entry.createdAt);
    });
  });
}
