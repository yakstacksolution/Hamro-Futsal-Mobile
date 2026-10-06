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

final class AcceptBookingEvent extends BookingDetailsEvent {
  const AcceptBookingEvent({required this.bookingId});

  final int bookingId;

  @override
  List<Object?> get props => <Object?>[bookingId];
}

final class RejectBookingEvent extends BookingDetailsEvent {
  const RejectBookingEvent({required this.bookingId, this.note});

  final int bookingId;
  final String? note;

  @override
  List<Object?> get props => <Object?>[bookingId, note];
}

final class BookingCompletedEvent extends BookingDetailsEvent {
  const BookingCompletedEvent({required this.booking});

  final BookingModel booking;

  @override
  List<Object?> get props => <Object?>[booking];
}

final class CheckBookingReviewEvent extends BookingDetailsEvent {
  const CheckBookingReviewEvent({required this.bookingId});

  final int bookingId;

  @override
  List<Object?> get props => <Object?>[bookingId];
}

final class SubmitBookingReviewEvent extends BookingDetailsEvent {
  const SubmitBookingReviewEvent({
    required this.bookingId,
    required this.rating,
    required this.review,
  });

  final int bookingId;
  final double rating;
  final String review;

  @override
  List<Object?> get props => <Object?>[bookingId, rating, review];
}
