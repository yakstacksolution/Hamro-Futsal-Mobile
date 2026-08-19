import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/booking_hold_use_case.dart';

part 'booking_hold_event.dart';
part 'booking_hold_state.dart';

class BookingHoldBloc extends Bloc<BookingHoldEvent, BookingHoldState> {
  BookingHoldBloc(this._bookingHoldUseCase) : super(const BookingHoldState()) {
    on<CreateBookingHoldEvent>(_onCreate);
    on<MarkBookingHoldConsumedEvent>(_onConsumed);
    on<ReleaseBookingHoldEvent>(_onRelease);
  }

  final BookingHoldUseCase _bookingHoldUseCase;

  bool _consumed = false;
  bool _released = false;

  Future<void> _onCreate(
    CreateBookingHoldEvent event,
    Emitter<BookingHoldState> emit,
  ) async {
    if (state.status == BookingHoldStatus.holding || state.hasToken) return;
    emit(state.copyWith(status: BookingHoldStatus.holding, clearError: true));

    final Either<AppException, BookingHoldModel> response =
        await _bookingHoldUseCase.createHold(
          venueId: event.venueId,
          courtId: event.courtId,
          bookingDate: event.bookingDate,
          startTime: event.startTime,
          endTime: event.endTime,
          bookingDates: event.bookingDates,
        );
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: BookingHoldStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (BookingHoldModel hold) => emit(
        state.copyWith(
          status: hold.hasToken
              ? BookingHoldStatus.held
              : BookingHoldStatus.failure,
          hold: hold,
          errorMessage: hold.hasToken
              ? null
              : 'Could not hold this slot. Please try again.',
          clearError: hold.hasToken,
        ),
      ),
    );
  }

  void _onConsumed(
    MarkBookingHoldConsumedEvent event,
    Emitter<BookingHoldState> emit,
  ) {
    _consumed = true;
  }

  void _onRelease(
    ReleaseBookingHoldEvent event,
    Emitter<BookingHoldState> emit,
  ) {
    _release();
  }

  /// Releases the hold (`DELETE /booking-holds/{token}`) at most once, unless a
  /// completed booking already consumed it. Fire-and-forget: the request runs
  /// on the singleton API client and survives the bloc being closed.
  void _release() {
    final String? token = state.holdToken;
    if (_consumed || _released || token == null || token.isEmpty) return;
    _released = true;
    unawaited(_bookingHoldUseCase.releaseHold(token));
  }

  @override
  Future<void> close() {
    // Covers back navigation / page disposal (the router disposes this bloc).
    _release();
    return super.close();
  }
}
