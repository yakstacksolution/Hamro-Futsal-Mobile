part of 'create_booking_bloc.dart';

sealed class CreateBookingEvent extends Equatable {
  const CreateBookingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class SubmitBookingEvent extends CreateBookingEvent {
  const SubmitBookingEvent(this.request);

  final CreateBookingRequest request;

  @override
  List<Object?> get props => <Object?>[
    request.venueId,
    request.courtId,
    request.bookingDate,
    request.startTime,
    request.endTime,
    request.couponCode,
    request.repeatWeeks,
    request.paymentProof,
  ];
}
