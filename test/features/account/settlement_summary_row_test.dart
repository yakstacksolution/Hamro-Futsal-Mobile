import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';

Future<void> _pump(WidgetTester tester, {double width = 411}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 800);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SettlementSummaryRow(
                counts: const SettlementStatusCounts(
                  pending: 0,
                  approved: 1,
                  paid: 14,
                  rejected: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('the row counts what is still moving, not what is done', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
    expect(find.text('Paid'), findsNothing);
    // The paid count goes with it — no stray 14 on the row.
    expect(find.text('14'), findsNothing);
  });

  testWidgets('the three tiles share the row evenly', (tester) async {
    await _pump(tester);

    final List<Rect> tiles = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(SettlementSummaryRow),
            matching: find.byType(Container),
          ),
        )
        .map((Container c) => tester.getRect(find.byWidget(c)))
        .toList();

    expect(tiles, hasLength(3));
    for (final Rect tile in tiles) {
      expect((tile.width - tiles.first.width).abs(), lessThan(0.5));
    }
    // They fill the row rather than leaving the old fourth slot empty.
    final Rect row = tester.getRect(find.byType(SettlementSummaryRow));
    expect(tiles.last.right, closeTo(row.right, 0.5));
  });

  testWidgets('it lays out on a narrow phone', (tester) async {
    await _pump(tester, width: 320);
    expect(tester.takeException(), isNull);
  });
}
