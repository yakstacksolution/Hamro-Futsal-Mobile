import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/data/data_source/vendor_ops_remote_data_source.dart';
import 'package:hamro_futsal/features/vendor_operations/data/service/vendor_ops_socket_service.dart';
import 'package:hamro_futsal/features/vendor_operations/data/vendor_ops_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';

/// Any bookings call fails the test: the Day board must not make one.
class _NoBookings implements BookingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected bookings call: ${invocation.memberName}');
}

/// Records every `GET /court-availability-slots` and answers with the staging
/// `type=day` sample for the asked date.
class _Remote implements VendorOpsRemoteDataSource {
  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];

  @override
  Future<Result> getCourtAvailabilitySlots({
    int? venueId,
    int? courtId,
    required String startDate,
    String? endDate,
    String type = 'week',
  }) async {
    calls.add(<String, Object?>{
      'venue_id': venueId,
      'court_id': courtId,
      'start_date': startDate,
      'end_date': endDate,
      'type': type,
    });
    return Result<dynamic, dynamic>.success(
      jsonDecode(
        File(
          'test/vendor_operations/fixtures/court_availability_slots_day.json',
        ).readAsStringSync().replaceAll('2026-09-28', startDate),
      ),
    );
  }
}

void main() {
  setUp(
    // Monday 28 Sep 2026, 20:00 in Kathmandu.
    () =>
        KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 28, 14, 15)),
  );
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  test('the Day board is one request for every venue and court', () async {
    final _Remote remote = _Remote();
    final VendorOpsBloc bloc = VendorOpsBloc(
      repository: VendorOpsRepository(
        bookingRepository: _NoBookings(),
        remoteDataSource: remote,
      ),
    )..add(const VendorOpsStarted());
    await pumpEventQueue();

    expect(remote.calls, <Map<String, Object?>>[
      <String, Object?>{
        'venue_id': null,
        'court_id': null,
        'start_date': '2026-09-28',
        'end_date': null,
        'type': 'day',
      },
      // The Week table's court's week, prefetched behind the Day board.
      <String, Object?>{
        'venue_id': 1,
        'court_id': 6,
        'start_date': '2026-09-27',
        'end_date': '2026-10-03',
        'type': 'week',
      },
    ]);
    // Courts, slots and bookings all came from that one answer.
    expect(bloc.state.status, VendorOpsStatus.success);
    expect(bloc.state.courts, hasLength(4));
    expect(bloc.state.bookings.map((b) => b.id), <int>[408]);
    expect(bloc.state.board!.venues, hasLength(3));

    // Another date in the same week: one more request, and the prefetched
    // week is kept.
    bloc.add(VendorOpsDateChanged(DateTime(2026, 9, 29)));
    await pumpEventQueue();
    expect(remote.calls, hasLength(3));
    expect(remote.calls.last['start_date'], '2026-09-29');

    // A refresh: one more request, for the day only.
    bloc.add(const VendorOpsRefreshed());
    await pumpEventQueue();
    expect(remote.calls, hasLength(4));
    expect(remote.calls.last['type'], 'day');
    await bloc.close();
  });

  test('the shown channel is watched; an event fetches it again', () async {
    final _Remote remote = _Remote();
    final _Socket socket = _Socket();
    final VendorOpsBloc bloc = VendorOpsBloc(
      repository: VendorOpsRepository(
        bookingRepository: _EmptyWeekBookings(),
        remoteDataSource: remote,
      ),
      socket: socket,
    )..add(const VendorOpsStarted());
    await pumpEventQueue();

    // Day board: the date's channel.
    expect(socket.watched.last, <String>['private-vendor.booking.2026-09-28']);
    // The day, and the Week table's week prefetched behind it.
    expect(remote.calls, hasLength(2));

    // A burst of events: one quiet refetch once they settle.
    socket
      ..emit('booking.confirmed')
      ..emit('payment.updated');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(remote.calls, hasLength(2));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await pumpEventQueue();
    expect(remote.calls, hasLength(3));
    expect(remote.calls.last['type'], 'day');

    // Another date: its own channel.
    bloc.add(VendorOpsDateChanged(DateTime(2026, 9, 29)));
    await pumpEventQueue();
    expect(socket.watched.last, <String>['private-vendor.booking.2026-09-29']);

    // Week table: the shown court's week, Sunday to Saturday.
    bloc.add(const VendorOpsViewChanged(OpsAvailabilityView.week));
    await pumpEventQueue();
    expect(socket.watched.last, <String>[
      'private-vendor.start_date.2026-09-27.end_date.2026-10-03'
          '.venue-id.1.court-id.6',
    ]);

    // Another court, then the next week: each its own channel.
    bloc.add(const VendorOpsWeekCourtChanged(14));
    await pumpEventQueue();
    expect(socket.watched.last, <String>[
      'private-vendor.start_date.2026-09-27.end_date.2026-10-03'
          '.venue-id.2.court-id.14',
    ]);
    bloc.add(VendorOpsDateChanged(DateTime(2026, 10, 6)));
    await pumpEventQueue();
    expect(socket.watched.last, <String>[
      'private-vendor.start_date.2026-10-04.end_date.2026-10-10'
          '.venue-id.2.court-id.14',
    ]);

    // An event on the week's channel refetches the week.
    final int before = remote.calls.length;
    socket.emit('booking.confirmed');
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await pumpEventQueue();
    expect(
      remote.calls.skip(before).map((Map<String, Object?> c) => c['type']),
      contains('week'),
    );

    // Back to the Day board: the date's channel again.
    bloc.add(const VendorOpsViewChanged(OpsAvailabilityView.day));
    await pumpEventQueue();
    expect(socket.watched.last, <String>['private-vendor.booking.2026-10-06']);

    await bloc.close();
    expect(socket.disposed, isTrue);
  });

  test('the Week table always has a court selected', () async {
    final _Remote remote = _Remote();
    final VendorOpsBloc bloc = VendorOpsBloc(
      repository: VendorOpsRepository(
        bookingRepository: _EmptyWeekBookings(),
        remoteDataSource: remote,
      ),
    )..add(const VendorOpsStarted());
    await pumpEventQueue();

    // None picked: the first court is selected and its week loaded.
    bloc.add(const VendorOpsViewChanged(OpsAvailabilityView.week));
    await pumpEventQueue();
    expect(bloc.state.weekCourtId, 6);
    expect(bloc.state.tableCourt?.id, 6);
    expect(remote.calls.last['court_id'], 6);

    // The venue filter takes that court away: the venue's first court
    // takes its place, and its week is loaded.
    bloc.add(const VendorOpsVenuesFiltered(<int>{2}));
    await pumpEventQueue();
    expect(bloc.state.weekCourtId, 14);
    expect(remote.calls.last['court_id'], 14);

    // A pick inside the filter is kept.
    bloc.add(const VendorOpsWeekCourtChanged(33));
    await pumpEventQueue();
    bloc.add(const VendorOpsVenuesFiltered(<int>{2, 34}));
    await pumpEventQueue();
    expect(bloc.state.weekCourtId, 33);
    await bloc.close();
  });
}

/// Records what the bloc watches; [emit] plays a broadcast.
class _Socket implements VendorOpsSocketService {
  final StreamController<VendorOpsLiveEvent> _events =
      StreamController<VendorOpsLiveEvent>.broadcast();
  final List<List<String>> watched = <List<String>>[];
  bool disposed = false;

  void emit(String name) =>
      _events.add(VendorOpsLiveEvent(channel: watched.last.first, name: name));

  @override
  Stream<VendorOpsLiveEvent> get events => _events.stream;

  @override
  void watch(List<String> channels) => watched.add(channels);

  @override
  void dispose() {
    disposed = true;
    _events.close();
  }
}

/// The Week table's bookings call answers with none.
class _EmptyWeekBookings implements BookingRepository {
  @override
  Future<Either<AppException, PaginatedBookings>> getFutsalBookings(
    BookingListQuery query,
  ) async => right(
    const PaginatedBookings(
      items: <BookingModel>[],
      currentPage: 1,
      lastPage: 1,
      perPage: 50,
      total: 0,
      hasMorePages: false,
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected bookings call: ${invocation.memberName}');
}
