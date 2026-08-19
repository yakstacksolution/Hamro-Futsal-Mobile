import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

Widget _host({required Brightness brightness, required Widget child}) =>
    MaterialApp(
      theme: brightness == Brightness.dark
          ? FutsalTheme.darkTheme
          : FutsalTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );

Color? _labelColour(WidgetTester tester) =>
    tester.widget<Text>(find.text('Book now')).style?.color;

Color? _iconColour(WidgetTester tester) =>
    tester.widget<Icon>(find.byIcon(Icons.check)).color;

void main() {
  group('default (filled) CustomButton', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('paints its label white in $brightness', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            brightness: brightness,
            child: CustomButton(
              text: 'Book now',
              icon: Icons.check,
              onPressed: () {},
            ),
          ),
        );

        // Regression: the label used the raw nullable `foregroundColor`, so with
        // no override it inherited the text theme's primaryText — dark on the
        // green fill in light mode, near-white in dark. The default must be
        // white in both, because the fill is the same brand green in both.
        expect(_labelColour(tester), const Color(0xFFFFFFFF));
        expect(_iconColour(tester), const Color(0xFFFFFFFF));
      });
    }
  });

  testWidgets('an explicit foregroundColor still wins', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        brightness: Brightness.light,
        child: CustomButton(
          text: 'Book now',
          icon: Icons.check,
          foregroundColor: LightColor.redColor,
          onPressed: () {},
        ),
      ),
    );
    expect(_labelColour(tester), LightColor.redColor);
    expect(_iconColour(tester), LightColor.redColor);
  });

  testWidgets('an outlined button keeps the brand tone, not white', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        brightness: Brightness.light,
        child: CustomButton(
          text: 'Book now',
          isOutlined: true,
          onPressed: () {},
        ),
      ),
    );
    // White here would be invisible: an outlined button has no fill, so its
    // label sits directly on the page.
    expect(_labelColour(tester), isNot(const Color(0xFFFFFFFF)));
    expect(_labelColour(tester), LightColor.secondaryColor);
  });
}
