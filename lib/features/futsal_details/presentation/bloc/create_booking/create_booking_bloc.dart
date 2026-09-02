import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_result_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/create_booking_request.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/create_booking_use_case.dart';

part 'create_booking_event.dart';
part 'create_booking_state.dart';

class CreateBookingBloc extends Bloc<CreateBookingEvent, CreateBookingState> {
  CreateBookingBloc(this._createBookingUseCase)
    : super(const CreateBookingState()) {
    on<SubmitBookingEvent>(_onSubmit);
  }

  final CreateBookingUseCase _createBookingUseCase;

  Future<void> _onSubmit(
    SubmitBookingEvent event,
    Emitter<CreateBookingState> emit,
  ) async {
    if (state.status == CreateBookingStatus.submitting) return;
    emit(
      state.copyWith(status: CreateBookingStatus.submitting, clearError: true),
    );

    final Either<AppException, BookingResultModel> response =
        await _createBookingUseCase.createBooking(event.request);
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: CreateBookingStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (BookingResultModel result) => emit(
        state.copyWith(
          status: CreateBookingStatus.success,
          result: result,
          clearError: true,
        ),
      ),
    );
  }
}
