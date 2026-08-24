import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';

enum TransactionPerspective { player, futsal }

enum TransactionStatus { paid, pending, refunded, cancelled }

final class BookingTransaction extends Equatable {
  const BookingTransaction({
    required this.booking,
    required this.perspective,
    required this.status,
    required this.amount,
  });

  final BookingModel booking;
  final TransactionPerspective perspective;
  final TransactionStatus status;
  final double amount;

  bool get isCredit => perspective == TransactionPerspective.futsal;

  String get reference {
    final String value = booking.bookingRef.trim();
    return value.isNotEmpty ? value : '#${booking.id}';
  }

  String get counterparty {
    if (perspective == TransactionPerspective.futsal) {
      return _firstNonEmpty(<String?>[
        booking.playerName,
        booking.playerEmail,
        booking.playerPhone,
      ]);
    }
    return _firstNonEmpty(<String?>[booking.futsalName, booking.futsalAddress]);
  }

  String get courtName => booking.courtName.trim();

  String? get paymentMethod {
    final String value = booking.payment?.method?.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  DateTime get bookingDate => booking.date;

  factory BookingTransaction.fromBooking(
    BookingModel booking, {
    required TransactionPerspective perspective,
  }) {
    return BookingTransaction(
      booking: booking,
      perspective: perspective,
      status: _statusFromBooking(booking),
      amount: _amountFromBooking(booking),
    );
  }

  @override
  List<Object?> get props => <Object?>[booking, perspective, status, amount];
}

double _amountFromBooking(BookingModel booking) {
  final double paymentAmount = booking.payment?.amount ?? 0;
  if (paymentAmount > 0) return paymentAmount;
  if (booking.payableNow > 0) return booking.payableNow;
  if (booking.advanceAmount > 0) return booking.advanceAmount;
  return booking.amount;
}

TransactionStatus _statusFromBooking(BookingModel booking) {
  final String rawStatus =
      <String?>[
            booking.payment?.verificationStatus,
            booking.payment?.status,
            booking.paymentStatus,
          ]
          .map((String? value) => value?.trim().toLowerCase() ?? '')
          .firstWhere((String value) => value.isNotEmpty, orElse: () => '');

  if (rawStatus.contains('refund')) return TransactionStatus.refunded;
  if (booking.status == BookingStatus.cancelled) {
    return TransactionStatus.cancelled;
  }
  if (<String>{
    'paid',
    'completed',
    'complete',
    'success',
    'successful',
    'verified',
    'approved',
  }.contains(rawStatus)) {
    return TransactionStatus.paid;
  }
  if (booking.status == BookingStatus.completed &&
      (booking.payment != null || booking.paymentStatus != null)) {
    return TransactionStatus.paid;
  }
  return TransactionStatus.pending;
}

String _firstNonEmpty(Iterable<String?> values) {
  for (final String? value in values) {
    final String normalized = value?.trim() ?? '';
    if (normalized.isNotEmpty) return normalized;
  }
  return '';
}
