import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/text_scaling.dart';

void main() {
  group('AppTextScaling.deviceFactorFor', () {
    test('leaves the design width untouched', () {
      expect(AppTextScaling.deviceFactorFor(375), 1);
    });

    test('shrinks type on a small phone, down to the floor', () {
      expect(AppTextScaling.deviceFactorFor(360), closeTo(0.96, 0.001));
      expect(AppTextScaling.deviceFactorFor(320), closeTo(0.853, 0.001));
      // Below the floor the factor stops falling.
      expect(AppTextScaling.deviceFactorFor(240), AppTextScaling.minFactor);
    });

    test('grows type on a large phone, up to the ceiling', () {
      expect(AppTextScaling.deviceFactorFor(414), closeTo(1.104, 0.001));
      expect(AppTextScaling.deviceFactorFor(430), AppTextScaling.maxFactor);
      // A tablet is not scaled past a large phone: the breakpoints give it
      // room, type growing with every pixel of width would not.
      expect(AppTextScaling.deviceFactorFor(834), AppTextScaling.maxFactor);
    });

    test('survives a degenerate size', () {
      expect(AppTextScaling.deviceFactorFor(0), 1);
      expect(AppTextScaling.deviceFactorFor(double.infinity), 1);
    });
  });

  group('AppTextScaling', () {
    testWidgets('scales a Text with the device size', (tester) async {
      Future<double> scaledSizeAt(Size size) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);

        late double scaled;
        await tester.pumpWidget(
          MaterialApp(
            builder: (BuildContext context, Widget? child) =>
                AppTextScaling(child: child ?? const SizedBox.shrink()),
            home: Builder(
              builder: (BuildContext context) {
                scaled = MediaQuery.textScalerOf(context).scale(12);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        return scaled;
      }

      expect(await scaledSizeAt(const Size(375, 812)), 12);
      expect(await scaledSizeAt(const Size(320, 640)), closeTo(10.24, 0.01));
      expect(await scaledSizeAt(const Size(430, 932)), closeTo(13.44, 0.01));
    });

    testWidgets('clamps the device factor times the user scale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(430, 932);
      addTearDown(tester.view.reset);

      late double scaled;
      await tester.pumpWidget(
        MediaQuery(
          // A user who has pushed the system font size up.
          data: const MediaQueryData(
            size: Size(430, 932),
            textScaler: TextScaler.linear(2),
          ),
          child: MaterialApp(
            builder: (BuildContext context, Widget? child) =>
                AppTextScaling(child: child ?? const SizedBox.shrink()),
            home: Builder(
              builder: (BuildContext context) {
                scaled = MediaQuery.textScalerOf(context).scale(12);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // 1.12 x 2 would be 2.24; the composite ceiling holds it at 1.3.
      expect(scaled, closeTo(12 * AppTextScaling.maxCompositeFactor, 0.01));
    });
  });
}
