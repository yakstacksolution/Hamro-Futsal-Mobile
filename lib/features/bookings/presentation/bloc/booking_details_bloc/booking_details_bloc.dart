import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';

part 'booking_details_event.dart';
part 'booking_details_state.dart';

class BookingDetailsBloc
    extends Bloc<BookingDetailsEvent, BookingDetailsState> {
  BookingDetailsBloc(this._useCase, {required BookingModel initialBooking})
    : super(BookingDetailsState(booking: initialBooking)) {
    on<FetchBookingDetailsEvent>(_onFetch);
  }

  final GetBookingsUseCase _useCase;

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
          booking: booking,
          clearError: true,
        ),
      ),
    );
  }
}
