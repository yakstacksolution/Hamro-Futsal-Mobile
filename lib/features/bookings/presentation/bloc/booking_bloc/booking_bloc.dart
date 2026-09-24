import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/cache/hive/hive_boxes.dart';
import 'package:hamro_futsal/core/cache/hive/hive_cache_service.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._useCase) : super(const BookingState()) {
    on<FetchMyBookingsEvent>(_onFetchMyBookings);
    on<FetchFutsalBookingsEvent>(_onFetchFutsalBookings);
    on<ApplyMyBookingsFiltersEvent>(_onApplyMyFilters);
    on<ApplyFutsalBookingsFiltersEvent>(_onApplyFutsalFilters);
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
    dateFilter: state.myDateFilter,
    order: state.myOrder,
    request: (int page, BookingStatusFilter filter) => _useCase.getMyBookings(
      BookingListQuery(
        page: page,
        perPage: _perPage,
        status: filter.query,
        dateFilter: state.myDateFilter,
        order: state.myOrder,
      ),
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
    dateFilter: state.futsalDateFilter,
    order: state.futsalOrder,
    request: (int page, BookingStatusFilter filter) =>
        _useCase.getFutsalBookings(
          BookingListQuery(
            page: page,
            perPage: _perPage,
            status: filter.query,
            dateFilter: state.futsalDateFilter,
            order: state.futsalOrder,
          ),
        ),
  );

  void _onApplyMyFilters(
    ApplyMyBookingsFiltersEvent event,
    Emitter<BookingState> emit,
  ) => _applyFilters(
    emit: emit,
    dateFilter: event.dateFilter,
    order: event.order,
    currentDateFilter: state.myDateFilter,
    currentOrder: state.myOrder,
    write: (BookingDateFilter dateFilter, BookingDateOrder order) =>
        state.copyWith(
          myDateFilter: dateFilter,
          myOrder: order,
          myLists: const <BookingStatusFilter, BookingListSlice>{},
        ),
    refetch: (BookingStatusFilter filter) =>
        add(FetchMyBookingsEvent(filter: filter, force: true)),
    selected: state.mySelectedFilter,
  );

  void _onApplyFutsalFilters(
    ApplyFutsalBookingsFiltersEvent event,
    Emitter<BookingState> emit,
  ) => _applyFilters(
    emit: emit,
    dateFilter: event.dateFilter,
    order: event.order,
    currentDateFilter: state.futsalDateFilter,
    currentOrder: state.futsalOrder,
    write: (BookingDateFilter dateFilter, BookingDateOrder order) =>
        state.copyWith(
          futsalDateFilter: dateFilter,
          futsalOrder: order,
          futsalLists: const <BookingStatusFilter, BookingListSlice>{},
        ),
    refetch: (BookingStatusFilter filter) =>
        add(FetchFutsalBookingsEvent(filter: filter, force: true)),
    selected: state.futsalSelectedFilter,
  );

  /// Stores a new window/order and starts the list again from page 1.
  ///
  /// The cached slices go with it: every one of them holds rows fetched under
  /// the old query, and their page cursors count pages of a result set that no
  /// longer exists. Keeping them would mean appending page 2 of the new window
  /// onto page 1 of the old one.
  void _applyFilters({
    required Emitter<BookingState> emit,
    required BookingDateFilter dateFilter,
    required BookingDateOrder order,
    required BookingDateFilter currentDateFilter,
    required BookingDateOrder currentOrder,
    required BookingState Function(BookingDateFilter, BookingDateOrder) write,
    required void Function(BookingStatusFilter) refetch,
    required BookingStatusFilter selected,
  }) {
    if (dateFilter == currentDateFilter && order == currentOrder) return;
    // Anything still in flight answers the old query, so its result must not
    // be written into the new one's slices.
    _inFlight.clear();
    emit(write(dateFilter, order));
    refetch(selected);
  }

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
    required BookingDateFilter dateFilter,
    required BookingDateOrder order,
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
    final String cacheScope = _bookingListCacheScope(
      kind: kind,
      filter: target,
      dateFilter: dateFilter,
      order: order,
      page: page,
    );
    final List<BookingModel> cached = loadMore
        ? const <BookingModel>[]
        : await HiveCacheService.instance.readList<BookingModel>(
            boxName: HiveBoxes.bookingList,
            scope: cacheScope,
            fromJson: BookingModel.fromJson,
          );
    if (cached.isNotEmpty && slice.bookings.isEmpty) {
      slice = slice.copyWith(
        loadStatus: BookingLoadStatus.success,
        bookings: cached,
        currentPage: 1,
        hasMorePages: true,
        clearError: true,
      );
      emit(writeSlice(target, slice));
    }

    if (loadMore) {
      emit(
        writeSlice(
          target,
          slice.copyWith(isLoadingMore: true, clearError: true),
        ),
      );
    } else if (slice.bookings.isNotEmpty) {
      // Rows already on screen stay there while the new ones are fetched; the
      // page shows a slim progress line instead of blanking to a skeleton.
      //
      // This holds for *every* refetch over rows, not just the ones that asked
      // to be silent. Blanking to the skeleton swaps the ListView out for a
      // different widget, which destroys its ScrollPosition — and a refetch
      // lands most often right in the middle of the pull-to-refresh drag that
      // started it. The replacement position came back (via the page's
      // PageStorageKey) holding the drag's overscroll offset but with no drag
      // and no spring left to carry it home, so the list stayed frozen
      // hundreds of pixels down the screen with the refresh spinner stuck.
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
      (pageResult) {
        final List<BookingModel> rows = loadMore
            ? _mergeBookings(slice.bookings, pageResult.items)
            : pageResult.items;
        _syncBookingList(
          scope: cacheScope,
          rows: pageResult.items,
          deleteMissing: !loadMore,
        );

        // A next page has to actually move the list on. A server that echoes
        // the page it was already given — or reports `has_more_pages` with a
        // `current_page` that never advances — otherwise leaves the list short
        // with `hasMorePages` still set, and the scroll listener sees room
        // below it and asks for the same page again on the very next frame:
        // a request and a full list rebuild every frame, for as long as the
        // page is on screen. That is the lock-up, so pagination ends here
        // instead.
        final bool advanced =
            !loadMore ||
            (pageResult.currentPage > slice.currentPage &&
                rows.length > slice.bookings.length);

        emit(
          writeSlice(
            target,
            slice.copyWith(
              loadStatus: BookingLoadStatus.success,
              bookings: rows,
              // Never step the cursor backwards on a load-more that the server
              // answered with a stale page — the next request would repeat it.
              currentPage:
                  loadMore && pageResult.currentPage < slice.currentPage
                  ? slice.currentPage
                  : pageResult.currentPage,
              lastPage: pageResult.lastPage,
              total: pageResult.total,
              hasMorePages: advanced && pageResult.hasMorePages,
              isLoadingMore: false,
              isRefreshing: false,
              loadMoreFailed: false,
              clearError: true,
            ),
          ).copyWith(refreshTick: state.refreshTick + 1),
        );
      },
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

  String _bookingListCacheScope({
    required String kind,
    required BookingStatusFilter filter,
    required BookingDateFilter dateFilter,
    required BookingDateOrder order,
    required int page,
  }) {
    final Map<String, dynamic> query = <String, dynamic>{
      'kind': kind,
      'status': filter.query,
      'page': page,
      'per_page': _perPage,
      'order': order.name,
      ...dateFilter.toQueryParameters(),
    };
    return '${HiveCacheService.instance.userScope}:${jsonEncode(query)}';
  }

  void _syncBookingList({
    required String scope,
    required List<BookingModel> rows,
    required bool deleteMissing,
  }) {
    unawaited(
      HiveCacheService.instance.syncList<BookingModel>(
        boxName: HiveBoxes.bookingList,
        scope: scope,
        items: rows,
        idOf: (BookingModel booking) => booking.id,
        toJson: (BookingModel booking) => booking.toJson(),
        deleteMissing: deleteMissing,
      ),
    );
    for (final BookingModel booking in rows) {
      unawaited(
        HiveCacheService.instance.syncItem(
          boxName: HiveBoxes.bookingDetails,
          key: '${HiveCacheService.instance.userScope}:${booking.id}',
          json: booking.toJson(),
        ),
      );
    }
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
