import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';

part 'public_venue_event.dart';
part 'public_venue_state.dart';

class PublicVenueBloc extends Bloc<PublicVenueEvent, PublicVenueState> {
  PublicVenueBloc(this._getPublicVenuesUseCase, {int perPage = 10})
    : _perPage = perPage,
      super(const PublicVenueState()) {
    on<FetchPublicVenuesEvent>(_onFetchPublicVenues);
    on<LoadMorePublicVenuesEvent>(_onLoadMorePublicVenues);
  }

  final GetPublicVenuesUseCase _getPublicVenuesUseCase;
  final int _perPage;

  FutureOr<void> _onFetchPublicVenues(
    FetchPublicVenuesEvent event,
    Emitter<PublicVenueState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PublicVenueStatus.loading,
        activeFilter: event.filter,
        clearError: true,
      ),
    );

    final Either<AppException, PublicListingVenuePage> response =
        await _getPublicVenuesUseCase(
          page: 1,
          perPage: _perPage,
          filter: event.filter,
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
          activeFilter: event.filter,
          clearError: true,
        ),
      ),
    );
  }

  FutureOr<void> _onLoadMorePublicVenues(
    LoadMorePublicVenuesEvent event,
    Emitter<PublicVenueState> emit,
  ) async {
    // Ignore concurrent or end-of-list requests.
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.status != PublicVenueStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    final Either<AppException, PublicListingVenuePage> response =
        await _getPublicVenuesUseCase(
          page: state.page + 1,
          perPage: _perPage,
          filter: state.activeFilter,
        );

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (PublicListingVenuePage page) => emit(
        state.copyWith(
          status: PublicVenueStatus.success,
          venues: <PublicListingVenueModel>[...state.venues, ...page.venues],
          page: page.page,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      ),
    );
  }
}
