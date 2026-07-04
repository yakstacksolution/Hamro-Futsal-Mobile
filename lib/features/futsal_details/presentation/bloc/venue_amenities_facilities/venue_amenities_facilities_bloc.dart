import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_amenities_facilities_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_venue_amenities_facilities_use_case.dart';

part 'venue_amenities_facilities_event.dart';
part 'venue_amenities_facilities_state.dart';

class VenueAmenitiesFacilitiesBloc
    extends Bloc<VenueAmenitiesFacilitiesEvent, VenueAmenitiesFacilitiesState> {
  VenueAmenitiesFacilitiesBloc(this._getVenueAmenitiesFacilitiesUseCase)
    : super(const VenueAmenitiesFacilitiesState()) {
    on<FetchVenueAmenitiesFacilitiesEvent>(_onFetchVenueAmenitiesFacilities);
  }

  final GetVenueAmenitiesFacilitiesUseCase _getVenueAmenitiesFacilitiesUseCase;

  FutureOr<void> _onFetchVenueAmenitiesFacilities(
    FetchVenueAmenitiesFacilitiesEvent event,
    Emitter<VenueAmenitiesFacilitiesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VenueAmenitiesFacilitiesStatus.loading,
        clearError: true,
      ),
    );

    final Either<AppException, VenueAmenitiesFacilitiesModel> response =
        await _getVenueAmenitiesFacilitiesUseCase(venueId: event.venueId);

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: VenueAmenitiesFacilitiesStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (VenueAmenitiesFacilitiesModel amenitiesFacilities) => emit(
        state.copyWith(
          status: VenueAmenitiesFacilitiesStatus.success,
          amenitiesFacilities: amenitiesFacilities,
          clearError: true,
        ),
      ),
    );
  }
}
