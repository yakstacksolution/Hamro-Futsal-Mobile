import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/app_theme_controller.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';

/// Reads its colour from `LightColor`, i.e. from the global brightness rather
/// than from `Theme.of(context)`. This is how the overwhelming majority of the
/// app is written, and it is exactly the shape that used to go stale on a theme
/// toggle: it registers no dependency on the `Theme` inherited widget, so
/// swapping [ThemeData] alone never causes it to rebuild.
class _GlobalColourWidget extends StatelessWidget {
  const _GlobalColourWidget();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: LightColor.background,
    child: const SizedBox(width: 10, height: 10),
  );
}

/// Reads through the inherited theme, so it was always updated correctly.
class _ThemeDependentWidget extends StatelessWidget {
  const _ThemeDependentWidget();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.appColors.background,
    child: const SizedBox(width: 10, height: 10),
  );
}

Color _colourOf(WidgetTester tester, Finder inside) {
  final ColoredBox box = tester.widget<ColoredBox>(
    find.descendant(of: inside, matching: find.byType(ColoredBox)),
  );
  return box.color;
}

void main() {
  // The controller is a singleton; leave it light for whatever runs next.
  tearDown(() => AppThemeController.instance.setDarkMode(false));

  Widget harness() => ValueListenableBuilder<ThemeMode>(
    valueListenable: AppThemeController.instance,
    builder: (BuildContext context, ThemeMode mode, _) => MaterialApp(
      theme: FutsalTheme.lightTheme,
      darkTheme: FutsalTheme.darkTheme,
      themeMode: mode,
      // A route boundary is what made this bug visible in the real app: the
      // Navigator does not rebuild its routes just because ThemeData changed.
      home: const Scaffold(
        body: Column(
          children: <Widget>[_GlobalColourWidget(), _ThemeDependentWidget()],
        ),
      ),
    ),
  );

  testWidgets(
    'toggling dark mode repaints widgets that read the global palette',
    (WidgetTester tester) async {
      AppThemeController.instance.setDarkMode(false);
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      final Finder global = find.byType(_GlobalColourWidget);
      final Finder themed = find.byType(_ThemeDependentWidget);

      expect(_colourOf(tester, global), AppThemeColors.light.background);
      expect(_colourOf(tester, themed), AppThemeColors.light.background);

      AppThemeController.instance.setDarkMode(true);
      await tester.pumpAndSettle();

      // The regression: this one used to keep the light background until restart.
      expect(
        _colourOf(tester, global),
        AppThemeColors.dark.background,
        reason: 'widget reading LightColor.* did not repaint after the toggle',
      );
      expect(_colourOf(tester, themed), AppThemeColors.dark.background);

      // And back again, so the fix is not one-directional.
      AppThemeController.instance.setDarkMode(false);
      await tester.pumpAndSettle();
      expect(_colourOf(tester, global), AppThemeColors.light.background);
      expect(_colourOf(tester, themed), AppThemeColors.light.background);
    },
  );

  testWidgets('toggling preserves State below the toggle point', (
    WidgetTester tester,
  ) async {
    AppThemeController.instance.setDarkMode(false);
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    final Element element = tester.element(find.byType(_GlobalColourWidget));
    AppThemeController.instance.setDarkMode(true);
    await tester.pumpAndSettle();

    // Same Element => nothing was unmounted, so scroll offsets, in-progress
    // forms and the navigation stack survive the toggle.
    expect(tester.element(find.byType(_GlobalColourWidget)), same(element));
  });
}
