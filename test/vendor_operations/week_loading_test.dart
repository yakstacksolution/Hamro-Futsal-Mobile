import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/data/model/court_availability_slots_model.dart';
import 'package:hamro_futsal/features/vendor_operations/data/vendor_ops_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';
import 'package:shimmer/shimmer.dart';

class _NoBookings implements BookingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The day's courts (as staging answers `type=day`) and a court's week, each
/// arriving only when its gate is released.
class _GatedRepo extends VendorOpsRepository {
  _GatedRepo() : super(bookingRepository: _NoBookings());

  final Completer<void> _dayGate = Completer<void>();
  final Completer<void> _weekGate = Completer<void>();
  void releaseDay() => _dayGate.complete();
  void releaseWeek() => _weekGate.complete();

  @override
  Future<Either<AppException, List<BookingModel>>> loadBookingsBetween(
    DateTime from,
    DateTime to,
  ) async => right(const <BookingModel>[]);

  @override
  Future<Either<AppException, OpsDayAvailability>> loadDay(
    DateTime date,
  ) async {
    await _dayGate.future;
    return right(
      CourtAvailabilitySlotsModel.fromDayResponse(
        jsonDecode(
          File(
            'test/vendor_operations/fixtures/court_availability_slots_day.json',
          ).readAsStringSync().replaceAll('2026-09-28', isoDate(date)),
        ),
        date: date,
        fetchedAt: DateTime(2026, 9, 27, 13, 5),
      ),
    );
  }

  @override
  Future<Either<AppException, OpsCourtWeekAvailability>> loadCourtWeekSlots({
    required int venueId,
    required int courtId,
    required DateTime start,
    required bool includeEndDate,
    required OpsAvailabilityResponseType type,
  }) async {
    await _weekGate.future;
    return right(
      CourtAvailabilitySlotsModel.fromResponse(
        jsonDecode(
          File(
            'test/vendor_operations/fixtures/court_availability_slots_week.json',
          ).readAsStringSync(),
        ),
        courtId: courtId,
        start: start,
        type: type,
        fetchedAt: DateTime(2026, 9, 27, 13, 5),
      ),
    );
  }
}

void main() {
  setUp(
    // Sunday 27 Sep 2026, 13:30 in Kathmandu.
    () => KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 27, 7, 45)),
  );
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  testWidgets('Day and Week show a skeleton, not "closed", until slots load', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final _GatedRepo repo = _GatedRepo();
    await tester.pumpWidget(
      MaterialApp(
        theme: FutsalTheme.lightTheme,
        home: Scaffold(
          body: VendorOperationsHome(repository: repo, demo: false),
        ),
      ),
    );
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    // Day view first: one call brings the courts and their slots, so the
    // page waits for it rather than drawing courts as closed.
    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.text('No schedule set'), findsNothing);

    repo.releaseDay();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(Shimmer), findsNothing);
    expect(find.text('Court 1'), findsWidgets);
    expect(find.text('No schedule set'), findsNothing);

    final Finder week = find.text('Week');
    await tester.scrollUntilVisible(
      week,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(week);
    await tester.pump(const Duration(milliseconds: 50));

    // Fetching: the skeleton, and no closed days drawn from the (empty)
    // schedule.
    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.text('Time slot'), findsNothing);
    expect(find.text('No schedule set'), findsNothing);
    expect(find.textContaining('Updated'), findsNothing);

    repo.releaseWeek();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(Shimmer), findsNothing);
    expect(find.text('Time slot'), findsOneWidget);
    expect(find.text('Available'), findsWidgets);
    expect(find.textContaining('Updated'), findsNothing);

    // Back to Day: already loaded, drawn at once.
    await tester.tap(find.text('Day'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(Shimmer), findsNothing);
    expect(find.text('No schedule set'), findsNothing);
    expect(find.text('Court 1'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
