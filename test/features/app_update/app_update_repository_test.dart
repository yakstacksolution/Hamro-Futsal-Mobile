import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/features/app_update/data/data_source/app_update_remote_data_source.dart';
import 'package:hamro_footsall/features/app_update/data/repositories/app_update_repository_impl.dart';
import 'package:hamro_footsall/features/app_update/data/service/in_app_update_service.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/app_update_check.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/install_progress.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Serves a canned manifest payload (or a transport error) in place of the
/// `/app-version` endpoint.
final class _FakeRemoteDataSource extends AppUpdateRemoteDataSource {
  Map<String, dynamic>? payload;
  bool fail = false;

  @override
  Future<Result> getAppVersion({required Map<String, dynamic> query}) async {
    if (fail) return Result.error(DataError('offline', 0, null));
    return Result.success(payload ?? <String, dynamic>{});
  }

  @override
  Future<Result> lookupAppStore({
    required String bundleId,
    String? country,
  }) async => Result.error(DataError('not used', 0, null));
}

/// Stands in for Google Play: the tests run on the host, where the real plugin
/// is unavailable.
final class _FakePlatform implements AppUpdatePlatform {
  PlayUpdateAvailability availability = PlayUpdateAvailability.none;

  @override
  bool get isPlaySupported => true;

  @override
  Future<PlayUpdateAvailability> checkPlayAvailability() async => availability;

  @override
  Future<PlayFlowOutcome> startFlexibleUpdate() async =>
      PlayFlowOutcome.started;

  @override
  Future<PlayFlowOutcome> performImmediateUpdate() async =>
      PlayFlowOutcome.started;

  @override
  Future<bool> completeFlexibleUpdate() async => true;

  @override
  Stream<InstallProgress> get installProgressStream =>
      const Stream<InstallProgress>.empty();

  @override
  Future<bool> openStore({
    String? storeUrl,
    String? packageName,
    String? appStoreId,
  }) async => true;
}

final class _MemoryPreferences implements Preferences {
  final Map<String, Object> _values = <String, Object>{};

