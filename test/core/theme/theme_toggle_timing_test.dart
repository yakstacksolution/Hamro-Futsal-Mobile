import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/app_theme_controller.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';

/// Reads the global palette (the shape ~3700 call sites use).
class _GlobalColour extends StatelessWidget {
  const _GlobalColour();
  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: LightColor.background, child: const SizedBox.square(dimension: 4));
}

/// Reads the inherited theme (the shape ~84 call sites use).
class _ThemedColour extends StatelessWidget {
  const _ThemedColour();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.appColors.background,
    child: const SizedBox.square(dimension: 4),
  );
}

Color _colour(WidgetTester tester, Finder of) => tester
    .widget<ColoredBox>(find.descendant(of: of, matching: find.byType(ColoredBox)))
    .color;

void main() {
  tearDown(() => AppThemeController.instance.setDarkMode(false));

  Widget harness({int rows = 40}) => ValueListenableBuilder<ThemeMode>(
    valueListenable: AppThemeController.instance,
    builder: (_, ThemeMode mode, __) => MaterialApp(
      theme: FutsalTheme.lightTheme,
      darkTheme: FutsalTheme.darkTheme,
      themeMode: mode,
      themeAnimationDuration: Duration.zero,
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            for (int i = 0; i < rows; i++) ...<Widget>[
              const _GlobalColour(),
              const _ThemedColour(),
            ],
          ],
        ),
      ),
    ),
  );

  testWidgets('both halves of the app flip in the SAME frame', (
    WidgetTester tester,
  ) async {
    AppThemeController.instance.setDarkMode(false);
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    AppThemeController.instance.setDarkMode(true);
    // Exactly one frame — no pumpAndSettle, no second pump. If either half
    // needed an extra frame or a cross-fade, it would still be light here.
    await tester.pump();

    expect(
      _colour(tester, find.byType(_GlobalColour).first),
      AppThemeColors.dark.background,
      reason: 'LightColor half lagged by a frame',
    );
    expect(
      _colour(tester, find.byType(_ThemedColour).first),
      AppThemeColors.dark.background,
      reason: 'Theme.of half was still mid cross-fade',
    );
  });

  testWidgets('no further visual change after that one frame', (
    WidgetTester tester,
  ) async {
    AppThemeController.instance.setDarkMode(false);
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    AppThemeController.instance.setDarkMode(true);
    await tester.pump();
    final Color afterOneFrame = _colour(tester, find.byType(_GlobalColour).first);

    await tester.pump(const Duration(milliseconds: 400));
    final Color afterSettling = _colour(tester, find.byType(_GlobalColour).first);

    // A second step would show up as these two differing.
    expect(afterSettling, afterOneFrame);
  });
}
