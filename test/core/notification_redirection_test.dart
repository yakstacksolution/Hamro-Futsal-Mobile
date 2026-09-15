import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/routers/notification_redirection.dart';

void main() {
  const Map<String, dynamic> vendorBooking = <String, dynamic>{
    'booking_id': '424',
    'entity_type': 'App\\Models\\Booking',
    'court_id': '33',
    'action_type': 'vendor_booking',
    'booking_date': '2026-09-14',
    'notification_id': '2227',
    'entity_id': '424',
    'type': 'vendor_booking_created',
    'category': 'booking',
    'venue_id': '2',
    'action_target': '/bookings/424',
  };

  test('vendor booking push is routable', () {
    expect(isSupportedNotificationPayload(vendorBooking), isTrue);
    expect(isSupportedNotificationType('vendor_booking_created'), isTrue);
  });

  const Map<String, dynamic> playerBooking = <String, dynamic>{
    'booking_id': '425',
    'entity_type': 'App\\Models\\Booking',
    'court_id': '56',
    'action_type': 'booking',
    'booking_date': '2026-09-13',
    'notification_id': '2229',
    'entity_id': '425',
    'type': 'booking_created',
    'category': 'booking',
    'venue_id': '54',
    'action_target': '/bookings/425',
  };

  test('vendor booking opens booking 424 in the vendor layout', () {
    final target = resolveNotificationTarget(vendorBooking);
    expect(target.kind, 'booking');
    expect(target.bookingId, 424);
    expect(target.isFutsalView, isTrue);
  });

  test('player booking opens booking 425 in the player layout', () {
    expect(isSupportedNotificationPayload(playerBooking), isTrue);
    final target = resolveNotificationTarget(playerBooking);
    expect(target.kind, 'booking');
    expect(target.bookingId, 425);
    expect(target.isFutsalView, isFalse);
  });

  const Map<String, dynamic> paymentVerified = <String, dynamic>{
    'booking_id': '425',
    'amount': '1000',
    'entity_type': 'App\\Models\\Payment',
    'action_type': 'booking_payment',
    'payment_id': '463',
    'notification_id': '2231',
    'entity_id': '463',
    'type': 'payment_verified',
    'category': 'payment',
    'action_target': '/bookings/425',
  };

  test('a verified payment opens its booking in My Bookings', () {
    expect(isSupportedNotificationPayload(paymentVerified), isTrue);
    final target = resolveNotificationTarget(paymentVerified);
    expect(target.kind, 'payment');
    // `entity_id` here is the payment (463), not the booking.
    expect(target.bookingId, 425);
    expect(target.isFutsalView, isFalse);
  });

  test('a payment entity_id is never mistaken for the booking', () {
    final target = resolveNotificationTarget(<String, dynamic>{
      'entity_type': 'App\\Models\\Payment',
      'entity_id': '463',
      'type': 'payment_verified',
      'action_target': '/bookings/425',
    });
    expect(target.bookingId, 425);
  });

  const Map<String, dynamic> rewardEarned = <String, dynamic>{
    'entity_type': 'App\\Models\\RewardTransaction',
    'action_type': 'reward',
    'notification_id': '2233',
    'entity_id': '71',
    'type': 'reward_earned',
    'category': 'promotion',
    'action_target': '/rewards',
  };

  test('an earned reward opens the rewards page', () {
    expect(isSupportedNotificationPayload(rewardEarned), isTrue);
    expect(resolveNotificationTarget(rewardEarned).kind, 'reward');
    // Nothing booking-shaped in it: `entity_id` is a reward transaction.
    expect(resolveNotificationTarget(rewardEarned).bookingId, isNull);
  });

  test('a reward push routes on action_target alone', () {
    expect(
      resolveNotificationTarget(<String, dynamic>{
        'action_target': '/rewards',
      }).kind,
      'reward',
    );
  });

  test('a plain promotion is not treated as a reward', () {
    expect(
      isSupportedNotificationPayload(<String, dynamic>{
        'type': 'promo_banner',
        'category': 'promotion',
      }),
      isFalse,
    );
  });

  test('the id is recovered from action_target alone', () {
    final target = resolveNotificationTarget(<String, dynamic>{
      'action_target': '/bookings/425',
    });
    expect(target.kind, 'booking');
    expect(target.bookingId, 425);
  });

  test('category alone is enough when the type is unknown', () {
    expect(
      isSupportedNotificationPayload(<String, dynamic>{
        'type': 'something_new',
        'category': 'booking',
      }),
      isTrue,
    );
  });

  test('action_target alone is enough', () {
    expect(
      isSupportedNotificationPayload(<String, dynamic>{
        'action_target': '/bookings/424',
      }),
      isTrue,
    );
  });

  test('unrelated pushes stay unsupported', () {
    expect(
      isSupportedNotificationPayload(<String, dynamic>{
        'type': 'promo_banner',
        'category': 'marketing',
      }),
      isFalse,
    );
  });
}
