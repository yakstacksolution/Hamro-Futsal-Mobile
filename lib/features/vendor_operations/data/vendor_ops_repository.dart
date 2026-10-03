import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/data/data_source/vendor_ops_remote_data_source.dart';
import 'package:hamro_futsal/features/vendor_operations/data/model/court_availability_slots_model.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';

/// Reads what the operations board is built from.
///
/// The Day board is one request: `GET /court-availability-slots` with
/// `type=day` answers for every court of every venue — the courts, their
/// slots and the bookings on them ([loadDay]). The Week table asks for one
/// court's week ([loadCourtWeekSlots]) and that week's bookings. The server
/// still decides what can actually be booked, when the slots are held.
class VendorOpsRepository {
  VendorOpsRepository({
    BookingRepository? bookingRepository,
    VendorOpsRemoteDataSource? remoteDataSource,
  }) : _bookings = bookingRepository ?? BookingRepositoryImpl(),
       _remote = remoteDataSource ?? const VendorOpsRemoteDataSourceImpl();

  final BookingRepository _bookings;
  final VendorOpsRemoteDataSource _remote;

  static const int _bookingsPerPage = 50;
  static const int _maxBookingPages = 20;

  /// Every booking from [from] to [to] (inclusive) — one request for the
  /// week table rather than one per day.
  Future<Either<AppException, List<BookingModel>>> loadBookingsBetween(
    DateTime from,
    DateTime to,
  ) => _loadAll(BookingDateFilter.range(from: from, to: to));

  /// The bookings [week]'s slots carry — the Week table's bookings, with no
  /// `/futsal-bookings` call of their own.
  List<BookingModel> bookingsInWeek(OpsCourtWeekAvailability week) =>
      List<BookingModel>.unmodifiable(
        <int, BookingModel>{
          for (final List<OpsServerSlot> day in week.days.values)
            for (final OpsServerSlot slot in day)
              if (slot.booking case final BookingModel b) b.id: b,
        }.values,
      );

  /// [courtId]'s slots, with their status, for the seven days from
  /// [weekStart].
  Future<Either<AppException, OpsCourtWeekAvailability>> loadCourtWeekSlots({
    required int venueId,
    required int courtId,
    required DateTime start,
    required bool includeEndDate,
    required OpsAvailabilityResponseType type,
  }) async {
    final DateTime end = DateTime(start.year, start.month, start.day + 6);
    try {
      final response = await _remote.getCourtAvailabilitySlots(
        venueId: type == OpsAvailabilityResponseType.week ? venueId : null,
        courtId: type == OpsAvailabilityResponseType.week ? courtId : null,
        startDate: isoDate(start),
        endDate: type == OpsAvailabilityResponseType.week && includeEndDate
            ? isoDate(end)
            : null,
        type: type.name,
      );
      if (response.isError()) return left(ResponseHelper.error(response));
      return right(
        CourtAvailabilitySlotsModel.fromResponse(
          response.getValue(),
          courtId: courtId,
          start: start,
          type: type,
          fetchedAt: KathmanduClock.now(),
        ),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not load this court\'s week from the server.',
          statusCode: 0,
        ),
      );
    }
  }

  /// The whole Day board for [date] — every venue's courts, their slots and
  /// the bookings on them — in one
  /// `GET /court-availability-slots?start_date=&type=day`.
  Future<Either<AppException, OpsDayAvailability>> loadDay(
    DateTime date,
  ) async {
    try {
      final response = await _remote.getCourtAvailabilitySlots(
        startDate: isoDate(date),
        type: OpsAvailabilityResponseType.day.name,
      );
      if (response.isError()) return left(ResponseHelper.error(response));
      return right(
        CourtAvailabilitySlotsModel.fromDayResponse(
          response.getValue(),
          date: date,
          fetchedAt: KathmanduClock.now(),
        ),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not load the day\'s slots from the server.',
          statusCode: 0,
        ),
      );
    }
  }

  /// Every page of [filter]'s bookings: the first page says how many there
  /// are, and the rest are fetched together rather than one after another.
  Future<Either<AppException, List<BookingModel>>> _loadAll(
    BookingDateFilter filter,
  ) async {
    Future<Either<AppException, PaginatedBookings>> page(int n) =>
        _bookings.getFutsalBookings(
          BookingListQuery(
            page: n,
            perPage: _bookingsPerPage,
            status: 'all',
            dateFilter: filter,
          ),
        );

    final Either<AppException, PaginatedBookings> first = await page(1);
    return first.fold(left, (PaginatedBookings firstPage) async {
      final int last = firstPage.items.isEmpty
          ? 1
          : firstPage.lastPage.clamp(1, _maxBookingPages);
      final List<Either<AppException, PaginatedBookings>> rest =
          await Future.wait(<Future<Either<AppException, PaginatedBookings>>>[
            for (int n = firstPage.currentPage + 1; n <= last; n++) page(n),
          ]);
      final List<BookingModel> all = <BookingModel>[...firstPage.items];
      for (final Either<AppException, PaginatedBookings> r in rest) {
        final AppException? failure = r.fold((AppException e) => e, (_) {
          return null;
        });
        if (failure != null) return left(failure);
        all.addAll(r.getOrElse(() => throw StateError('unreachable')).items);
      }
      return right(List<BookingModel>.unmodifiable(all));
    });
  }
}
