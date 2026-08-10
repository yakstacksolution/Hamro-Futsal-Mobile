import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_page_model.dart';
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
  bool _isFetching = false;

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
    if (_isFetching || (event.loadMore && !state.hasMorePages)) return;
    _isFetching = true;
    if (event.loadMore) {
      emit(state.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    } else if (!event.silent) {
      emit(state.copyWith(status: VenueCourtStatus.loading, clearError: true));
    }

    final int page = event.loadMore ? state.currentPage + 1 : 1;
    late final Either<AppException, VenueCourtPageModel> response;
    try {
      response = await _getVenueCourtUseCase(page: page, perPage: 10);
    } catch (_) {
      response = left(
        DefaultException(
          errorMessage: 'Could not load venue courts. Please try again.',
          statusCode: 0,
        ),
      );
    }
    _isFetching = false;

    response.fold(
      (AppException failure) => emit(
        event.loadMore
            ? state.copyWith(
                isLoadingMore: false,
                loadMoreError: failure.errorMessage,
                refreshTick: state.refreshTick + 1,
              )
            : state.copyWith(
                status: VenueCourtStatus.failure,
                errorMessage: failure.errorMessage,
                refreshTick: state.refreshTick + 1,
              ),
      ),
      (VenueCourtPageModel result) => emit(
        state.copyWith(
          status: VenueCourtStatus.success,
          venues: event.loadMore
              ? _mergeVenues(state.venues, result.items)
              : result.items,
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          total: result.total,
          hasMorePages: result.hasMorePages,
          isLoadingMore: false,
          clearError: true,
          clearLoadMoreError: true,
          refreshTick: state.refreshTick + 1,
        ),
      ),
    );
  }

  List<VenueCourtModel> _mergeVenues(
    List<VenueCourtModel> existing,
    List<VenueCourtModel> incoming,
  ) {
    final Map<int, VenueCourtModel> byId = <int, VenueCourtModel>{};
    final List<VenueCourtModel> withoutId = <VenueCourtModel>[];
    for (final VenueCourtModel venue in <VenueCourtModel>[
      ...existing,
      ...incoming,
    ]) {
      final int? id = venue.id;
      if (id == null) {
        withoutId.add(venue);
      } else {
        byId[id] = venue;
      }
    }
    return <VenueCourtModel>[...byId.values, ...withoutId];
  }
}
