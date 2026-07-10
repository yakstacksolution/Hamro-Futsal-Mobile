import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/transactions/domain/model/booking_transaction.dart';
import 'package:hamro_footsall/features/transactions/presentation/pages/transaction_history_page.dart';

void main() {
  testWidgets('player history loads personal booking payments', (
    WidgetTester tester,
  ) async {
    final _FakeBookingRepository repository = _FakeBookingRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionHistoryPage(
          perspective: TransactionPerspective.player,
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.myBookingsCalls, 1);
    expect(repository.futsalBookingsCalls, 0);
    expect(find.text(StringConstants.playerPayments), findsOneWidget);
    expect(find.text('Goal Arena'), findsOneWidget);
  });

  testWidgets('futsal history loads incoming customer payments', (
    WidgetTester tester,
  ) async {
    final _FakeBookingRepository repository = _FakeBookingRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionHistoryPage(
          perspective: TransactionPerspective.futsal,
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.myBookingsCalls, 0);
    expect(repository.futsalBookingsCalls, 1);
    expect(find.text(StringConstants.futsalEarnings), findsOneWidget);
    expect(find.text('Aarav Shrestha'), findsOneWidget);
  });
}

final class _FakeBookingRepository implements BookingRepository {
  int myBookingsCalls = 0;
  int futsalBookingsCalls = 0;

  final BookingModel booking = BookingModel(
    id: 12,
    bookingRef: 'BK-0012',
    courtName: 'Court A',
    futsalName: 'Goal Arena',
    date: DateTime(2026, 7, 4),
    startTime: '18:00',
    endTime: '19:00',
    status: BookingStatus.confirmed,
    amount: 1500,
    playerName: 'Aarav Shrestha',
    payments: const <BookingPaymentModel>[
      BookingPaymentModel(
        id: 50,
        amount: 1500,
        status: 'completed',
        method: 'eSewa',
      ),
    ],
  );

  @override
  Future<Either<AppException, List<BookingModel>>> getMyBookings() async {
    myBookingsCalls++;
    return right(<BookingModel>[booking]);
  }

  @override
  Future<Either<AppException, List<BookingModel>>> getFutsalBookings() async {
    futsalBookingsCalls++;
    return right(<BookingModel>[booking]);
  }

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(
    int bookingId,
  ) async {
    return right(booking);
  }

  @override
  Future<Either<AppException, BookingModel?>> cancelBooking(
    int bookingId,
  ) async => right(booking);

  @override
  Future<Either<AppException, bool>> getCancelBoundary(int bookingId) async =>
      right(true);

  @override
  Future<Either<AppException, BookingModel?>> verifyBookingPayment({
    required int bookingId,
    required int paymentId,
    required double actualAmount,
    String? note,
  }) async => right(booking);

  @override
  Future<Either<AppException, BookingModel?>> rejectBookingPayment({
    required int bookingId,
    required int paymentId,
    String? note,
  }) async => right(booking);

  @override
  Future<Either<AppException, BookingModel?>> acceptBooking({
    required int bookingId,
  }) async => right(booking);

  @override
  Future<Either<AppException, BookingModel?>> rejectBooking({
    required int bookingId,
    String? note,
  }) async => right(booking);
}
