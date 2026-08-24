part of 'booking_hold_bloc.dart';

enum BookingHoldStatus { idle, holding, held, failure }

final class BookingHoldState extends Equatable {
  const BookingHoldState({
    this.status = BookingHoldStatus.idle,
    this.hold,
    this.errorMessage,
  });

  final BookingHoldStatus status;

  /// The full hold returned by `POST /booking-holds`, kept for the lifetime of
  /// the checkout page so the hold can be released on exit.
  final BookingHoldModel? hold;
  final String? errorMessage;

  /// The token used to release the hold (`DELETE /booking-holds/{token}`).
  String? get holdToken => hold?.holdToken;

  bool get hasToken => hold?.hasToken ?? false;
  bool get isHolding => status == BookingHoldStatus.holding;

  BookingHoldState copyWith({
    BookingHoldStatus? status,
    BookingHoldModel? hold,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingHoldState(
      status: status ?? this.status,
      hold: hold ?? this.hold,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, hold, errorMessage];
}
