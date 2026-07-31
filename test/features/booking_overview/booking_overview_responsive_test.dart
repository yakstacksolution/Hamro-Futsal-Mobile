import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_summary_widgets.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_tabs.dart';

/// Sizes representing each breakpoint.
const Size _phone = Size(411, 891);
const Size _tabletPortrait = Size(800, 1280);
const Size _desktopWindow = Size(1440, 900);

/// The page is full-width now, so the pane is the window minus its insets.
const double _desktopPaneWidth = 1440 - AppDimens.paddingX32 * 2;

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  Widget child, {
  double? paneWidth,
  // The revenue chart starts an animation timer that outlives a bare pump.
  Duration settle = Duration.zero,
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
        home: Scaffold(
          body: Center(
            child: SizedBox(width: paneWidth, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  if (settle > Duration.zero) await tester.pump(settle);
}

BookingAnalytics _analytics() {
  final BookingOverviewResponse data = BookingOverviewResponse.fromResponse(
    const <String, dynamic>{
      'data': <String, dynamic>{
        'filters': <String, dynamic>{
          'date_from': '2026-07-01',
          'date_to': '2026-07-07',
        },
      },
    },
  );
  return BookingAnalytics(
    data: data,
    period: BookingPeriod.week,
    range: BookingRange.fromApi('2026-07-01', '2026-07-07'),
  );
}

/// Column count the KPI Wrap resolved to, from the rendered tile widths.
int _kpiColumns(WidgetTester tester) {
  final Size wrapSize = tester.getSize(find.byType(Wrap).first);
  final Size tile = tester.getSize(
    find
        .descendant(of: find.byType(Wrap), matching: find.byType(SizedBox))
        .first,
  );
  return ((wrapSize.width + AppDimens.paddingX10) /
          (tile.width + AppDimens.paddingX10))
      .round();
}

void main() {
  group('columnsFor', () {
    test('derives the count from a minimum item width', () {
      expect(
        columnsFor(availableWidth: 300, minItemWidth: 220, spacing: 10),
        1,
      );
      expect(
        columnsFor(availableWidth: 460, minItemWidth: 220, spacing: 10),
        2,
      );
      expect(
        columnsFor(availableWidth: 700, minItemWidth: 220, spacing: 10),
        3,
      );
      // Never below one, never above the cap.
      expect(columnsFor(availableWidth: 10, minItemWidth: 220), 1);
      expect(
        columnsFor(availableWidth: 5000, minItemWidth: 220, maxColumns: 4),
        4,
      );
    });
  });

  group('BookingKpiGrid', () {
    testWidgets('phone keeps two tiles per row', (WidgetTester tester) async {
      await _pumpAt(tester, _phone, BookingKpiGrid(analytics: _analytics()));

      expect(tester.takeException(), isNull);
      expect(_kpiColumns(tester), 2);
    });

    // Every row must be full: six KPIs at five columns would strand one.
    for (final (String label, double pane, int expected)
        in <(String, double, int)>[
          ('600px tablet pane', 464, 2),
          ('800px tablet pane', 664, 3),
          ('1100px pane', 964, 3),
          ('1440px desktop pane', _desktopPaneWidth, 6),
          ('very wide pane', 1784, 6),
        ]) {
      testWidgets('$label uses $expected columns', (WidgetTester tester) async {
        await _pumpAt(
          tester,
          _desktopWindow,
          BookingKpiGrid(analytics: _analytics()),
          paneWidth: pane,
        );

        expect(tester.takeException(), isNull);
        expect(_kpiColumns(tester), expected);
        // 6 tiles divided evenly -- no partial last row.
        expect(6 % _kpiColumns(tester), 0);
      });
    }

    testWidgets('never drops below two tiles, even in a narrow pane', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _phone,
        BookingKpiGrid(analytics: _analytics()),
        paneWidth: 320,
      );

      expect(tester.takeException(), isNull);
      expect(_kpiColumns(tester), 2);
    });
  });

  group('Tab bodies', () {
    testWidgets('analytics tab stacks its two cards below desktop', (
      WidgetTester tester,
    ) async {
      for (final Size size in <Size>[_phone, _tabletPortrait]) {
        await _pumpAt(
          tester,
          size,
          BookingAnalyticsTab(analytics: _analytics()),
          settle: const Duration(seconds: 3),
        );
        expect(tester.takeException(), isNull, reason: '$size');

        final Offset trend = tester.getTopLeft(find.text('Revenue trend'));
        final Offset status = tester.getTopLeft(find.text('Booking statuses'));
        expect(status.dy, greaterThan(trend.dy), reason: '$size should stack');
      }
    });

    testWidgets('analytics tab pairs its two cards on desktop', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _desktopWindow,
        BookingAnalyticsTab(analytics: _analytics()),
        paneWidth: _desktopPaneWidth,
        settle: const Duration(seconds: 3),
      );

      expect(tester.takeException(), isNull);
      final Offset trend = tester.getTopLeft(find.text('Revenue trend'));
      final Offset status = tester.getTopLeft(find.text('Booking statuses'));
      expect(status.dy, trend.dy, reason: 'same row');
      expect(status.dx, greaterThan(trend.dx), reason: 'second column');
    });

    testWidgets('rankings tab pairs the two leaderboards on desktop', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _desktopWindow,
        BookingRankingsTab(analytics: _analytics()),
        paneWidth: _desktopPaneWidth,
      );

      expect(tester.takeException(), isNull);
      final Offset courts = tester.getTopLeft(find.text('Top courts'));
      final Offset customers = tester.getTopLeft(find.text('Top customers'));
      expect(customers.dy, courts.dy);
      expect(customers.dx, greaterThan(courts.dx));
      // The venue card above them stays full width.
      final Offset venue = tester.getTopLeft(find.text('Performance by venue'));
      expect(venue.dy, lessThan(courts.dy));
    });

    testWidgets('rankings tab stacks all three on phone', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _phone,
        BookingRankingsTab(analytics: _analytics()),
      );

      expect(tester.takeException(), isNull);
      final double venue = tester
          .getTopLeft(find.text('Performance by venue'))
          .dy;
      final double courts = tester.getTopLeft(find.text('Top courts')).dy;
      final double customers = tester.getTopLeft(find.text('Top customers')).dy;
      expect(courts, greaterThan(venue));
      expect(customers, greaterThan(courts));
    });
  });
}
