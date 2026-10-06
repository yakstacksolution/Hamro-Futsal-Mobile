import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_quote_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/booking_hold_use_case.dart';

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

    final Either<AppException, List<BookingHoldModel>> response =
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
      (List<BookingHoldModel> holds) {
        // An empty answer used to throw on `holds.first`, leaving the state in
        // `holding` — and the checkout's price spinning — for good.
        final bool held = holds.isNotEmpty && holds.first.hasToken;
        emit(
          state.copyWith(
            status: held ? BookingHoldStatus.held : BookingHoldStatus.failure,
            holds: holds,
            errorMessage: held
                ? null
                : 'Could not hold this slot. Please try again.',
            clearError: held,
          ),
        );
      },
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

  void _release() {
    final List<String> ids = state.holdIds;
    if (_consumed || _released || ids.isEmpty) return;
    _released = true;
    unawaited(_bookingHoldUseCase.releaseHolds(ids));
  }

  @override
  Future<void> close() {
    // Covers back navigation / page disposal (the router disposes this bloc).
    _release();
    return super.close();
  }
}
