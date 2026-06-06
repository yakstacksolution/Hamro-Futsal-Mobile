import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_footsall/features/booking_overview/domain/usecase/booking_overview_usecase.dart';

part 'booking_overview_event.dart';
part 'booking_overview_state.dart';

class BookingOverviewBloc
    extends Bloc<BookingOverviewEvent, BookingOverviewState> {
  BookingOverviewBloc(this.useCase) : super(const BookingOverviewState()) {
    on<LoadBookingOverviewEvent>(_onLoad);
  }

  final BookingOverviewUseCase useCase;

  Future<void> _onLoad(
    LoadBookingOverviewEvent event,
    Emitter<BookingOverviewState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BookingOverviewStatus.loading,
        clearErrorMessage: true,
      ),
    );
    final futsalsResult = await useCase.getFutsals();
    final bookingsResult = await useCase.getBookings();
    futsalsResult.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingOverviewStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (futsals) => bookingsResult.fold(
        (failure) => emit(
          state.copyWith(
            status: BookingOverviewStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        ),
        (bookings) => emit(
          state.copyWith(
            status: BookingOverviewStatus.success,
            futsals: futsals,
            bookings: bookings,
            clearErrorMessage: true,
          ),
        ),
      ),
    );
  }
}
