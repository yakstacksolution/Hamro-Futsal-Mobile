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
    final result = await useCase.getOverview(
      dateFilter: event.dateFilter,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
      venueIds: event.venueIds,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingOverviewStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (overview) => emit(
        state.copyWith(
          status: BookingOverviewStatus.success,
          overview: overview,
          clearErrorMessage: true,
        ),
      ),
    );
  }
}
