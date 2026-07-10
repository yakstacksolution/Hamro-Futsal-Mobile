import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._useCase) : super(const BookingState()) {
    on<FetchMyBookingsEvent>(_onFetchMyBookings);
    on<FetchFutsalBookingsEvent>(_onFetchFutsalBookings);
  }

  final GetBookingsUseCase _useCase;

  FutureOr<void> _onFetchMyBookings(
    FetchMyBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(
          myBookingsStatus: BookingLoadStatus.loading,
          clearMyError: true,
        ),
      );
    }

    final result = await _useCase.getMyBookings();
    result.fold(
      (error) => emit(
        state.copyWith(
          myBookingsStatus: BookingLoadStatus.failure,
          myBookingsError: error.errorMessage,
          refreshTick: state.refreshTick + 1,
        ),
      ),
      (bookings) => emit(
        state.copyWith(
          myBookingsStatus: BookingLoadStatus.success,
          myBookings: bookings,
          clearMyError: true,
          refreshTick: state.refreshTick + 1,
        ),
      ),
    );
  }

  FutureOr<void> _onFetchFutsalBookings(
    FetchFutsalBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(
          futsalBookingsStatus: BookingLoadStatus.loading,
          clearFutsalError: true,
        ),
      );
    }

    final result = await _useCase.getFutsalBookings();
    result.fold(
      (error) => emit(
        state.copyWith(
          futsalBookingsStatus: BookingLoadStatus.failure,
          futsalBookingsError: error.errorMessage,
          refreshTick: state.refreshTick + 1,
        ),
      ),
      (bookings) => emit(
        state.copyWith(
          futsalBookingsStatus: BookingLoadStatus.success,
          futsalBookings: bookings,
          clearFutsalError: true,
          refreshTick: state.refreshTick + 1,
        ),
      ),
    );
  }
}
