import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hamro_footsall/core/helper/device_location_helper.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';

part 'public_venue_event.dart';
part 'public_venue_state.dart';

/// The origin `GET /venues` measures `distance_km` from.
typedef VenueOrigin = ({double latitude, double longitude});

/// Resolves the current origin, or null when no fix is available yet. Injected
/// so tests can supply a fixed origin instead of reaching for the device GPS.
typedef VenueOriginResolver = VenueOrigin? Function();

VenueOrigin? _deviceOrigin() {
  final Position? fix = DeviceLocationHelper.instance.position.value;
  if (fix == null) return null;
  return (latitude: fix.latitude, longitude: fix.longitude);
}

class PublicVenueBloc extends Bloc<PublicVenueEvent, PublicVenueState> {
  PublicVenueBloc(
    this._getPublicVenuesUseCase, {
    int perPage = kVenueListPerPage,
    VenueOriginResolver originResolver = _deviceOrigin,
  }) : _perPage = perPage,
       _originResolver = originResolver,
       super(const PublicVenueState()) {
    on<FetchPublicVenuesEvent>(_onFetchPublicVenues);
    on<LoadMorePublicVenuesEvent>(_onLoadMorePublicVenues);
    on<RetryLoadMorePublicVenuesEvent>(_onRetryLoadMore);
  }

  final GetPublicVenuesUseCase _getPublicVenuesUseCase;
  final int _perPage;
  final VenueOriginResolver _originResolver;

  FutureOr<void> _onFetchPublicVenues(
    FetchPublicVenuesEvent event,
    Emitter<PublicVenueState> emit,
  ) async {
    // Resolved once per listing: every page of one listing must share the same
    // origin, or the distances would be measured from different points.
    final VenueOrigin? origin = event.origin ?? _originResolver();

    emit(
      state.copyWith(
        status: PublicVenueStatus.loading,
        activeFilter: event.filter,
        origin: origin,
        clearOrigin: origin == null,
        clearError: true,
        clearLoadMoreError: true,
      ),
    );

    final Either<AppException, PublicListingVenuePage> response =
        await _getPublicVenuesUseCase(
          page: 1,
          perPage: _perPage,
          filter: event.filter,
          latitude: origin?.latitude,
          longitude: origin?.longitude,
        );

    // A newer fetch (e.g. triggered by a location fix) superseded this one
    // while it was in flight — drop the stale response.
    if (event.filter != state.activeFilter) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: PublicVenueStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (PublicListingVenuePage page) => emit(
        state.copyWith(
          status: PublicVenueStatus.success,
          venues: page.venues,
          page: page.page,
          hasReachedMax: !page.hasMore,
          total: page.total,
          activeFilter: event.filter,
          isLoadingMore: false,
          clearError: true,
          clearLoadMoreError: true,
        ),
      ),
    );
  }

  FutureOr<void> _onLoadMorePublicVenues(
    LoadMorePublicVenuesEvent event,
    Emitter<PublicVenueState> emit,
  ) async {
    if (!state.canLoadMore) return;

    emit(state.copyWith(isLoadingMore: true, clearLoadMoreError: true));

    final int requestedPage = state.page + 1;
    final VenueFilter requestedFilter = state.activeFilter;

    final Either<AppException, PublicListingVenuePage> response =
        await _getPublicVenuesUseCase(
          page: requestedPage,
          perPage: _perPage,
          filter: requestedFilter,
          latitude: state.origin?.latitude,
          longitude: state.origin?.longitude,
        );

    // The filter changed (or the list was reloaded) while the page was in
    // flight; appending it now would mix results from two different queries.
    if (requestedFilter != state.activeFilter ||
        state.page != requestedPage - 1) {
      return;
    }

    response.fold(
      // Keep `hasReachedMax` false but record the failure: the scroll listener
      // checks `canLoadMore`, so the list stops auto-retrying until the user
      // taps retry, instead of firing a request on every scroll tick.
      (AppException failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          loadMoreErrorMessage: failure.errorMessage,
        ),
      ),
      (PublicListingVenuePage page) => emit(
        state.copyWith(
          status: PublicVenueStatus.success,
          venues: _appendUnique(state.venues, page.venues),
          page: page.page,
          hasReachedMax: !page.hasMore,
          total: page.total,
          isLoadingMore: false,
          clearError: true,
          clearLoadMoreError: true,
        ),
      ),
    );
  }

  /// Clears the load-more failure and immediately tries the same page again.
  FutureOr<void> _onRetryLoadMore(
    RetryLoadMorePublicVenuesEvent event,
    Emitter<PublicVenueState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedMax) return;
    emit(state.copyWith(clearLoadMoreError: true));
    add(const LoadMorePublicVenuesEvent());
  }

  /// Appends [next] to [current], skipping venues already loaded.
  ///
  /// Pages are fetched over separate requests, so a venue whose ranking changed
  /// between them can come back twice; without this the list would show it
  /// twice and duplicate its widget key.
  static List<PublicListingVenueModel> _appendUnique(
    List<PublicListingVenueModel> current,
    List<PublicListingVenueModel> next,
  ) {
    final Set<int> seenIds = current
        .map((PublicListingVenueModel venue) => venue.id)
        .whereType<int>()
        .toSet();

    final List<PublicListingVenueModel> merged =
        List<PublicListingVenueModel>.of(current);
    for (final PublicListingVenueModel venue in next) {
      // Venues without an id cannot be de-duplicated; keep them as-is.
      if (venue.id != null && !seenIds.add(venue.id!)) continue;
      merged.add(venue);
    }
    return List<PublicListingVenueModel>.unmodifiable(merged);
  }
}
