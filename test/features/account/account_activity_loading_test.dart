import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_loading_widgets.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';
import 'package:shimmer/shimmer.dart';

AccountEntryModel _entry() => AccountEntryModel.fromJson(<String, dynamic>{
  'type': 'booking_payment',
  'title': 'Venue booking payment',
  'reference': 'BK-TRJSQE1T',
  'date': '2026-09-14 06:00:00',
  'created_at': '2026-09-12 19:57:03',
  'amount': 1200,
  'direction': 'credit',
  'venue_name': 'Dhanawantary Sports',
});

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(411, 1200);
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
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('recent activity shimmer', () {
    testWidgets('a skeleton card is the size of the card it replaces', (
      tester,
    ) async {
      await _pump(tester, AccountEntryTile(entry: _entry()));
      final Size real = tester.getSize(find.byType(AccountEntryTile));

      await _pump(tester, const AccountListLoading(itemCount: 1));
      final Size skeleton = tester.getSize(find.byType(AccountListLoading));

      // Within a couple of points: the list must not visibly re-flow when the
      // real entries land.
      expect((skeleton.height - real.height).abs(), lessThan(3));
      expect(skeleton.width, real.width);
    });

    testWidgets('it shimmers', (tester) async {
      await _pump(tester, const AccountListLoading(itemCount: 2));
      expect(find.byType(Shimmer), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one skeleton per row, and the day heading when asked', (
      tester,
    ) async {
      await _pump(tester, const AccountListLoading(itemCount: 4));
      // Four card panels, no heading.
      expect(find.byType(Divider), findsNWidgets(4));

      await _pump(
        tester,
        const AccountListLoading(itemCount: 4, showDayHeader: true),
      );
      // The heading adds its own rule above the run.
      expect(find.byType(Divider), findsNWidgets(5));
    });

    testWidgets('a full run fits a short screen without overflowing', (
      tester,
    ) async {
      // The height that reproduced the report: five skeleton cards plus a day
      // heading are taller than the viewport they were being aligned into.
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(411, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) => MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: const AccountListLoading(showDayHeader: true),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(AccountListLoading), findsOneWidget);
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
                children: const <Widget>[AccountListLoading(itemCount: 5)],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      // Only the ListView's own scrollable — the placeholder does not nest one
      // inside it.
      expect(find.byType(Scrollable), findsOneWidget);
    });

    testWidgets('the whole-page skeleton includes activity cards', (
      tester,
    ) async {
      await _pump(tester, const AccountLoadingView());
      expect(find.byType(AccountListLoading), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