  @override
  String? getString(String key) => _values[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _values[key] as int?;
  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  List<String> getStringList(String key) =>
      (_values[key] as List<String>?) ?? <String>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late _FakeRemoteDataSource remote;
  late _FakePlatform platform;

  setUpAll(() async {
    await AppSettings().init(_MemoryPreferences());
  });

  setUp(() {
    // Installed build under test: 1.2.0 (build 12).
    PackageInfo.setMockInitialValues(
      appName: 'Hamro Futsal',
      packageName: 'com.np.hamrofutsal',
      version: '1.2.0',
      buildNumber: '12',
      buildSignature: '',
    );
    AppSettings().clearUpdateSnooze();
    remote = _FakeRemoteDataSource();
    platform = _FakePlatform();
  });

  AppUpdateRepositoryImpl buildRepository() => AppUpdateRepositoryImpl(
    remoteDataSource: remote,
    updateService: platform,
  );

  Future<AppUpdateCheck> check() async {
    final result = await buildRepository().checkForUpdate();
    return result.getOrElse(
      () => throw StateError('expected a successful check'),
    );
  }

  group('requirement from the backend manifest', () {
    test('a newer version is an optional update', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{'latest_version': '1.3.0'},
      };

      final AppUpdateCheck result = await check();

      expect(result.requirement, UpdateRequirement.optional);
      expect(result.latestVersionLabel, '1.3.0');
    });

    test('the same version is not an update', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{'latest_version': '1.2.0'},
      };

      expect((await check()).requirement, UpdateRequirement.none);
    });

    test('an older published version is not an update', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{'latest_version': '1.1.9'},
      };

      expect((await check()).requirement, UpdateRequirement.none);
    });

    test('a higher build under the same version is an update', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{'latest_version': '1.2.0', 'build': 15},
      };

      expect((await check()).requirement, UpdateRequirement.optional);
    });

    test('force_update makes the available update mandatory', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{
          'latest_version': '1.3.0',
          'force_update': true,
        },
      };

      expect((await check()).requirement, UpdateRequirement.forced);
    });

    test('a version below min_supported_version is forced', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{
          'latest_version': '2.0.0',
          'min_supported_version': '1.5.0',
        },
      };

      expect((await check()).requirement, UpdateRequirement.forced);
    });

    test('a version at the minimum is not forced', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{
          'latest_version': '1.3.0',
          'min_supported_version': '1.2.0',
        },
      };

      expect((await check()).requirement, UpdateRequirement.optional);
    });

    test('update_available:false suppresses the prompt', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{
          'latest_version': '1.3.0',
          'update_available': false,
        },
      };

      expect((await check()).requirement, UpdateRequirement.none);
    });

    test('platform-specific keys override the shared ones', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{
          'latest_version': '1.2.0',
          // Tests run on the host, which the manifest parser treats as Android.
          'android': <String, dynamic>{'latest_version': '1.9.0'},
          'ios': <String, dynamic>{'latest_version': '1.2.0'},
        },
      };

      final AppUpdateCheck result = await check();
      expect(result.latestVersionLabel, '1.9.0');
      expect(result.requirement, UpdateRequirement.optional);
    });

    test('release notes are split into bullets', () async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{
          'latest_version': '1.3.0',
          'changelog': '• Faster booking\n- Fixed crash on payment',
        },
      };

      expect((await check()).releaseNotes, <String>[
        'Faster booking',
        'Fixed crash on payment',
      ]);
    });
  });

  group('fallback when the backend is unreachable', () {
    test('a Play-reported update is optional by default', () async {
      remote.fail = true;
      platform.availability = const PlayUpdateAvailability(
        updateAvailable: true,
        immediateAllowed: true,
        flexibleAllowed: true,
        availableVersionCode: 15,
        priority: 3,
      );

      final AppUpdateCheck result = await check();
      expect(result.requirement, UpdateRequirement.optional);
      expect(result.canUsePlayFlow, isTrue);
    });

    test('Play priority 5 escalates to a mandatory update', () async {
      remote.fail = true;
      platform.availability = const PlayUpdateAvailability(
        updateAvailable: true,
        immediateAllowed: true,
        flexibleAllowed: false,
        priority: 5,
      );

      expect((await check()).requirement, UpdateRequirement.forced);
    });

    test('no source at all reports no update and flags unreachable', () async {
      remote.fail = true;

      final AppUpdateCheck result = await check();
      expect(result.requirement, UpdateRequirement.none);
      expect(result.sourceReachable, isFalse);
    });

    test('an answered but unparsable manifest still counts as reachable', () async {
      remote.payload = <String, dynamic>{'data': <String, dynamic>{}};

      final AppUpdateCheck result = await check();
      expect(result.requirement, UpdateRequirement.none);
      expect(result.sourceReachable, isTrue);
    });
  });

  group('snoozing', () {
    Future<AppUpdateCheck> optionalUpdate() async {
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{'latest_version': '1.3.0', 'build': 20},
      };
      return check();
    }

    test('prompts before any snooze', () async {
      final AppUpdateRepositoryImpl repository = buildRepository();
      final AppUpdateCheck result = await optionalUpdate();

      expect(repository.shouldPrompt(result), isTrue);
    });

    test('stops prompting inside the snooze window', () async {
      final AppUpdateRepositoryImpl repository = buildRepository();
      final AppUpdateCheck result = await optionalUpdate();

      await repository.snooze(result);

      expect(repository.shouldPrompt(result), isFalse);
    });

    test('prompts again once the window has passed', () async {
      final AppUpdateRepositoryImpl repository = buildRepository();
      final AppUpdateCheck result = await optionalUpdate();

      await repository.snooze(result, duration: Duration.zero);

      expect(repository.shouldPrompt(result), isTrue);
    });

    test('a newer release is not covered by an earlier snooze', () async {
      final AppUpdateRepositoryImpl repository = buildRepository();
      await repository.snooze(await optionalUpdate());

      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{'latest_version': '1.4.0', 'build': 21},
      };
      final AppUpdateCheck newer = await check();

      expect(repository.shouldPrompt(newer), isTrue);
    });

    test('a mandatory update always prompts, snooze or not', () async {
      final AppUpdateRepositoryImpl repository = buildRepository();
      remote.payload = <String, dynamic>{
        'data': <String, dynamic>{
          'latest_version': '1.3.0',
          'force_update': true,
        },
      };
      final AppUpdateCheck forced = await check();

      await repository.snooze(forced);

      expect(repository.shouldPrompt(forced), isTrue);
    });
  });
}
