import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/utils/text_scaling.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_bottom_action_bar.dart';

Future<void> _pumpBar(
  WidgetTester tester, {
  required Size size,
  bool hasPrevious = true,
  String nextLabel = 'Save & Continue',
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) => MaterialApp(
        builder: (BuildContext context, Widget? child) =>
            AppTextScaling(child: child ?? const SizedBox.shrink()),
        home: Scaffold(
          bottomNavigationBar: VendorBottomActionBar(
            hasPrevious: hasPrevious,
            isSubmitting: false,
            nextLabel: nextLabel,
            onPrevious: () {},
            onNext: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  for (final (String label, Size size) in <(String, Size)>[
    ('320pt', Size(320, 568)),
    ('411pt', Size(411, 891)),
    ('tablet', Size(800, 1280)),
  ]) {
    testWidgets('$label gives Back and Next the same width', (
      WidgetTester tester,
    ) async {
      await _pumpBar(tester, size: size);

      expect(tester.takeException(), isNull);
      final Size back = tester.getSize(
        find.text(StringConstants.back).hitTestable().first,
      );
      expect(back.width, greaterThan(0));

      final double backWidth = tester
          .getSize(
            find.ancestor(
              of: find.text(StringConstants.back),
              matching: find.byType(Ink),
            ),
          )
          .width;
      final double nextWidth = tester.getSize(find.byType(CustomButton)).width;

      expect(
        backWidth,
        closeTo(nextWidth, 1),
        reason: 'Back and Next should split the bar evenly at $label',
      );
    });

    testWidgets('$label keeps both buttons the same height', (
      WidgetTester tester,
    ) async {
      await _pumpBar(tester, size: size);

      final double backHeight = tester
          .getSize(
            find.ancestor(
              of: find.text(StringConstants.back),
              matching: find.byType(Ink),
            ),
          )
          .height;
      final double nextHeight = tester
          .getSize(find.byType(CustomButton))
          .height;

      expect(backHeight, closeTo(nextHeight, 1));
    });
  }

  testWidgets('a long next label does not shrink the Back button', (
    WidgetTester tester,
  ) async {
    await _pumpBar(
      tester,
      size: const Size(320, 568),
      nextLabel: 'Save this court and continue to slots',
    );

    expect(tester.takeException(), isNull);
    final double backWidth = tester
        .getSize(
          find.ancestor(
            of: find.text(StringConstants.back),
            matching: find.byType(Ink),
          ),
        )
        .width;
    final double nextWidth = tester.getSize(find.byType(CustomButton)).width;

    expect(backWidth, closeTo(nextWidth, 1));
  });

  testWidgets('the first step shows only Next, full width', (
    WidgetTester tester,
  ) async {
    await _pumpBar(tester, size: const Size(411, 891), hasPrevious: false);

    expect(tester.takeException(), isNull);
    expect(find.text(StringConstants.back), findsNothing);
    // Next spans the bar, minus its padding — nothing shares the row.
    expect(tester.getSize(find.byType(CustomButton)).width, greaterThan(360));
  });
}
