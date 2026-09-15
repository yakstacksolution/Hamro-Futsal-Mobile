import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_futsal/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';

/// The list's scroll listener asks for the next page whenever `hasMorePages`
/// is set and there is room left below the rows in hand. So a next page that
/// brings nothing new must end the pagination — otherwise the same request
/// goes out again on the very next frame, forever, and the screen locks up.
void main() {
  test('a next page the server does not advance ends the pagination', () async {
    final _StuckPageRepository repository = _StuckPageRepository();
    final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
    addTearDown(bloc.close);

    bloc.add(const FetchFutsalBookingsEvent());
    await bloc.stream.firstWhere(
      (BookingState s) =>
          s.futsalSlice(BookingStatusFilter.all).loadStatus ==
          BookingLoadStatus.success,
    );
    expect(
      bloc.state.futsalSlice(BookingStatusFilter.all).hasMorePages,
      isTrue,
    );

    bloc.add(const FetchFutsalBookingsEvent(silent: true, loadMore: true));
    final BookingState after = await bloc.stream.firstWhere(
      (BookingState s) => !s.futsalSlice(BookingStatusFilter.all).isLoadingMore,
    );

    final BookingListSlice slice = after.futsalSlice(BookingStatusFilter.all);
    expect(repository.calls, 2);
    expect(slice.bookings.length, 1, reason: 'nothing new arrived');
    expect(
      slice.hasMorePages,
      isFalse,
      reason: 'pagination must stop, or the list re-requests every frame',
    );
  });

  /// Blanking a list that already has rows swaps the ListView out and destroys
  /// its ScrollPosition — mid pull-to-refresh, that strands the list at the
  /// drag's overscroll offset with no spring left to bring it back.
  test(
    'a refetch over existing rows never falls back to the skeleton',
    () async {
      final _StuckPageRepository repository = _StuckPageRepository();
      final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
      addTearDown(bloc.close);

      bloc.add(const FetchFutsalBookingsEvent());
      await bloc.stream.firstWhere(
        (BookingState s) =>
            s.futsalSlice(BookingStatusFilter.all).loadStatus ==
            BookingLoadStatus.success,
      );

      final List<BookingLoadStatus> seen = <BookingLoadStatus>[];
      final StreamSubscription<BookingState> sub = bloc.stream.listen(
        (BookingState s) =>
            seen.add(s.futsalSlice(BookingStatusFilter.all).loadStatus),
      );
      addTearDown(sub.cancel);

      // `silent: false` is what the tab-visible refresh sends whenever the slice
      // is not in the success state.
      bloc.add(const FetchFutsalBookingsEvent(force: true));
      await bloc.stream.firstWhere(
        (BookingState s) =>
            !s.futsalSlice(BookingStatusFilter.all).isRefreshing,
      );

      expect(seen, isNot(contains(BookingLoadStatus.loading)));
      expect(
        bloc.state.futsalSlice(BookingStatusFilter.all).bookings,
        isNotEmpty,
      );
    },
  );

  test('a failed next page keeps the rows and flags the retry', () async {
    final _StuckPageRepository repository = _StuckPageRepository(failFrom: 2);
    final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
    addTearDown(bloc.close);

    bloc.add(const FetchFutsalBookingsEvent());
    await bloc.stream.firstWhere(
      (BookingState s) =>
          s.futsalSlice(BookingStatusFilter.all).loadStatus ==
          BookingLoadStatus.success,
    );

    bloc.add(const FetchFutsalBookingsEvent(silent: true, loadMore: true));
    final BookingState after = await bloc.stream.firstWhere(
      (BookingState s) => s.futsalSlice(BookingStatusFilter.all).loadMoreFailed,
    );

    final BookingListSlice slice = after.futsalSlice(BookingStatusFilter.all);
    expect(slice.bookings.length, 1);
    expect(slice.loadStatus, BookingLoadStatus.success);
    expect(slice.isLoadingMore, isFalse);
  });
}

/// A server that reports more pages but keeps answering with page 1's row —
/// the shape that turned auto-pagination into a per-frame request loop.
final class _StuckPageRepository implements BookingRepository {
  _StuckPageRepository({this.failFrom});

  /// Page number from which the request fails, if any.
  final int? failFrom;
  int calls = 0;

  final BookingModel _booking = BookingModel(
    id: 1,
    bookingRef: 'HF-1',
    courtName: 'Court A',
    futsalName: 'Goal Arena',
    date: DateTime(2026, 7, 4),
    startTime: '18:00',
    endTime: '19:00',
    status: BookingStatus.confirmed,
    amount: 1800,
  );

  @override
  Future<Either<AppException, PaginatedBookings>> getFutsalBookings(
    BookingListQuery query,
  ) async {
    calls++;
    if (failFrom != null && query.page >= failFrom!) {
      return left(
        DefaultException(errorMessage: 'Server error.', statusCode: 500),
      );
    }
    return right(
      PaginatedBookings(
        items: <BookingModel>[_booking],
        // Never moves on, however many pages are asked for.
        currentPage: 1,
        lastPage: 9,
        perPage: query.perPage,
        total: 90,
        hasMorePages: true,
      ),
    );
  }

  @override
  Future<Either<AppException, PaginatedBookings>> getMyBookings(
    BookingListQuery query,
  ) => getFutsalBookings(query);

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(int id) async =>
      right(_booking);

  @override
  Future<Either<AppException, BookingModel?>> cancelBooking(int id) async =>
      right(_booking);

  @override
  Future<Either<AppException, BookingReviewModel?>> getBookingReview(
    int bookingId,
  ) async => right(null);

  @override
  Future<Either<AppException, BookingReviewModel>> submitBookingReview({
    required int bookingId,
    required double rating,
    required String review,
  }) async => right(BookingReviewModel(rating: rating, review: review));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
