import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';

part 'booking_details_event.dart';
part 'booking_details_state.dart';

class BookingDetailsBloc
    extends Bloc<BookingDetailsEvent, BookingDetailsState> {
  BookingDetailsBloc(
    this._useCase, {
    required BookingModel initialBooking,
    this.isFutsalView = false,
  }) : super(BookingDetailsState(booking: initialBooking)) {
    on<FetchBookingDetailsEvent>(_onFetch);
    on<CancelBookingEvent>(_onCancel);
    on<VerifyPaymentEvent>(_onVerifyPayment);
    on<RejectPaymentEvent>(_onRejectPayment);
    on<AcceptBookingEvent>(_onAcceptBooking);
    on<RejectBookingEvent>(_onRejectBooking);
    on<CheckBookingReviewEvent>(_onCheckReview);
    on<SubmitBookingReviewEvent>(_onSubmitReview);
  }

  final GetBookingsUseCase _useCase;

  /// Cancellation is a customer-only action; the futsal owner view never shows
  /// it, so the cancel-boundary API is not called there.
  final bool isFutsalView;

  FutureOr<void> _onFetch(
    FetchBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(
      state.copyWith(status: BookingDetailsStatus.loading, clearError: true),
    );

    final result = await _useCase.getBookingDetails(event.bookingId);
    result.fold(
      (error) => emit(
        state.copyWith(
          status: BookingDetailsStatus.failure,
          errorMessage: error.errorMessage,
        ),
      ),
      (booking) => emit(
        state.copyWith(
          status: BookingDetailsStatus.success,
          // Vendor detail responses are sometimes slimmer than the futsal
          // booking-list item and omit the customer relation. Preserve the
          // list identity so "Chat with customer" remains actionable after
          // the details request completes.
          booking: booking.copyWith(
            playerId: booking.playerId ?? state.booking.playerId,
            playerName: booking.playerName ?? state.booking.playerName,
            playerPhone: booking.playerPhone ?? state.booking.playerPhone,
            playerEmail: booking.playerEmail ?? state.booking.playerEmail,
            venueId: booking.venueId ?? state.booking.venueId,
            vendorId: booking.vendorId ?? state.booking.vendorId,
          ),
          clearError: true,
        ),
      ),
    );

    // Only the customer view can cancel, so skip the boundary check (and its
    // automatic API call) entirely in the futsal owner view.
    if (result.isRight() && !isFutsalView) {
      await _resolveCancelBoundary(event.bookingId, emit);
      // Reviews only exist for a played booking, and only the customer who
      // booked it can leave one — so this is asked in the same two conditions
      // as the cancel boundary, plus a completed status.
      if (state.booking.status == BookingStatus.completed) {
        await _resolveReview(event.bookingId, emit);
      }
    }
  }

  /// Asks the server whether the booking can still be cancelled and stores the
  /// result so the UI can show/hide the cancel action. Failures default to
  /// hiding the action.
  Future<void> _resolveCancelBoundary(
    int bookingId,
    Emitter<BookingDetailsState> emit,
  ) async {
    final result = await _useCase.getCancelBoundary(bookingId);
    result.fold(
      (_) => emit(state.copyWith(canCancel: false)),
      (canCancel) => emit(state.copyWith(canCancel: canCancel)),
    );
  }

  FutureOr<void> _onCheckReview(
    CheckBookingReviewEvent event,
    Emitter<BookingDetailsState> emit,
  ) async => await _resolveReview(event.bookingId, emit);

  /// Resolves whether a review exists. A failure leaves the status at
  /// [BookingReviewStatus.failure] rather than [BookingReviewStatus.none]:
  /// offering the form on a failed check invites a duplicate submission the
  /// server would then reject.
  Future<void> _resolveReview(
    int bookingId,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        reviewStatus: BookingReviewStatus.checking,
        clearReviewError: true,
      ),
    );
    final result = await _useCase.getBookingReview(bookingId);
    result.fold(
      (error) => emit(
        state.copyWith(
          reviewStatus: BookingReviewStatus.failure,
          reviewError: error.errorMessage,
        ),
      ),
      (review) => emit(
        state.copyWith(
          reviewStatus: review == null
              ? BookingReviewStatus.none
              : BookingReviewStatus.reviewed,
          review: review,
          clearReviewError: true,
        ),
      ),
    );
  }

  FutureOr<void> _onSubmitReview(
    SubmitBookingReviewEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    if (state.isSubmittingReview) return;
    emit(
      state.copyWith(
        reviewStatus: BookingReviewStatus.submitting,
        clearReviewError: true,
      ),
    );

    final result = await _useCase.submitBookingReview(
      bookingId: event.bookingId,
      rating: event.rating,
      review: event.review,
    );
    result.fold(
      (error) {
        // A duplicate-review rejection means the server already holds one, so
        // the form closes rather than inviting a retry that cannot succeed.
        final String message = error.errorMessage.toLowerCase();
        final bool alreadyReviewed =
            error.statusCode == 409 ||
            (error.statusCode == 422 && message.contains('already'));
        emit(
          state.copyWith(
            reviewStatus: alreadyReviewed
                ? BookingReviewStatus.reviewed
                : BookingReviewStatus.none,
            reviewError: error.errorMessage,
          ),
        );
      },
      (review) => emit(
        state.copyWith(
          reviewStatus: BookingReviewStatus.reviewed,
          review: review,
          clearReviewError: true,
        ),
      ),
    );
  }

  BookingModel _paymentOnlyBookingUpdate(
    BookingModel? serverBooking, {
    required int paymentId,
    required String verificationStatus,
    String? note,
  }) {
    final BookingModel source = serverBooking ?? state.booking;
    final List<BookingPaymentModel> payments = source.payments
        .map(
          (BookingPaymentModel payment) => payment.id == paymentId
              ? payment.copyWith(
                  verificationStatus: verificationStatus,
                  note: note ?? payment.note,
                )
              : payment,
        )
        .toList(growable: false);
    return source.copyWith(status: state.booking.status, payments: payments);
  }

  FutureOr<void> _onCancel(
    CancelBookingEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        cancelStatus: CancelBookingStatus.cancelling,
        clearError: true,
      ),
    );

    final result = await _useCase.cancelBooking(event.bookingId);
    result.fold(
      (error) => emit(
        state.copyWith(
          cancelStatus: CancelBookingStatus.failure,
          errorMessage: error.errorMessage,
        ),
      ),
      (booking) => emit(
        state.copyWith(
          cancelStatus: CancelBookingStatus.cancelled,
          booking: booking,
          clearError: true,
        ),
      ),
    );
  }

  // ── Payment proof verify / reject ──

  FutureOr<void> _onVerifyPayment(
    VerifyPaymentEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        paymentStatus: PaymentActionStatus.submitting,
        clearError: true,
      ),
    );

    final result = await _useCase.verifyBookingPayment(
      bookingId: event.bookingId,
      paymentId: event.paymentId,
      actualAmount: event.actualAmount,
      note: event.note,
    );
    result.fold(
      (error) => emit(
        state.copyWith(
          paymentStatus: PaymentActionStatus.failure,
          errorMessage: error.errorMessage,
        ),
      ),
      (booking) => emit(
        state.copyWith(
          paymentStatus: PaymentActionStatus.verified,
          booking: _paymentOnlyBookingUpdate(
            booking,
            paymentId: event.paymentId,
            verificationStatus: 'verified',
            note: event.note,
          ),
          clearError: true,
        ),
      ),
    );
  }

  FutureOr<void> _onRejectPayment(
    RejectPaymentEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        paymentStatus: PaymentActionStatus.submitting,
        clearError: true,
      ),
    );

    final result = await _useCase.rejectBookingPayment(
      bookingId: event.bookingId,
      paymentId: event.paymentId,
      note: event.note,
    );
    result.fold(
      (error) => emit(
        state.copyWith(
          paymentStatus: PaymentActionStatus.failure,
          errorMessage: error.errorMessage,
        ),
      ),
      (booking) => emit(
        state.copyWith(
          paymentStatus: PaymentActionStatus.rejected,
          booking: _paymentOnlyBookingUpdate(
            booking,
            paymentId: event.paymentId,
            verificationStatus: 'rejected',
            note: event.note,
          ),
          clearError: true,
        ),
      ),
    );
  }

  // ── Booking accept / reject ──

  FutureOr<void> _onAcceptBooking(
    AcceptBookingEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        decisionStatus: DecisionStatus.submitting,
        clearError: true,
      ),
    );

    final result = await _useCase.acceptBooking(bookingId: event.bookingId);
    result.fold(
      (error) => emit(
        state.copyWith(
          decisionStatus: DecisionStatus.failure,
          errorMessage: error.errorMessage,
        ),
      ),
      (booking) => emit(
        state.copyWith(
          decisionStatus: DecisionStatus.accepted,
          booking: booking ?? state.booking,
          clearError: true,
        ),
      ),
    );
  }

  FutureOr<void> _onRejectBooking(
    RejectBookingEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        decisionStatus: DecisionStatus.submitting,
        clearError: true,
      ),
    );

    final result = await _useCase.rejectBooking(
      bookingId: event.bookingId,
      note: event.note,
    );
    result.fold(
      (error) {
        final String message = error.errorMessage.trim().toLowerCase();
        final bool alreadyConfirmed =
            error.statusCode == 422 && message.contains('already confirmed');
        emit(
          state.copyWith(
            decisionStatus: DecisionStatus.failure,
            booking: alreadyConfirmed
                ? state.booking.copyWith(status: BookingStatus.confirmed)
                : state.booking,
            errorMessage: error.errorMessage,
          ),
        );
      },
      (booking) => emit(
        state.copyWith(
          decisionStatus: DecisionStatus.rejected,
          booking: booking ?? state.booking,
          clearError: true,
        ),
      ),
    );
  }
}
