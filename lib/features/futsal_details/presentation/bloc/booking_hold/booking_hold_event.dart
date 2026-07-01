part of 'booking_hold_bloc.dart';

sealed class BookingHoldEvent extends Equatable {
  const BookingHoldEvent();

  @override
  List<Object?> get props => <Object?>[];
}


class CreateBookingHoldEvent extends BookingHoldEvent {
  const CreateBookingHoldEvent({
    required this.venueId,
    required this.courtId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.bookingDates = const <String>[],
  });

  final int? venueId;
  final int? courtId;
  final String bookingDate;
  final String startTime;
  final String endTime;

  /// Recurring session dates in `yyyy-MM-dd`; empty for single bookings.
  final List<String> bookingDates;

  @override
  List<Object?> get props => <Object?>[
    venueId,
    courtId,
    bookingDate,
    startTime,
    endTime,
    bookingDates,
  ];
}


class MarkBookingHoldConsumedEvent extends BookingHoldEvent {
  const MarkBookingHoldConsumedEvent();
}

/// Releases the hold (`DELETE /booking-holds/{token}`). Dispatched when the
/// app is closed/backgrounded while the checkout page is still open.
class ReleaseBookingHoldEvent extends BookingHoldEvent {
  const ReleaseBookingHoldEvent();
}
