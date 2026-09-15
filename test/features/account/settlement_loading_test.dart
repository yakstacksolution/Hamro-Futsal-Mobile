import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_loading_widgets.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';
import 'package:shimmer/shimmer.dart';

SettlementModel _settlement() => SettlementModel.fromJson(<String, dynamic>{
  'id': '31',
  'settlement_code': 'STL-4K2J9P',
  'requested_amount': 12500,
  'status': 'paid',
  'venue_name': 'Dhanawantary Sports',
  'requested_at': '2026-09-10 11:02:00',
  'resolved_at': '2026-09-12 16:40:00',
  'transaction_reference': 'TXN-99120043',
  'item_count': 4,
});

Future<void> _pump(WidgetTester tester, Widget child, {double h = 1200}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(411, h);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('settlements shimmer', () {
    testWidgets('a skeleton card is the size of the card it replaces', (
      tester,
    ) async {
      await _pump(tester, SettlementCard(settlement: _settlement()));
      final Size real = tester.getSize(find.byType(SettlementCard));

      await _pump(tester, const AccountSettlementListLoading(itemCount: 1));
      final Size skeleton = tester.getSize(
        find.byType(AccountSettlementListLoading),
      );

      // Within a few points: the list must not visibly re-flow when the real
      // settlements land.
      expect((skeleton.height - real.height).abs(), lessThan(6));
      expect(skeleton.width, real.width);
    });

    testWidgets('it shimmers', (tester) async {
      await _pump(tester, const AccountSettlementListLoading(itemCount: 2));
      expect(find.byType(Shimmer), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the summary tiles are included only when asked', (
      tester,
    ) async {
      await _pump(tester, const AccountSettlementListLoading(itemCount: 2));
      final int withoutSummary = find.byType(Shimmer).evaluate().length;

      await _pump(
        tester,
        const AccountSettlementListLoading(itemCount: 2, showSummary: true),
      );
      // One more shimmering block per status tile: Pending, Approved,
      // Rejected. Paid is not a tile — those settlements are done with.
      expect(
        find.byType(Shimmer).evaluate().length - withoutSummary,
        3,
      );
    });

    testWidgets('a full run fits a short screen without overflowing', (
      tester,
    ) async {
      // The shape that crashed the activity list: a page of skeletons handed a
      // bounded height.
      await _pump(
        tester,
        const AccountSettlementListLoading(showSummary: true),
        h: 640,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('inside a scrolling list it adds no scroll view of its own', (
      tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) => MaterialApp(
            home: Scaffold(
              body: ListView(
                children: const <Widget>[AccountSettlementListLoading()],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(Scrollable), findsOneWidget);
    });
  });
}
