import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/profile/data/model/profile_model.dart';

/// The `/api/auth/me` body, as staging serves it.
const Map<String, dynamic> _response = <String, dynamic>{
  'status': 'success',
  'message': 'Profile fetched successfully.',
  'data': <String, dynamic>{
    'id': 3,
    'full_name': 'Roshan',
    'email': 'hamrofutsal1@gmail.com',
    'phone': null,
    'latitude': null,
    'longitude': null,
    'role': 'vendor',
    'email_verified_at': '2026-09-21T15:58:32.000000Z',
    'requires_vendor_onboarding': false,
    'is_vendor_requested': false,
    'vendor_onboarding_completed_at': null,
    'date_of_birth': null,
    'address': null,
    'gender': null,
    'enable_push_notification': true,
    'enable_booking_alert': true,
    'enable_opponent_request': true,
    'enable_promotional_emails': true,
    'is_test_user': false,
    'notification_settings': null,
    'vendor_onboarding_data': null,
    'designation': null,
    'profile_photo': null,
    'wishlists': <dynamic>[],
    'created_at': '2026-09-21 21:43:15',
    'updated_at': '2026-09-21 21:43:32',
  },
};

void main() {
  test('reads every field the auth/me body carries', () {
    final ProfileModel profile = ProfileModel.fromJson(_response);
    final UserData user = profile.data;

    expect(profile.status, 'success');
    expect(user.id, 3);
    expect(user.fullName, 'Roshan');
    expect(user.email, 'hamrofutsal1@gmail.com');
    expect(user.role, 'vendor');
    expect(user.emailVerifiedAt, isNotNull);
    expect(user.requiresVendorOnboarding, isFalse);
    expect(user.isVendorRequested, isFalse);
    expect(user.isTestUser, isFalse);
    expect(user.notificationSettings, isNull);
    expect(user.wishlistVenueIds, isEmpty);
    expect(user.createdAt, DateTime.parse('2026-09-21 21:43:15'));
    expect(user.updatedAt, DateTime.parse('2026-09-21 21:43:32'));

    final prefs = user.notificationPreferences;
    expect(prefs.pushNotification, isTrue);
    expect(prefs.bookingAlert, isTrue);
    expect(prefs.opponentRequest, isTrue);
    expect(prefs.promotionalEmails, isTrue);
  });

  test('a test account is flagged, whatever the serializer sends', () {
    for (final Object flag in <Object>[true, 1, '1', 'true']) {
      final UserData user = UserData.fromJson(<String, dynamic>{
        'id': 3,
        'role': 'vendor',
        'is_test_user': flag,
      });
      expect(user.isTestUser, isTrue, reason: 'is_test_user: $flag');
    }
  });

  test('notification_settings is kept as sent', () {
    final UserData user = UserData.fromJson(<String, dynamic>{
      'id': 3,
      'notification_settings': <String, dynamic>{'chat': false},
    });

    expect(user.notificationSettings, <String, dynamic>{'chat': false});
    expect(user.toJson()['notification_settings'], <String, dynamic>{
      'chat': false,
    });
  });
}
