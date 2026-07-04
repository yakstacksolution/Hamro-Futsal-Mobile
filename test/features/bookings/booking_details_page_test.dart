import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/presentation/pages/booking_details_page.dart';

void main() {
  testWidgets('renders booking and payment values from the API model', (
    WidgetTester tester,
  ) async {
    final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
      'id': 7,
      'booking_code': 'BK-9BSUCLB3',
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
    expect(find.text('6:00 PM – 7:00 PM'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Payment summary'),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Venue Hosted by'), findsOneWidget);
    expect(find.byKey(const Key('chat-venue-button')), findsOneWidget);
    expect(find.text('Discount (FIRSTBOOK)'), findsOneWidget);
    expect(find.text('NPR 1080'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);
    expect(find.text('Balance due later'), findsOneWidget);
    expect(find.text('Payment method: Cash'), findsOneWidget);

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
}

final class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository(this.booking);

  final BookingModel booking;
  int? requestedBookingId;

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(
    int bookingId,
  ) async {
    requestedBookingId = bookingId;
    return right(booking);
  }

  @override
  Future<Either<AppException, List<BookingModel>>> getMyBookings() async =>
      right(<BookingModel>[booking]);

  @override
  Future<Either<AppException, List<BookingModel>>> getFutsalBookings() async =>
      right(<BookingModel>[booking]);
}
