part of 'booking_details_bloc.dart';

sealed class BookingDetailsEvent extends Equatable {
  const BookingDetailsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FetchBookingDetailsEvent extends BookingDetailsEvent {
  const FetchBookingDetailsEvent(this.bookingId);

  final int bookingId;

  @override
  List<Object?> get props => <Object?>[bookingId];
}

final class CancelBookingEvent extends BookingDetailsEvent {
  const CancelBookingEvent(this.bookingId);

  final int bookingId;

  @override
  List<Object?> get props => <Object?>[bookingId];
}

/// Verifies a booking's payment proof.
final class VerifyPaymentEvent extends BookingDetailsEvent {
  const VerifyPaymentEvent({
    required this.bookingId,
    required this.paymentId,
    required this.actualAmount,
    this.note,
  });

  final int bookingId;
  final int paymentId;
  final double actualAmount;
  final String? note;

  @override
  List<Object?> get props => <Object?>[
    bookingId,
    paymentId,
    actualAmount,
    note,
  ];
}

/// Rejects a booking's payment proof with an optional reason.
final class RejectPaymentEvent extends BookingDetailsEvent {
  const RejectPaymentEvent({
    required this.bookingId,
    required this.paymentId,
    this.note,
  });

  final int bookingId;
  final int paymentId;
  final String? note;

  @override
  List<Object?> get props => <Object?>[bookingId, paymentId, note];
}

/// Accepts the booking itself.
final class AcceptBookingEvent extends BookingDetailsEvent {
  const AcceptBookingEvent({required this.bookingId});

  final int bookingId;

  @override
  List<Object?> get props => <Object?>[bookingId];
}

/// Rejects the booking itself with an optional reason.
final class RejectBookingEvent extends BookingDetailsEvent {
  const RejectBookingEvent({required this.bookingId, this.note});

  final int bookingId;
  final String? note;

  @override
  List<Object?> get props => <Object?>[bookingId, note];
}
