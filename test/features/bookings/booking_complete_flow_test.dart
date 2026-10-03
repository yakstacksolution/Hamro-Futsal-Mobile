import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_futsal/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_futsal/features/bookings/presentation/pages/booking_details_page.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_products_sheet.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_status_page.dart';

/// Confirm → Complete, driven through the real buttons and sheet, with the
/// live `POST /bookings/561/complete` answer standing in for the server.
void main() {
  late BookingModel confirmed;
  late BookingModel completed;
  late int sent;

  setUp(() {
    confirmed = BookingModel.fromResponse(
      jsonDecode(
        File(
          'test/fixtures/futsal_bookings_confirmed_response.json',
        ).readAsStringSync(),
      ),
    );
    completed = BookingModel.fromResponse(
      jsonDecode(
        File('test/fixtures/booking_complete_response.json').readAsStringSync(),
      ),
    );
    sent = 0;
    debugSendCompleteBooking =
        (
          int bookingId, {
          BookingCompleteResult? result,
          List<Map<String, dynamic>>? extraItems,
        }) async {
          sent++;
          return BookingCompletionResponse(success: true, booking: completed);
        };
  });
  tearDown(() => debugSendCompleteBooking = null);

  String? chipLabel(WidgetTester tester) => tester
      .widgetList<DataCardChip>(find.byType(DataCardChip))
      .firstOrNull
      ?.label;

  Future<void> completeThroughSheet(WidgetTester tester) async {
    await tester.pumpAndSettle();
    // The sheet's own Complete button — the last one on screen.
    await tester.tap(find.text('Complete').last);
    await tester.pumpAndSettle();
  }

  testWidgets('details page: completes, says so, and settles the page', (
    WidgetTester tester,
  ) async {
    // The details endpoint answers with the server's current booking.
    final _FakeRepository repository = _FakeRepository(confirmed);
    BookingModel? reported;
    await tester.pumpWidget(
      MaterialApp(
        home: BookingDetailsPage(
          booking: confirmed,
          isFutsalView: true,
          repository: repository,
          onBookingUpdated: (BookingModel b) => reported = b,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(chipLabel(tester), 'confirmed');

    await tester.tap(find.byKey(const Key('complete-booking-button')));
    repository.booking = completed;
    await completeThroughSheet(tester);

    expect(sent, 1);
    expect(chipLabel(tester), 'completed');
    expect(find.byKey(const Key('complete-booking-button')), findsNothing);
    expect(find.text(StringConstants.bookingConfirmedToCompleted), findsOne);
    expect(reported?.id, 561);
    expect(reported?.status, BookingStatus.completed);
    expect(reported?.paidAmount, 2500);
    // Let the top snackbar run out.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a second complete is possible after the first returns', (
    WidgetTester tester,
  ) async {
    // The request used to wait on itself: the first never returned, and
    // every later tap for that booking was swallowed as "already running".
    final Future<BookingCompletionResponse> first = completeBooking(561);
    await tester.pump();
    expect((await first).success, isTrue);
    final Future<BookingCompletionResponse> second = completeBooking(561);
    await tester.pump();
    expect((await second).success, isTrue);
    expect(sent, 2);
  });

  testWidgets('list card: completes and leaves the Confirmed list', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(confirmed);
    final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<BookingBloc>.value(
            value: bloc,
            child: const BookingStatusPage(
              kind: BookingListKind.futsal,
              filter: BookingStatusFilter.confirmed,
            ),
          ),
        ),
      ),
    );
    bloc.add(
      const FetchFutsalBookingsEvent(
        filter: BookingStatusFilter.confirmed,
        force: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      bloc.state.futsalSlice(BookingStatusFilter.confirmed).bookings,
      hasLength(1),
    );

    await tester.tap(find.text('Complete'));
    // The server has it completed now, so the list's refetch drops it too.
    repository.listItems = const <BookingModel>[];
    await completeThroughSheet(tester);

    expect(sent, 1);
    expect(find.text(StringConstants.bookingConfirmedToCompleted), findsOne);
    expect(
      bloc.state.futsalSlice(BookingStatusFilter.confirmed).bookings,
      isEmpty,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}

final class _FakeRepository implements BookingRepository {
  _FakeRepository(this.booking) : listItems = <BookingModel>[booking];

  BookingModel booking;
  List<BookingModel> listItems;

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(
    int bookingId,
  ) async => right(booking);

  @override
  Future<Either<AppException, BookingReviewModel?>> getBookingReview(
    int bookingId,
  ) async => right(null);

  @override
  Future<Either<AppException, PaginatedBookings>> getFutsalBookings(
    BookingListQuery query,
  ) async => right(
    PaginatedBookings(
      items: listItems,
      currentPage: 1,
      lastPage: 1,
      perPage: query.perPage,
      total: listItems.length,
      hasMorePages: false,
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
