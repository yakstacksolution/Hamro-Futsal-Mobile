part of 'booking_details_bloc.dart';

enum BookingDetailsStatus { idle, loading, success, failure }

enum CancelBookingStatus { idle, cancelling, cancelled, failure }

enum DecisionStatus { idle, submitting, accepted, rejected, failure }

enum PaymentActionStatus { idle, submitting, verified, rejected, failure }

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

  final bool canCancel;

  final BookingReviewStatus reviewStatus;

  final BookingReviewModel? review;

  final String? reviewError;

  final String? errorMessage;

  bool get isCheckingReview => reviewStatus == BookingReviewStatus.checking;
  bool get isSubmittingReview => reviewStatus == BookingReviewStatus.submitting;
  bool get hasReviewed => reviewStatus == BookingReviewStatus.reviewed;

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
