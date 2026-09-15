import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_futsal/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';

void main() {
  test('the date window and order reach the request', () async {
    final _SpyRepository repository = _SpyRepository();
    final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
    addTearDown(bloc.close);

    bloc.add(
      ApplyFutsalBookingsFiltersEvent(
        dateFilter: BookingDateFilter.month(DateTime(2026, 9)),
        order: BookingDateOrder.ascending,
      ),
    );
    await bloc.stream.firstWhere(
      (BookingState s) =>
          s.futsalSlice(BookingStatusFilter.all).loadStatus ==
          BookingLoadStatus.success,
    );

    expect(repository.futsalPayloads.last, <String, dynamic>{
      'page': 1,
      'per_page': 10,
      'status': 'all',
      'date_filter': 'month',
      'month': '2026-09',
      'from_date': '2026-09-01',
      'to_date': '2026-09-30',
      'sort': 'date',
      'order': 'asc',
    });
  });

  // The window is a server filter, so every cached status was fetched under the
  // old one. Keeping them would append page 2 of the new window onto page 1 of
  // the old.
  test(
    'a new window drops the cached statuses and restarts at page 1',
    () async {
      final _SpyRepository repository = _SpyRepository();
      final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
      addTearDown(bloc.close);

      // Fetch two statuses, and page 2 of one of them.
      bloc.add(const FetchFutsalBookingsEvent());
      await bloc.stream.firstWhere(
        (BookingState s) =>
            s.futsalSlice(BookingStatusFilter.all).loadStatus ==
            BookingLoadStatus.success,
      );
      bloc.add(
        const FetchFutsalBookingsEvent(filter: BookingStatusFilter.pending),
      );
      await bloc.stream.firstWhere(
        (BookingState s) =>
            s.futsalSlice(BookingStatusFilter.pending).loadStatus ==
            BookingLoadStatus.success,
      );
      bloc.add(const FetchFutsalBookingsEvent(loadMore: true, silent: true));
      await bloc.stream.firstWhere(
        (BookingState s) =>
            s.futsalSlice(BookingStatusFilter.all).currentPage > 1,
      );

      bloc.add(
        ApplyFutsalBookingsFiltersEvent(
          dateFilter: BookingDateFilter.day(DateTime(2026, 9, 10)),
          order: BookingDateOrder.descending,
        ),
      );
      await bloc.stream.firstWhere(
        (BookingState s) =>
            s.futsalSlice(BookingStatusFilter.all).loadStatus ==
                BookingLoadStatus.success &&
            s.futsalDateFilter.mode == BookingDateMode.day,
      );

      // The other status is back to untouched, and the visible one restarted.
      expect(
        bloc.state.futsalSlice(BookingStatusFilter.pending).isIdle,
        isTrue,
      );
      expect(bloc.state.futsalSlice(BookingStatusFilter.all).currentPage, 1);
      expect(repository.futsalPayloads.last['page'], 1);
      expect(repository.futsalPayloads.last['date'], '2026-09-10');
    },
  );

  test('re-applying the same window sends nothing', () async {
    final _SpyRepository repository = _SpyRepository();
    final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
    addTearDown(bloc.close);

    bloc.add(const FetchFutsalBookingsEvent());
    await bloc.stream.firstWhere(
      (BookingState s) =>
          s.futsalSlice(BookingStatusFilter.all).loadStatus ==
          BookingLoadStatus.success,
    );
    final int before = repository.futsalPayloads.length;

    bloc.add(
      const ApplyFutsalBookingsFiltersEvent(
        dateFilter: BookingDateFilter.all(),
        order: BookingDateOrder.descending,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(repository.futsalPayloads.length, before);
  });

  test('the two lists keep separate windows', () async {
    final _SpyRepository repository = _SpyRepository();
    final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
    addTearDown(bloc.close);

    bloc.add(
      ApplyFutsalBookingsFiltersEvent(
        dateFilter: BookingDateFilter.day(DateTime(2026, 9, 10)),
        order: BookingDateOrder.descending,
      ),
    );
    await bloc.stream.firstWhere(
      (BookingState s) => s.futsalDateFilter.mode == BookingDateMode.day,
    );

    expect(bloc.state.myDateFilter, const BookingDateFilter.all());
    expect(bloc.state.futsalDateFilter.mode, BookingDateMode.day);
  });
}

/// Records the payload of every list request.
final class _SpyRepository implements BookingRepository {
  final List<Map<String, dynamic>> futsalPayloads = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> myPayloads = <Map<String, dynamic>>[];

  final BookingModel _booking = BookingModel(
    id: 1,
    bookingRef: 'HF-1',
    courtName: 'Court A',
    futsalName: 'Goal Arena',
    date: DateTime(2026, 9, 10),
    startTime: '18:00',
    endTime: '19:00',
    status: BookingStatus.confirmed,
    amount: 1800,
  );

  PaginatedBookings _page(BookingListQuery query) => PaginatedBookings(
    items: <BookingModel>[_booking.copyWith(id: query.page)],
    currentPage: query.page,
    lastPage: 3,
    perPage: query.perPage,
    total: 30,
    hasMorePages: query.page < 3,
  );

  @override
  Future<Either<AppException, PaginatedBookings>> getFutsalBookings(
    BookingListQuery query,
  ) async {
    futsalPayloads.add(query.toQueryParameters());
    return right(_page(query));
  }

  @override
  Future<Either<AppException, PaginatedBookings>> getMyBookings(
    BookingListQuery query,
  ) async {
    myPayloads.add(query.toQueryParameters());
    return right(_page(query));
  }

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(int id) async =>
      right(_booking);

  @override
  Future<Either<AppException, BookingReviewModel?>> getBookingReview(
    int bookingId,
  ) async => right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
