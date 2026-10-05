import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/date_time/app_calendar.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/features/profile/data/model/profile_model.dart';
import 'package:hamro_futsal/features/profile/domain/repository/profile_repository.dart';
import 'package:hamro_futsal/features/profile/domain/usecase/profile_usecase.dart';
import 'package:hamro_futsal/features/profile/presentation/profile_bloc/profile_bloc.dart';

/// `use_nepali_calendar` on the user profile picks the app's calendar:
/// Nepali (BS) when true, English (AD, the default) when false.
void main() {
  late _MemoryPreferences preferences;

  setUpAll(() async {
    preferences = _MemoryPreferences();
    await AppSettings().init(preferences);
  });

  tearDown(() => AppCalendarController.instance.setCalendar(AppCalendar.ad));

  Map<String, dynamic> userJson([Object? useNepali = _absent]) =>
      <String, dynamic>{
        'id': 1,
        'full_name': 'Player One',
        'email': 'player@example.com',
        'role': 'candidate',
        if (!identical(useNepali, _absent)) 'use_nepali_calendar': useNepali,
      };

  group('UserData', () {
    test('reads use_nepali_calendar in the forms APIs send it', () {
      expect(UserData.fromJson(userJson(true)).useNepaliCalendar, isTrue);
      expect(UserData.fromJson(userJson(1)).useNepaliCalendar, isTrue);
      expect(UserData.fromJson(userJson('1')).useNepaliCalendar, isTrue);
      expect(UserData.fromJson(userJson(false)).useNepaliCalendar, isFalse);
      expect(UserData.fromJson(userJson(0)).useNepaliCalendar, isFalse);
    });

    test('is null when the server does not send it', () {
      final UserData user = UserData.fromJson(userJson());
      expect(user.useNepaliCalendar, isNull);
      expect(user.toJson().containsKey('use_nepali_calendar'), isFalse);
    });

    test('round-trips through toJson and survives a merge without it', () {
      final UserData nepali = UserData.fromJson(userJson(true));
      expect(nepali.toJson()['use_nepali_calendar'], isTrue);
      final UserData merged = nepali.mergeWith(UserData.fromJson(userJson()));
      expect(merged.useNepaliCalendar, isTrue);
    });
  });

  test('parses the /auth/me response', () {
    final ProfileModel profile = ProfileModel.fromJson(_authMeResponse);
    final UserData user = profile.data;

    expect(profile.status, 'success');
    expect(user.id, 4);
    expect(user.fullName, 'Dilli Bhandari');
    expect(user.role, 'vendor');
    expect(user.phone, '9800000000');
    expect(user.dateOfBirth, DateTime(1998, 5, 28));
    expect(user.gender, 'male');
    expect(user.address, 'Kathmandu Nepal');
    expect(user.useNepaliCalendar, isTrue);
    expect(user.isTestUser, isFalse);
    expect(user.isVendorRequested, isFalse);
    expect(user.requiresVendorOnboarding, isFalse);
    // `created_at` arrives as "2026-05-27 09:09:06", without the T.
    expect(user.createdAt, DateTime(2026, 5, 27, 9, 9, 6));
    expect(user.updatedAt, DateTime(2026, 10, 3, 21, 51, 50));
    expect(user.futsalId, 57);
    expect(user.futsalSlug, 'test-futsal-3');
    expect(user.isVendorOnboardingCompleted, isFalse);
    expect(user.profilePhoto?.id, 519);
    expect(
      user.profilePhoto?.remoteUrl,
      endsWith('camera_1789479440399887.jpg'),
    );
    expect(user.wishlistVenueIds, <int>[63]);
    expect(user.notificationPreferences.pushNotification, isTrue);
    expect(user.notificationPreferences.promotionalEmails, isTrue);
    expect(user.notificationSettings?['categories'], hasLength(7));
  });

  group('local storage', () {
    test('saves use_nepali_calendar on the device as a bool', () {
      AppCalendarController.instance.setCalendar(AppCalendar.bs);
      expect(preferences.getBool('use_nepali_calendar'), isTrue);
      expect(AppSettings().useNepaliCalendar, isTrue);

      AppCalendarController.instance.setCalendar(AppCalendar.ad);
      expect(preferences.getBool('use_nepali_calendar'), isFalse);
    });

    test('is read back at start-up', () {
      preferences.setBool('use_nepali_calendar', true);
      AppCalendarController.restore();
      expect(AppCalendarController.instance.calendar, AppCalendar.bs);
    });

    test('logout clears it and returns to English', () {
      AppCalendarController.instance.setCalendar(AppCalendar.bs);
      AppSettings().logout();
      expect(preferences.containsKey('use_nepali_calendar'), isFalse);
      expect(AppCalendarController.instance.calendar, AppCalendar.ad);
    });
  });

  group('ProfileBloc', () {
    test('a profile with use_nepali_calendar switches the app to BS', () async {
      final ProfileBloc bloc = ProfileBloc(
        ProfileUseCase(_FakeRepository(fetched: userJson(true))),
      );
      addTearDown(bloc.close);

      bloc.add(const FetchProfileEvent());
      await bloc.stream.firstWhere(
        (ProfileState s) => s.status == ProfileStatus.success,
      );

      expect(AppCalendarController.instance.calendar, AppCalendar.bs);
    });

    test(
      'a profile without the key leaves the current calendar alone',
      () async {
        AppCalendarController.instance.setCalendar(AppCalendar.bs);
        final ProfileBloc bloc = ProfileBloc(
          ProfileUseCase(_FakeRepository(fetched: userJson())),
        );
        addTearDown(bloc.close);

        bloc.add(const FetchProfileEvent());
        await bloc.stream.firstWhere(
          (ProfileState s) => s.status == ProfileStatus.success,
        );

        expect(AppCalendarController.instance.calendar, AppCalendar.bs);
      },
    );

    test(
      'saving sends use_nepali_calendar and applies the saved value',
      () async {
        final _FakeRepository repository = _FakeRepository(
          fetched: userJson(false),
          updated: userJson(true),
        );
        final ProfileBloc bloc = ProfileBloc(ProfileUseCase(repository));
        addTearDown(bloc.close);

        bloc.add(const FetchProfileEvent());
        await bloc.stream.firstWhere(
          (ProfileState s) => s.status == ProfileStatus.success,
        );
        expect(AppCalendarController.instance.calendar, AppCalendar.ad);

        bloc.add(
          const UpdateProfileEvent(
            fullName: 'Player One',
            useNepaliCalendar: true,
          ),
        );
        await bloc.stream.firstWhere(
          (ProfileState s) => s.status == ProfileStatus.updateSuccess,
        );

        expect(repository.lastUpdate?['use_nepali_calendar'], isTrue);
        expect(AppCalendarController.instance.calendar, AppCalendar.bs);
      },
    );

    test(
      'an update that does not set it leaves it out of the request',
      () async {
        final _FakeRepository repository = _FakeRepository(fetched: userJson());
        final ProfileBloc bloc = ProfileBloc(ProfileUseCase(repository));
        addTearDown(bloc.close);

        bloc.add(const UpdateProfileEvent(fullName: 'Player One'));
        await bloc.stream.firstWhere(
          (ProfileState s) => s.status == ProfileStatus.updateSuccess,
        );
        expect(
          repository.lastUpdate?.containsKey('use_nepali_calendar'),
          isFalse,
        );
      },
    );
  });
}

