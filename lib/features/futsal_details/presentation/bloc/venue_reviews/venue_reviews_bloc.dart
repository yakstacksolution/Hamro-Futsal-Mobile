import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_review_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_venue_reviews_use_case.dart';

part 'venue_reviews_event.dart';
part 'venue_reviews_state.dart';

/// Reviews for one venue, paged.
///
/// The same bloc serves both surfaces: the details page asks for a short
/// preview ([kVenueReviewsPreviewSize]) and the full-list page asks for
/// [kVenueReviewsPageSize] at a time, appending as the user scrolls.
class VenueReviewsBloc extends Bloc<VenueReviewsEvent, VenueReviewsState> {
  VenueReviewsBloc(this._getVenueReviewsUseCase)
    : super(const VenueReviewsState()) {
    on<FetchVenueReviewsEvent>(_onFetch);
    on<LoadMoreVenueReviewsEvent>(_onLoadMore);
  }

  final GetVenueReviewsUseCase _getVenueReviewsUseCase;

  FutureOr<void> _onFetch(
    FetchVenueReviewsEvent event,
    Emitter<VenueReviewsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: event.refresh
            ? VenueReviewsStatus.refreshing
            : VenueReviewsStatus.loading,
        clearError: true,
      ),
    );

    final Either<AppException, VenueReviewPageModel> response =
        await _getVenueReviewsUseCase(
          venueId: event.venueId,
          page: 1,
          perPage: event.perPage,
        );

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: VenueReviewsStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (VenueReviewPageModel page) => emit(
        state.copyWith(
          status: VenueReviewsStatus.success,
          page: page,
          reviews: page.items,
          venueId: event.venueId,
          clearError: true,
        ),
      ),
    );
  }

  FutureOr<void> _onLoadMore(
    LoadMoreVenueReviewsEvent event,
    Emitter<VenueReviewsState> emit,
  ) async {
    // Guarded rather than queued: the scroll listener fires repeatedly near the
    // bottom, and a second request for the same page would duplicate rows.
    if (state.isLoadingMore || !state.canLoadMore) return;

    emit(state.copyWith(status: VenueReviewsStatus.loadingMore));

    final int nextPage = state.page.currentPage + 1;
    final Either<AppException, VenueReviewPageModel> response =
        await _getVenueReviewsUseCase(
          venueId: state.venueId,
          page: nextPage,
          perPage: state.page.perPage,
        );

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          // The rows already on screen stay; only the footer reports the error.
          status: VenueReviewsStatus.success,
          errorMessage: failure.errorMessage,
        ),
      ),
      (VenueReviewPageModel page) {
        final Set<int> seen = state.reviews
            .map((VenueReviewModel e) => e.id)
            .toSet();
        // A review added while the vendor was reading shifts every later page
        // by one, which resends a row this list already has.
        final List<VenueReviewModel> fresh = page.items
            .where((VenueReviewModel e) => e.id == 0 || !seen.contains(e.id))
            .toList();
        emit(
          state.copyWith(
            status: VenueReviewsStatus.success,
            page: page,
            reviews: <VenueReviewModel>[...state.reviews, ...fresh],
            clearError: true,
          ),
        );
      },
    );
  }
}
