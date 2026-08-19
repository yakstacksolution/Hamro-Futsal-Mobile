part of 'booking_details_bloc.dart';

enum BookingDetailsStatus { idle, loading, success, failure }

enum CancelBookingStatus { idle, cancelling, cancelled, failure }

enum DecisionStatus { idle, submitting, accepted, rejected, failure }

/// Status of the payment-proof verify/reject action (distinct from the
/// booking accept/reject decision).
enum PaymentActionStatus { idle, submitting, verified, rejected, failure }

final class BookingDetailsState extends Equatable {
  const BookingDetailsState({
    required this.booking,
    this.status = BookingDetailsStatus.idle,
    this.cancelStatus = CancelBookingStatus.idle,
    this.decisionStatus = DecisionStatus.idle,
    this.paymentStatus = PaymentActionStatus.idle,
    this.canCancel = false,
    this.errorMessage,
  });

  final BookingModel booking;
  final BookingDetailsStatus status;
  final CancelBookingStatus cancelStatus;
  final DecisionStatus decisionStatus;
  final PaymentActionStatus paymentStatus;

  /// Whether the booking is still within its allowed cancellation window,
  /// resolved from `GET /bookings/{id}/cancel-boundary`.
  final bool canCancel;
  final String? errorMessage;

  BookingDetailsState copyWith({
    BookingModel? booking,
    BookingDetailsStatus? status,
    CancelBookingStatus? cancelStatus,
    DecisionStatus? decisionStatus,
    PaymentActionStatus? paymentStatus,
    bool? canCancel,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingDetailsState(
      booking: booking ?? this.booking,
      status: status ?? this.status,
      cancelStatus: cancelStatus ?? this.cancelStatus,
      decisionStatus: decisionStatus ?? this.decisionStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      canCancel: canCancel ?? this.canCancel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    booking,
    status,
    cancelStatus,
    decisionStatus,
    paymentStatus,
    canCancel,
    errorMessage,
  ];
}
