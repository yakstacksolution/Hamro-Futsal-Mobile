import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

part 'venue_court_event.dart';
part 'venue_court_state.dart';

class VenueCourtBloc extends Bloc<VenueCourtEvent, VenueCourtState> {
  VenueCourtBloc(this._getVenueCourtUseCase) : super(const VenueCourtState()) {
    on<FetchVenueCourtEvent>(_onFetchVenueCourt);
    on<UpsertVenueCourtLocallyEvent>(_onUpsertVenueCourtLocally);
    on<RemoveVenueCourtLocallyEvent>(_onRemoveVenueCourtLocally);
  }

  final GetVenueCourtUseCase _getVenueCourtUseCase;

  void _onUpsertVenueCourtLocally(
    UpsertVenueCourtLocallyEvent event,
    Emitter<VenueCourtState> emit,
  ) {
    final List<VenueCourtModel> updatedVenues = state.venues.map((venue) {
      if (venue.id != event.venueId) return venue;

      final List<CourtDraft> courts = List<CourtDraft>.from(venue.courts);
      final int existingIndex = courts.indexWhere(
        (c) => c.remoteId != null && c.remoteId == event.court.remoteId,
      );

      if (existingIndex >= 0) {
        courts[existingIndex] = event.court;
      } else {
        courts.add(event.court);
      }

      return VenueCourtModel(
        id: venue.id,
        title: venue.title,
        address: venue.address,
        phone: venue.phone,
        status: venue.status,
        courts: courts,
        imageUrl: venue.imageUrl,
      );
    }).toList();

    emit(state.copyWith(venues: updatedVenues));
  }

  void _onRemoveVenueCourtLocally(
    RemoveVenueCourtLocallyEvent event,
    Emitter<VenueCourtState> emit,
  ) {
    final List<VenueCourtModel> updatedVenues = state.venues.map((venue) {
      if (venue.id != event.venueId) return venue;

      final List<CourtDraft> courts = venue.courts.where((CourtDraft c) {
        final bool sameRemote =
            c.remoteId != null &&
            event.court.remoteId != null &&
            c.remoteId == event.court.remoteId;
        return !(sameRemote || c.id == event.court.id);
      }).toList();

      return VenueCourtModel(
        id: venue.id,
        title: venue.title,
        address: venue.address,
        phone: venue.phone,
        status: venue.status,
        courts: courts,
        imageUrl: venue.imageUrl,
      );
    }).toList();

    emit(state.copyWith(venues: updatedVenues));
  }

  FutureOr<void> _onFetchVenueCourt(
    FetchVenueCourtEvent event,
    Emitter<VenueCourtState> emit,
  ) async {
    emit(state.copyWith(status: VenueCourtStatus.loading, clearError: true));

    final Either<AppException, List<VenueCourtModel>> response =
        await _getVenueCourtUseCase();

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: VenueCourtStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (List<VenueCourtModel> venues) => emit(
        state.copyWith(
          status: VenueCourtStatus.success,
          venues: venues,
          clearError: true,
        ),
      ),
    );
  }
}
