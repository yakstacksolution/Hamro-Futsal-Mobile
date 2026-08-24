import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_description_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_venue_description_use_case.dart';

part 'venue_description_event.dart';
part 'venue_description_state.dart';

class VenueDescriptionBloc
    extends Bloc<VenueDescriptionEvent, VenueDescriptionState> {
  VenueDescriptionBloc(this._getVenueDescriptionUseCase)
    : super(const VenueDescriptionState()) {
    on<FetchVenueDescriptionEvent>(_onFetchVenueDescription);
  }

  final GetVenueDescriptionUseCase _getVenueDescriptionUseCase;

  FutureOr<void> _onFetchVenueDescription(
    FetchVenueDescriptionEvent event,
    Emitter<VenueDescriptionState> emit,
  ) async {
    emit(
      state.copyWith(status: VenueDescriptionStatus.loading, clearError: true),
    );

    final Either<AppException, VenueDescriptionModel> response =
        await _getVenueDescriptionUseCase(venueId: event.venueId);

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: VenueDescriptionStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (VenueDescriptionModel venueDescription) => emit(
        state.copyWith(
          status: VenueDescriptionStatus.success,
          venueDescription: venueDescription,
          clearError: true,
        ),
      ),
    );
  }
}
