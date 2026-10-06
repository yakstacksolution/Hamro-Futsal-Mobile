import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/domain/model/booking_export_file.dart';
import 'package:hamro_futsal/features/booking_overview/domain/usecase/booking_overview_usecase.dart';

part 'booking_overview_event.dart';
part 'booking_overview_state.dart';

class BookingOverviewBloc
    extends Bloc<BookingOverviewEvent, BookingOverviewState> {
  BookingOverviewBloc(this.useCase) : super(const BookingOverviewState()) {
    on<LoadBookingOverviewEvent>(_onLoad);
    on<ExportBookingOverviewEvent>(_onExportBookingOverView);
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

  Future<void> _onExportBookingOverView(
    ExportBookingOverviewEvent event,
    Emitter<BookingOverviewState> emit,
  ) async {
    // A second tap while the file is still being built is ignored.
    if (state.exportStatus == BookingExportStatus.exporting) return;
    emit(
      state.copyWith(
        exportStatus: BookingExportStatus.exporting,
        clearExportFile: true,
        clearExportErrorMessage: true,
      ),
    );
    final result = await useCase.exportBookingsOverView(
      dateFilter: event.dateFilter,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
      venueIds: event.venueIds,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          exportStatus: BookingExportStatus.failure,
          exportErrorMessage: failure.errorMessage,
        ),
      ),
      (file) => emit(
        state.copyWith(
          exportStatus: BookingExportStatus.success,
          exportFile: file,
        ),
      ),
    );
  }
}