const Object _absent = Object();

class _FakeRepository implements ProfileRepository {
  _FakeRepository({required this.fetched, Map<String, dynamic>? updated})
    : updated = updated ?? fetched;

  final Map<String, dynamic> fetched;
  final Map<String, dynamic> updated;
  Map<String, dynamic>? lastUpdate;

  ProfileModel _model(Map<String, dynamic> user) => ProfileModel(
    status: 'success',
    message: '',
    data: UserData.fromJson(user),
  );

  @override
  Future<Either<AppException, ProfileModel>> getProfile() async =>
      right(_model(fetched));

  @override
  Future<Either<AppException, ProfileModel>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    lastUpdate = data;
    return right(_model(updated));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// `/api/auth/me` as the staging server sends it (contact details replaced).
final Map<String, dynamic> _authMeResponse = <String, dynamic>{
  'status': 'success',
  'message': 'Profile fetched successfully.',
  'data': <String, dynamic>{
    'id': 4,
    'full_name': 'Dilli Bhandari',
    'email': 'user@example.com',
    'phone': '9800000000',
    'latitude': null,
    'longitude': null,
    'role': 'vendor',
    'email_verified_at': '2026-09-02T09:53:33.000000Z',
    'requires_vendor_onboarding': false,
    'is_vendor_requested': false,
    'vendor_onboarding_completed_at': null,
    'date_of_birth': '1998-05-28',
    'address': 'Kathmandu Nepal',
    'gender': 'male',
    'enable_push_notification': true,
    'enable_booking_alert': true,
    'enable_opponent_request': true,
    'enable_promotional_emails': true,
    'is_test_user': false,
    'use_nepali_calendar': true,
    'notification_settings': <String, dynamic>{
      'push_enabled': true,
      'in_app_enabled': true,
      'channels': <Map<String, dynamic>>[
        <String, dynamic>{
          'key': 'push',
          'label': 'Push notifications',
          'enabled': true,
        },
        <String, dynamic>{
          'key': 'in_app',
          'label': 'In-app notifications',
          'enabled': true,
        },
      ],
      'categories': <Map<String, dynamic>>[
        for (final String key in <String>[
          'booking',
          'chat',
          'payment',
          'match',
          'opponent',
          'promotion',
          'system',
        ])
          <String, dynamic>{'key': key, 'label': key, 'enabled': true},
      ],
    },
    'vendor_onboarding_data': <String, dynamic>{
      'id': 57,
      'name': 'Test futsal',
      'slug': 'test-futsal-3',
      'main_step': 0,
      'sub_step': 0,
      'onboarding_completed': false,
    },
    'designation': null,
    'profile_photo': <String, dynamic>{
      'id': 519,
      'name': 'camera_1789479440399887',
      'full_url':
          'https://staging.hamrofutsal.com//storage/users/4/library/519/camera_1789479440399887.jpg',
      'status': 'active',
    },
    'wishlists': <int>[63],
    'created_at': '2026-05-27 09:09:06',
    'updated_at': '2026-10-03 21:51:50',
  },
};

final class _MemoryPreferences implements Preferences {
  final Map<String, Object> values = <String, Object>{};
  int writes = 0;

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  double? getDouble(String key) => values[key] as double?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  List<String> getStringList(String key) =>
      (values[key] as List<String>?) ?? <String>[];

  @override
  Future<bool> remove(String key) async {
    writes++;
    return values.remove(key) != null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> permissions) async {
    writes++;
    values[key] = List<String>.from(permissions);
    return true;
  }
}
