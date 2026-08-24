import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/app_theme_controller.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';

void main() {
  late _MemoryPreferences preferences;

  setUpAll(() async {
    preferences = _MemoryPreferences();
    await AppSettings().init(preferences);
  });

  tearDown(() {
    AppThemeController.instance.setDarkMode(false);
  });

  test('theme controller persists and publishes light/dark changes', () {
    final AppThemeController controller = AppThemeController.instance;

    controller.setDarkMode(true);
    expect(controller.value, ThemeMode.dark);
    expect(preferences.getBool('settings_dark_mode'), isTrue);
    expect(LightColor.background, const Color(0xFF000000));
    expect(LightColor.cardColor, const Color(0xFF101311));
    expect(LightColor.primaryTextColor, const Color(0xFFF5F7F5));

    controller.setDarkMode(false);
    expect(controller.value, ThemeMode.light);
    expect(preferences.getBool('settings_dark_mode'), isFalse);
  });

  testWidgets('MaterialApp switches to the OLED theme immediately', (
    WidgetTester tester,
  ) async {
    final AppThemeController controller = AppThemeController.instance;
    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: controller,
        builder: (_, ThemeMode mode, __) => MaterialApp(
          theme: FutsalTheme.lightTheme,
          darkTheme: FutsalTheme.darkTheme,
          themeMode: mode,
          home: Builder(
            builder: (BuildContext context) => ColoredBox(
              key: const Key('themed-surface'),
              color: context.appColors.background,
            ),
          ),
        ),
      ),
    );

    controller.setDarkMode(true);
    await tester.pumpAndSettle();

    final ColoredBox surface = tester.widget(
      find.byKey(const Key('themed-surface')),
    );
    expect(surface.color, const Color(0xFF000000));
  });
}

final class _MemoryPreferences implements Preferences {
  final Map<String, Object> _values = <String, Object>{};

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  double? getDouble(String key) => _values[key] as double?;

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  List<String> getStringList(String key) =>
      (_values[key] as List<String>?) ?? <String>[];

  @override
  Future<bool> remove(String key) async => _values.remove(key) != null;

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> permissions) async {
    _values[key] = List<String>.of(permissions);
    return true;
  }
}
