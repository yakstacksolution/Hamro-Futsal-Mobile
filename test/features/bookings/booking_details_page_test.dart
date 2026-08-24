import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/domain/model/paginated_bookings.dart';
import 'package:hamro_footsall/features/bookings/presentation/pages/booking_details_page.dart';

void main() {
  testWidgets('renders booking and payment values from the API model', (
    WidgetTester tester,
  ) async {
    final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
      'id': 7,
      'booking_code': 'BK-9BSUCLB3',
      'booking_type': 'online',
      'is_recurring': true,
      'recurrence_type': 'weekly',
      'recurrence_start_date': '2026-07-01',
      'recurrence_end_date': '2026-08-19',
      'booking_date': '2026-08-12',
      'start_time': '18:00:00',
      'end_time': '19:00:00',
      'subtotal': 1200,
      'discount_amount': 120,
      'payable_now': 600,
      'balance_due_later': 480,
      'total_amount': 1080,
      'payment_status': 'partial',
      'booking_status': 'pending',
      'venue': <String, dynamic>{'id': 1, 'name': 'Dhananjay sports'},
      'court': <String, dynamic>{'id': 6, 'name': 'Shidartha'},
      'coupon': <String, dynamic>{'id': 1, 'code': 'FIRSTBOOK'},
      'payment': <String, dynamic>{
        'id': 7,
        'payment_method': 'cash',
        'amount': 600,
        'verification_status': 'pending',
        'payment_proof_url': 'https://example.com/payment-proof.jpg',
        'has_payment_proof': true,
      },
    });

    final _FakeBookingRepository repository = _FakeBookingRepository(booking);
    bool cancelled = false;
    bool openedVenueChat = false;
    await tester.pumpWidget(
      MaterialApp(
        home: BookingDetailsPage(
          booking: booking,
          repository: repository,
          onCancelBooking: () => cancelled = true,
          onChatVenue: () => openedVenueChat = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedBookingId, 7);
    expect(find.byKey(const Key('cancel-booking-button')), findsOneWidget);
    expect(find.text('Dhananjay sports'), findsWidgets);
    expect(find.text('Shidartha'), findsWidgets);
    expect(find.text('Wed, 12 Aug 2026 · 6:00 PM – 7:00 PM'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Booked via'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Payment summary'),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Vendor'), findsOneWidget);
    expect(find.byKey(const Key('chat-venue-button')), findsOneWidget);
    expect(find.text('Discount (FIRSTBOOK)'), findsOneWidget);
    expect(find.text('NPR 1080'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);
    expect(find.text('Balance due later'), findsOneWidget);
    expect(find.text('Paid via Cash'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel-booking-button')));
    await tester.tap(find.byKey(const Key('chat-venue-button')));
    expect(cancelled, isTrue);
    expect(openedVenueChat, isTrue);

    await tester.scrollUntilVisible(
      find.text('Submitted payment screenshot'),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Submitted payment screenshot'), findsOneWidget);
    expect(find.text('View full screen'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('payment-proof-preview')));
    await tester.tap(find.byKey(const Key('payment-proof-preview')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Payment proof'), findsOneWidget);
  });

  testWidgets('shows accept and reject actions for a pending futsal booking', (
    WidgetTester tester,
  ) async {
    final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
      'id': 0,
      'booking_date': '2026-08-12',
      'start_time': '18:00:00',
      'end_time': '19:00:00',
      'booking_status': 'pending',
      'total_amount': 1080,
      'venue': <String, dynamic>{'id': 1, 'name': 'Dhananjay sports'},
      'court': <String, dynamic>{'id': 6, 'name': 'Shidartha'},
      // Payment already verified so the Accept action is enabled.
      'payment': <String, dynamic>{
        'id': 7,
        'payment_method': 'cash',
        'amount': 1080,
        'verification_status': 'verified',
        'has_payment_proof': true,
      },
    });
    bool accepted = false;
    bool rejected = false;
    bool openedChat = false;

    await tester.pumpWidget(
      MaterialApp(
        home: BookingDetailsPage(
          booking: booking,
          isFutsalView: true,
          repository: _FakeBookingRepository(booking),
          onAcceptBooking: () => accepted = true,
          onRejectBooking: () => rejected = true,
          onChatCustomer: () => openedChat = true,
        ),
      ),
    );

    expect(find.byKey(const Key('accept-booking-button')), findsOneWidget);
    expect(find.byKey(const Key('reject-booking-button')), findsOneWidget);
    expect(find.byKey(const Key('chat-customer-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('accept-booking-button')));
    await tester.tap(find.byKey(const Key('reject-booking-button')));
    await tester.tap(find.byKey(const Key('chat-customer-button')));

    expect(accepted, isTrue);
    expect(rejected, isTrue);
    expect(openedChat, isTrue);
  });

  testWidgets('verifying payment proof does not accept or refresh booking', (
    WidgetTester tester,
  ) async {
    final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
      'id': 5,
      'booking_date': '2026-08-12',
      'start_time': '18:00:00',
      'end_time': '19:00:00',
      'booking_status': 'pending',
      'total_amount': 1080,
      'venue': <String, dynamic>{'id': 1, 'name': 'Dhananjay sports'},
      'court': <String, dynamic>{'id': 6, 'name': 'Shidartha'},
      'payment': <String, dynamic>{
        'id': 13,
        'payment_method': 'cash',
        'amount': 1080,
        'verification_status': 'pending',
        'has_payment_proof': true,
      },
    });
    final _FakeBookingRepository repository = _FakeBookingRepository(booking);

    await tester.pumpWidget(
      MaterialApp(
        home: BookingDetailsPage(
          booking: booking,
          isFutsalView: true,
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.getBookingDetailsCalls, 1);

    await tester.scrollUntilVisible(
      find.byKey(const Key('proof-accept-button')),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.byKey(const Key('proof-accept-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('proof-accept-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('payment-proof-actual-amount-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('payment-proof-remarks-field')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('payment-proof-actual-amount-field')),
      '1050',
    );
    await tester.enterText(
      find.byKey(const Key('payment-proof-remarks-field')),
      'Verified with bank statement',
    );
    await tester.tap(
      find.byKey(const Key('confirm-payment-proof-accept-button')),
    );
    await tester.pumpAndSettle();

    expect(repository.verifyPaymentCalls, 1);
    expect(repository.verifiedActualAmount, 1050);
    expect(repository.verifiedNote, 'Verified with bank statement');
    expect(repository.acceptBookingCalls, 0);
    expect(repository.getBookingDetailsCalls, 1);
  });

  testWidgets('rejecting payment proof asks for a reason', (
    WidgetTester tester,
  ) async {
    final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
      'id': 5,
      'booking_date': '2026-08-12',
      'start_time': '18:00:00',
      'end_time': '19:00:00',
      'booking_status': 'pending',
      'total_amount': 1080,
      'venue': <String, dynamic>{'id': 1, 'name': 'Dhananjay sports'},
      'court': <String, dynamic>{'id': 6, 'name': 'Shidartha'},
      'payment': <String, dynamic>{
        'id': 13,
        'payment_method': 'cash',
        'amount': 1080,
        'verification_status': 'pending',
        'has_payment_proof': true,
      },
    });
    final _FakeBookingRepository repository = _FakeBookingRepository(booking);

    await tester.pumpWidget(
      MaterialApp(
        home: BookingDetailsPage(
          booking: booking,
          isFutsalView: true,
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('proof-reject-button')),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.byKey(const Key('proof-reject-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('proof-reject-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('payment-proof-reject-reason-field')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('payment-proof-reject-reason-field')),
      'Wrong amount',
    );
    await tester.tap(
      find.byKey(const Key('confirm-payment-proof-reject-button')),
    );
    await tester.pumpAndSettle();

    expect(repository.rejectPaymentCalls, 1);
    expect(repository.rejectedNote, 'Wrong amount');
    expect(repository.acceptBookingCalls, 0);
  });
}

final class _FakeBookingRepository implements BookingRepository {
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

  _FakeBookingRepository(this.booking);

  final BookingModel booking;
  int? requestedBookingId;
  int getBookingDetailsCalls = 0;
  int verifyPaymentCalls = 0;
  int rejectPaymentCalls = 0;
  int acceptBookingCalls = 0;
  double? verifiedActualAmount;
  String? verifiedNote;
  String? rejectedNote;

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(
    int bookingId,
  ) async {
    getBookingDetailsCalls++;
    requestedBookingId = bookingId;
    return right(booking);
  }

  @override
  Future<Either<AppException, PaginatedBookings>> getMyBookings({
    required int page,
    required int perPage,
    String? status,
  }) async => right(
    PaginatedBookings(
      items: <BookingModel>[booking],
      currentPage: page,
      lastPage: page,
      perPage: perPage,
      total: 1,
      hasMorePages: false,
    ),
  );

  @override
  Future<Either<AppException, PaginatedBookings>> getFutsalBookings({
    required int page,
    required int perPage,
    String? status,
  }) async => right(
    PaginatedBookings(
      items: <BookingModel>[booking],
      currentPage: page,
      lastPage: page,
      perPage: perPage,
      total: 1,
      hasMorePages: false,
    ),
  );

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
  }) async {
    verifyPaymentCalls++;
    verifiedActualAmount = actualAmount;
    verifiedNote = note;
    return right(booking);
  }

  @override
  Future<Either<AppException, BookingModel?>> rejectBookingPayment({
    required int bookingId,
    required int paymentId,
    String? note,
  }) async {
    rejectPaymentCalls++;
    rejectedNote = note;
    return right(booking);
  }

  @override
  Future<Either<AppException, BookingModel?>> acceptBooking({
    required int bookingId,
  }) async {
    acceptBookingCalls++;
    return right(booking);
  }

  @override
  Future<Either<AppException, BookingModel?>> rejectBooking({
    required int bookingId,
    String? note,
  }) async => right(booking);
}
