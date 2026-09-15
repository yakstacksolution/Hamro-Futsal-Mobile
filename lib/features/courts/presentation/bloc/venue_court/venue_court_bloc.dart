import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_page_model.dart';
import 'package:hamro_futsal/features/courts/domain/model/venue_court_purpose.dart';
import 'package:hamro_futsal/features/courts/domain/usecase/get_venue_court_use_case.dart';

part 'venue_court_event.dart';
part 'venue_court_state.dart';

class VenueCourtBloc extends Bloc<VenueCourtEvent, VenueCourtState> {
  VenueCourtBloc(this._getVenueCourtUseCase, {required this.purpose})
    : super(const VenueCourtState()) {
    on<FetchVenueCourtEvent>(_onFetchVenueCourt);
  }

  /// Which answer this bloc's screen wants from `/auth/get-venue-courts`.
  ///
  /// A screen's purpose never changes while it is open, so it is held here
  /// rather than repeated on every fetch, refresh and load-more event — where
  /// one call site forgetting it would silently ask for the other list.
  final VenueCourtPurpose purpose;

  final GetVenueCourtUseCase _getVenueCourtUseCase;
  bool _isFetching = false;

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
      response = await _getVenueCourtUseCase(
        page: page,
        perPage: 10,
        purpose: purpose,
      );
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
