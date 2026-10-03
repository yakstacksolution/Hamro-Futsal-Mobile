import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/fcm_helper.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';

/// Without Firebase (Windows and Linux never initialise it) the helper must
/// stay inert. It used to read `FirebaseMessaging.instance` while being built,
/// which threw inside every login handler that syncs the token.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => AppSettings().init(_MemoryPreferences()));

  test(
    'without Firebase, building and using the helper never throws',
    () async {
      expect(FcmHelper.isPushSupported, isFalse);
      expect(FcmHelper.new, returnsNormally);
      await expectLater(FcmHelper().init(), completes);
      await expectLater(FcmHelper().syncTokenAfterLogin(), completes);
    },
  );
}

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
