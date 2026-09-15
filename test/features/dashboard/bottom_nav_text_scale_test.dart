import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/dashboard_nav_destinations.dart';

/// Crashlytics issue 6823bac6…: "A RenderFlex overflowed by 33 pixels on the
/// right" from `Row ← Padding ← … ← CustomBottomNavigationBar`, reported from
/// a Samsung SM-A546E (384dp wide). The bar's destinations were sized to their
/// content, and the active one carries a label that grows with the reader's
/// text scale, so a large scale overran the width.
///
/// These are guards, not a reproduction: the test font does not widen with the
/// text scale the way the shipped font does, so the bar does not overflow here
/// even without the fix. They still fail if the bar stops laying out at these
/// sizes at all.
Future<void> _pumpBar(
  WidgetTester tester, {
  required double width,
  required double textScale,
  int currentIndex = 0,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 800);
  // The scale the reader actually set on the device, applied where the
  // framework reads it from, so every MediaQuery below sees it.
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// True when the label had to be cut short to fit — what produced "C…".
bool _labelIsClipped(WidgetTester tester, String label) {
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
    find.text(label),
  );
  return paragraph.didExceedMaxLines;
}

void main() {
  group('the active destination shows its whole label', () {
    testWidgets('every destination, in full, at the default scale', (
      tester,
    ) async {
      for (int i = 0; i < dashboardNavDestinations.length; i++) {
        await _pumpBar(tester, width: 384, textScale: 1.0, currentIndex: i);
        final String label = dashboardNavDestinations[i].label;

        expect(find.text(label), findsOneWidget, reason: label);
        expect(
          _labelIsClipped(tester, label),
          isFalse,
          reason: '\$label was cut short',
        );
      }
    });

    testWidgets('in full on a narrow phone too', (tester) async {
      await _pumpBar(tester, width: 320, textScale: 1.0, currentIndex: 2);
      final String label = dashboardNavDestinations[2].label;
      expect(_labelIsClipped(tester, label), isFalse);
    });

    testWidgets('the label takes the room it needs, not an equal share', (
      tester,
    ) async {
      // The regression: five items each capped at a fifth of the bar, so the
      // labelled one was clipped while the rest of the bar sat empty.
      await _pumpBar(tester, width: 384, textScale: 1.0, currentIndex: 1);
      final double active = tester
          .getSize(
            find.ancestor(
              of: find.text(dashboardNavDestinations[1].label),
              matching: find.byType(Row),
            ).first,
          )
          .width;
      final double fifth = 360 / 5;
      expect(active, greaterThan(fifth * 0.5));
      expect(_labelIsClipped(tester, dashboardNavDestinations[1].label), isFalse);
    });
  });

  group('CustomBottomNavigationBar', () {
    testWidgets('fits at the default text scale', (tester) async {
      await _pumpBar(tester, width: 384, textScale: 1.0);
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
    });

    testWidgets('fits at the largest system text scale', (tester) async {
      // Android's accessibility font sizes go to 2.0x.
      await _pumpBar(tester, width: 384, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits on a narrow screen at a large scale', (tester) async {
      await _pumpBar(tester, width: 320, textScale: 1.8);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every destination can be the active one without overflow', (
      tester,
    ) async {
      for (int i = 0; i < dashboardNavDestinations.length; i++) {
        await _pumpBar(tester, width: 384, textScale: 1.6, currentIndex: i);
        expect(
          tester.takeException(),
          isNull,
          reason: 'destination $i overflowed',
        );
      }
    });
  });
}
