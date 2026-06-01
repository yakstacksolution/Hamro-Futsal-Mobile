import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';

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
      state.copyWith(status: PublicVenueStatus.loading, clearError: true),
    );

    final Either<AppException, PublicVenuePage> response =
        await _getPublicVenuesUseCase(page: 1, perPage: _perPage);

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: PublicVenueStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (PublicVenuePage page) => emit(
        state.copyWith(
          status: PublicVenueStatus.success,
          venues: page.venues,
          page: page.page,
          hasReachedMax: !page.hasMore,
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

    final Either<AppException, PublicVenuePage> response =
        await _getPublicVenuesUseCase(
          page: state.page + 1,
          perPage: _perPage,
        );

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (PublicVenuePage page) => emit(
        state.copyWith(
          status: PublicVenueStatus.success,
          venues: <PublicVenueModel>[...state.venues, ...page.venues],
          page: page.page,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      ),
    );
  }
}
