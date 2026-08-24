part of 'booking_details_bloc.dart';

enum BookingDetailsStatus { idle, loading, success, failure }

enum CancelBookingStatus { idle, cancelling, cancelled, failure }

enum DecisionStatus { idle, submitting, accepted, rejected, failure }

/// Status of the payment-proof verify/reject action (distinct from the
/// booking accept/reject decision).
enum PaymentActionStatus { idle, submitting, verified, rejected, failure }

/// Whether this booking has been reviewed. [unknown] is the state before the
/// check resolves — distinct from [none], so the form is not offered on a
/// guess and then withdrawn.
enum BookingReviewStatus {
  unknown,
  checking,
  none,
  reviewed,
  submitting,
  failure,
}

final class BookingDetailsState extends Equatable {
  const BookingDetailsState({
    required this.booking,
    this.status = BookingDetailsStatus.idle,
    this.cancelStatus = CancelBookingStatus.idle,
    this.decisionStatus = DecisionStatus.idle,
    this.paymentStatus = PaymentActionStatus.idle,
    this.canCancel = false,
    this.reviewStatus = BookingReviewStatus.unknown,
    this.review,
    this.reviewError,
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

  /// Resolved from `GET /bookings/{id}/review`, customer view only.
  final BookingReviewStatus reviewStatus;

  /// The submitted review, once there is one.
  final BookingReviewModel? review;

  /// Kept apart from [errorMessage] so a failed review submit does not surface
  /// as a booking-level error.
  final String? reviewError;

  final String? errorMessage;

  bool get isCheckingReview => reviewStatus == BookingReviewStatus.checking;
  bool get isSubmittingReview => reviewStatus == BookingReviewStatus.submitting;
  bool get hasReviewed => reviewStatus == BookingReviewStatus.reviewed;

  /// The form is offered only once the check has come back empty.
  bool get canReview => reviewStatus == BookingReviewStatus.none;

  BookingDetailsState copyWith({
    BookingModel? booking,
    BookingDetailsStatus? status,
    CancelBookingStatus? cancelStatus,
    DecisionStatus? decisionStatus,
    PaymentActionStatus? paymentStatus,
    bool? canCancel,
    BookingReviewStatus? reviewStatus,
    BookingReviewModel? review,
    String? reviewError,
    bool clearReviewError = false,
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
      reviewStatus: reviewStatus ?? this.reviewStatus,
      review: review ?? this.review,
      reviewError: clearReviewError ? null : reviewError ?? this.reviewError,
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
    reviewStatus,
    review,
    reviewError,
    errorMessage,
  ];
}
