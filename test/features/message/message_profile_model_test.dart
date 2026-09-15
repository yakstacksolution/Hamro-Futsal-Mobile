import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/message_profile_model.dart';

void main() {
  group('MessageProfileModel.fromJson', () {
    // The shape `GET /message-profile/{id}` actually returns.
    test('reads the live payload, image object and all', () {
      final MessageProfileModel
      profile = MessageProfileModel.fromJson(<String, dynamic>{
        'id': 19,
        'name': 'Rosnnnnn',
        'image': <String, dynamic>{
          'id': 393,
          'name': 'camera_1786343181608970',
          'url':
              'https://hamrofutsal.com//storage/users/19/library/393/camera.jpg',
        },
        'address': 'Bbb',
        'email': 'test01@gmail.com',
      });

      expect(profile.id, 19);
      expect(profile.name, 'Rosnnnnn');
      expect(profile.address, 'Bbb');
      expect(profile.email, 'test01@gmail.com');
      // Absent from this response — null, so the UI shows "Not provided"
      // rather than a blank row.
      expect(profile.gender, isNull);
      expect(profile.genderLabel, isNull);
      expect(
        profile.imageUrl,
        'https://hamrofutsal.com/storage/users/19/library/393/camera.jpg',
      );
    });

    test('labels gender once the endpoint carries it', () {
      expect(
        MessageProfileModel.fromJson(<String, dynamic>{
          'name': 'A',
          'gender': 'male',
        }).genderLabel,
        'Male',
      );
      expect(
        MessageProfileModel.fromJson(<String, dynamic>{
          'name': 'A',
          'gender': 'prefer_not_to_say',
        }).genderLabel,
        'Prefer Not To Say',
      );
    });

    test('leaves every absent or blank field null', () {
      final MessageProfileModel empty = MessageProfileModel.fromJson(
        <String, dynamic>{
          'name': '  ',
          'address': null,
          'image': <String, dynamic>{'url': ''},
        },
      );

      expect(empty.id, isNull);
      expect(empty.name, isNull);
      expect(empty.address, isNull);
      expect(empty.email, isNull);
      expect(empty.gender, isNull);
      expect(empty.imageUrl, isNull);
    });

    test('falls back to alternative keys and survives a missing id', () {
      final MessageProfileModel profile =
          MessageProfileModel.fromJson(<String, dynamic>{
            'full_name': 'Bina',
            'location': 'Lalitpur',
            'email_address': 'bina@example.com',
            'avatar': 'https://hamrofutsal.com//storage/a.png',
          });

      expect(profile.id, isNull);
      expect(profile.name, 'Bina');
      expect(profile.address, 'Lalitpur');
      expect(profile.email, 'bina@example.com');
      expect(profile.imageUrl, 'https://hamrofutsal.com/storage/a.png');
    });
  });
}
