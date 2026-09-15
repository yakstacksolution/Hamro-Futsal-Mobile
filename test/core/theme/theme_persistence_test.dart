import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/theme/app_theme_controller.dart';

/// The app opened on System even though the reader had chosen Light.
///
/// The controller reads storage when it is first built, but it is a lazily
/// created singleton — the first `LightColor.*` read anywhere builds it — so
/// when that happened before storage was open it fell back to System and never
/// looked again, while the reader's choice sat in storage unread.
///
/// `AppThemeController.restore()` is what closes that: `main` calls it once,
/// straight after settings are initialised.
void main() {
  // Changing the mode marks the tree dirty through the scheduler.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemoryPreferences preferences;

  setUpAll(() async {
    preferences = _MemoryPreferences();
    await AppSettings().init(preferences);
  });

  setUp(() {
    preferences.values.clear();
    AppThemeController.instance.setThemeMode(ThemeMode.system);
  });

  group('a choice survives a restart', () {
    test('Light is restored as Light', () {
      AppThemeController.instance.setThemeMode(ThemeMode.light);
      expect(preferences.getString('settings_app_theme_mode'), 'light');

      // A fresh launch that built the controller before storage was open: it
      // is sitting on System with the choice still on disk.
      AppThemeController.instance.value = ThemeMode.system;
      AppThemeController.restore();

      expect(AppThemeController.instance.value, ThemeMode.light);
      expect(AppThemeController.restoredMode, ThemeMode.light);
    });

    test('Dark is restored as Dark', () {
      AppThemeController.instance.setThemeMode(ThemeMode.dark);
      AppThemeController.instance.value = ThemeMode.system;
      AppThemeController.restore();
      expect(AppThemeController.instance.value, ThemeMode.dark);
    });

    test('System stays System when that is what was chosen', () {
      AppThemeController.instance.setThemeMode(ThemeMode.light);
      AppThemeController.instance.setThemeMode(ThemeMode.system);
      expect(preferences.getString('settings_app_theme_mode'), 'system');

      AppThemeController.instance.value = ThemeMode.light;
      AppThemeController.restore();
      expect(AppThemeController.instance.value, ThemeMode.system);
    });

    test('restoring does not write anything back', () {
      AppThemeController.instance.setThemeMode(ThemeMode.dark);
      preferences.writes = 0;

      AppThemeController.restore();

      // Restoring is not a choice the reader made; recording it as one would
      // overwrite a legacy value with a guess.
      expect(preferences.writes, 0);
      expect(AppThemeController.instance.value, ThemeMode.dark);
    });
  });

  group('a device with nothing chosen yet', () {
    test('falls back to System on a fresh install', () {
      preferences.values.clear();
      AppThemeController.restore();
      expect(AppThemeController.instance.value, ThemeMode.system);
      expect(AppThemeController.storedMode, ThemeMode.system);
    });

    test('an older install that only saved the dark flag still restores', () {
      // Before the app stored a three-way mode it stored a dark on/off bool,
      // and nothing under the newer key.
      preferences.values.remove('settings_app_theme_mode');
      preferences.values['settings_dark_mode'] = true;
      AppThemeController.restore();
      expect(AppThemeController.instance.value, ThemeMode.dark);

      preferences.values['settings_dark_mode'] = false;
      AppThemeController.restore();
      expect(AppThemeController.instance.value, ThemeMode.light);
    });

    test('an unrecognised stored value falls back to System', () {
      preferences.values['settings_app_theme_mode'] = 'midnight';
      AppThemeController.restore();
      expect(AppThemeController.instance.value, ThemeMode.system);
    });
  });

  test('the theme only changes when the reader changes it', () {
    AppThemeController.instance.setThemeMode(ThemeMode.light);

    // Several restarts in a row, nothing else touching it.
    for (int i = 0; i < 3; i++) {
      AppThemeController.instance.value = ThemeMode.system;
      AppThemeController.restore();
      expect(AppThemeController.instance.value, ThemeMode.light);
    }

    AppThemeController.instance.setThemeMode(ThemeMode.dark);
    AppThemeController.instance.value = ThemeMode.system;
    AppThemeController.restore();
    expect(AppThemeController.instance.value, ThemeMode.dark);
  });
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
