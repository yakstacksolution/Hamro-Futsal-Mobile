import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/transactions/domain/model/booking_transaction.dart';

void main() {
  group('BookingTransaction', () {
    test('maps a player booking to an outgoing paid transaction', () {
      final BookingTransaction transaction = BookingTransaction.fromBooking(
        _booking(
          futsalName: 'Goal Arena',
          payment: const BookingPaymentModel(
            id: 40,
            amount: 700,
            status: 'completed',
          ),
        ),
        perspective: TransactionPerspective.player,
      );

      expect(transaction.counterparty, 'Goal Arena');
      expect(transaction.isCredit, isFalse);
      expect(transaction.amount, 700);
      expect(transaction.status, TransactionStatus.paid);
    });

    test('maps a futsal booking to incoming customer revenue', () {
      final BookingTransaction transaction = BookingTransaction.fromBooking(
        _booking(playerName: 'Aarav Shrestha', payableNow: 1200),
        perspective: TransactionPerspective.futsal,
      );

      expect(transaction.counterparty, 'Aarav Shrestha');
      expect(transaction.isCredit, isTrue);
      expect(transaction.amount, 1200);
      expect(transaction.status, TransactionStatus.pending);
    });

    test('prioritizes an explicit refund payment status', () {
      final BookingTransaction transaction = BookingTransaction.fromBooking(
        _booking(
          status: BookingStatus.cancelled,
          payment: const BookingPaymentModel(
            id: 41,
            amount: 500,
            verificationStatus: 'refunded',
          ),
        ),
        perspective: TransactionPerspective.player,
      );

      expect(transaction.status, TransactionStatus.refunded);
    });
  });
}

BookingModel _booking({
  String futsalName = 'Hamro Futsal',
  String? playerName,
  double payableNow = 0,
  BookingStatus status = BookingStatus.confirmed,
  BookingPaymentModel? payment,
}) {
  return BookingModel(
    id: 10,
    bookingRef: 'BK-0010',
    courtName: 'Court A',
    futsalName: futsalName,
    date: DateTime(2026, 7, 4),
    startTime: '18:00',
    endTime: '19:00',
    status: status,
    amount: 1500,
    playerName: playerName,
    payableNow: payableNow,
    payments: payment == null
        ? const <BookingPaymentModel>[]
        : <BookingPaymentModel>[payment],
  );
}
