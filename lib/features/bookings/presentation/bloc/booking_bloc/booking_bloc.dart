import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
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

    final Either<AppException, List<BookingModel>> result;
    try {
      result = await _useCase.getMyBookings();
    } catch (error) {
      // Anything the layers below fail to turn into a Left (a socket drop, a
      // token-refresh crash) would otherwise escape this handler and leave the
      // status on `loading` — an endless skeleton with no way back. Surface it
      // as a failure so the list shows its error view with a retry.
      emit(
        state.copyWith(
          myBookingsStatus: BookingLoadStatus.failure,
          myBookingsError: _messageFor(error),
          refreshTick: state.refreshTick + 1,
        ),
      );
      return;
    }
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

    final Either<AppException, List<BookingModel>> result;
    try {
      result = await _useCase.getFutsalBookings();
    } catch (error) {
      emit(
        state.copyWith(
          futsalBookingsStatus: BookingLoadStatus.failure,
          futsalBookingsError: _messageFor(error),
          refreshTick: state.refreshTick + 1,
        ),
      );
      return;
    }
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

  /// Readable text for an exception that never became an [AppException].
  String _messageFor(Object error) {
    if (error is AppException) {
      final String message = error.errorMessage.trim();
      if (message.isNotEmpty) return message;
    }
    if (error is SocketException || error is TimeoutException) {
      return 'No internet connection. Check your network and try again.';
    }
    return 'Something went wrong while loading bookings. Please try again.';
  }
}
