import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/domain/model/paginated_bookings.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._useCase) : super(const BookingState()) {
    on<FetchMyBookingsEvent>(_onFetchMyBookings);
    on<FetchFutsalBookingsEvent>(_onFetchFutsalBookings);
  }

  final GetBookingsUseCase _useCase;

  /// Page size for both booking endpoints.
  static const int _perPage = 10;

  /// Requests currently out, keyed by list + status + page.
  final Set<String> _inFlight = <String>{};

  FutureOr<void> _onFetchMyBookings(
    FetchMyBookingsEvent event,
    Emitter<BookingState> emit,
  ) => _fetch(
    emit: emit,
    kind: 'mine',
    filter: event.filter,
    select: event.select,
    force: event.force,
    silent: event.silent,
    loadMore: event.loadMore,
    selected: state.mySelectedFilter,
    sliceOf: (BookingStatusFilter filter) => state.mySlice(filter),
    selectFilter: (BookingStatusFilter filter) =>
        state.copyWith(mySelectedFilter: filter),
    writeSlice: (BookingStatusFilter filter, BookingListSlice slice) =>
        state.withMySlice(filter, slice),
    request: (int page, BookingStatusFilter filter) => _useCase.getMyBookings(
      page: page,
      perPage: _perPage,
      status: filter.query,
    ),
  );

  FutureOr<void> _onFetchFutsalBookings(
    FetchFutsalBookingsEvent event,
    Emitter<BookingState> emit,
  ) => _fetch(
    emit: emit,
    kind: 'futsal',
    filter: event.filter,
    select: event.select,
    force: event.force,
    silent: event.silent,
    loadMore: event.loadMore,
    selected: state.futsalSelectedFilter,
    sliceOf: (BookingStatusFilter filter) => state.futsalSlice(filter),
    selectFilter: (BookingStatusFilter filter) =>
        state.copyWith(futsalSelectedFilter: filter),
    writeSlice: (BookingStatusFilter filter, BookingListSlice slice) =>
        state.withFutsalSlice(filter, slice),
    request: (int page, BookingStatusFilter filter) => _useCase
        .getFutsalBookings(page: page, perPage: _perPage, status: filter.query),
  );

  /// The one fetch routine both lists share.
  ///
  /// Everything that differs between `/bookings` and `/futsal-bookings` — which
  /// slice map to read and write, which request to make — arrives as a
  /// parameter, so the paging, the caching and the error handling exist once
  /// instead of twice in near-identical copies.
  Future<void> _fetch({
    required Emitter<BookingState> emit,
    required String kind,
    required BookingStatusFilter? filter,
    required bool select,
    required bool force,
    required bool silent,
    required bool loadMore,
    required BookingStatusFilter selected,
    required BookingListSlice Function(BookingStatusFilter) sliceOf,
    required BookingState Function(BookingStatusFilter) selectFilter,
    required BookingState Function(BookingStatusFilter, BookingListSlice)
    writeSlice,
    required Future<Either<AppException, PaginatedBookings>> Function(
      int page,
      BookingStatusFilter filter,
    )
    request,
  }) async {
    final BookingStatusFilter target = filter ?? selected;

    // Selecting is immediate and never waits on the network: the page swipes to
    // a status that already holds rows and shows them at once.
    if (select && target != selected) {
      emit(selectFilter(target));
    }

    BookingListSlice slice = sliceOf(target);

    // A status already fetched is served from state. `force` (a swipe onto the
    // page, pull-to-refresh, an explicit retry) and `loadMore` still go out.
    if (select && !force && !loadMore && !slice.isIdle) return;

    if (loadMore && (!slice.hasMorePages || slice.isLoadingMore)) return;

    // One request per status at a time. Swiping back and forth, or landing on a
    // page the tab-visible refresh is already loading, must not stack requests
    // — the last one to answer would otherwise decide what is on screen.
    final int page = loadMore ? slice.currentPage + 1 : 1;
    final String key = '$kind:${target.name}:$page';
    if (_inFlight.contains(key)) return;

    if (loadMore) {
      emit(
        writeSlice(
          target,
          slice.copyWith(isLoadingMore: true, clearError: true),
        ),
      );
    } else if (silent && !slice.isIdle) {
      // Rows already on screen stay there while the new ones are fetched; the
      // page shows a slim progress line instead of blanking to a skeleton.
      emit(
        writeSlice(
          target,
          slice.copyWith(isRefreshing: true, clearError: true),
        ),
      );
    } else {
      // Nothing to keep — the skeleton is the honest state.
      emit(
        writeSlice(
          target,
          slice.copyWith(
            loadStatus: BookingLoadStatus.loading,
            clearError: true,
          ),
        ),
      );
    }

    _inFlight.add(key);
    Either<AppException, PaginatedBookings> result;
    try {
      result = await request(page, target);
    } catch (error) {
      // Anything the layers below fail to turn into a Left (a socket drop, a
      // token-refresh crash) would otherwise escape this handler and leave the
      // status on `loading` — an endless skeleton with no way back. Surface it
      // as a failure so the list shows its error view with a retry.
      result = left(_asException(error));
    } finally {
      _inFlight.remove(key);
    }

    slice = sliceOf(target);
    result.fold(
      (error) => emit(
        writeSlice(
          target,
          slice.copyWith(
            // A failed *next* page — or a failed refresh over rows already on
            // screen — leaves those rows alone. Only a load with nothing behind
            // it falls back to the error view.
            loadStatus: loadMore || slice.bookings.isNotEmpty
                ? BookingLoadStatus.success
                : BookingLoadStatus.failure,
            error: error.errorMessage,
            isLoadingMore: false,
            isRefreshing: false,
            loadMoreFailed: loadMore,
          ),
        ).copyWith(refreshTick: state.refreshTick + 1),
      ),
      (pageResult) => emit(
        writeSlice(
          target,
          slice.copyWith(
            loadStatus: BookingLoadStatus.success,
            bookings: loadMore
                ? _mergeBookings(slice.bookings, pageResult.items)
                : pageResult.items,
            currentPage: pageResult.currentPage,
            lastPage: pageResult.lastPage,
            total: pageResult.total,
            hasMorePages: pageResult.hasMorePages,
            isLoadingMore: false,
            isRefreshing: false,
            loadMoreFailed: false,
            clearError: true,
          ),
        ).copyWith(refreshTick: state.refreshTick + 1),
      ),
    );
  }

  List<BookingModel> _mergeBookings(
    List<BookingModel> existing,
    List<BookingModel> incoming,
  ) {
    final Map<int, BookingModel> byId = <int, BookingModel>{
      for (final BookingModel booking in existing) booking.id: booking,
      for (final BookingModel booking in incoming) booking.id: booking,
    };
    return byId.values.toList(growable: false);
  }

  /// An [AppException] for anything the layers below threw instead of
  /// returning as a Left.
  AppException _asException(Object error) {
    if (error is AppException && error.errorMessage.trim().isNotEmpty) {
      return error;
    }
    final String message = error is SocketException || error is TimeoutException
        ? 'No internet connection. Check your network and try again.'
        : 'Something went wrong while loading bookings. Please try again.';
    return DefaultException(errorMessage: message, statusCode: 0);
  }
}
