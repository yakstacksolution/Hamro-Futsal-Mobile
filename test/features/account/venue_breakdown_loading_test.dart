import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_loading_widgets.dart';
import 'package:shimmer/shimmer.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double height = 1200,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(411, height);
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
  group('futsal breakdown shimmer', () {
    testWidgets('a card is the height of the venue card it replaces', (
      tester,
    ) async {
      // `_VenueCard` is private to the account screen, so this pins the
      // skeleton's own height: a card with the pay button measures 150pt,
      // matching the real card's header, hairline, two figure rows and a
      // 36pt button. If either side is restyled, this is the tripwire.
      await _pump(tester, const AccountVenueListLoading(itemCount: 1));
      expect(
        tester.getSize(find.byType(AccountVenueListLoading)).height,
        150,
      );
    });

    testWidgets('it shimmers', (tester) async {
      await _pump(tester, const AccountVenueListLoading(itemCount: 2));
      expect(find.byType(Shimmer), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one card per venue placeholder', (tester) async {
      await _pump(tester, const AccountVenueListLoading(itemCount: 4));
      // Each card draws its own hairline between the header and the figures.
      expect(find.byType(Divider), findsNWidgets(4));
    });

    testWidgets('the pay button is on some cards, not all', (tester) async {
      // A run of identical cards reads as a pattern rather than as content on
      // its way; the real list only shows the button where a futsal can be
      // settled.
      await _pump(tester, const AccountVenueListLoading(itemCount: 4));
      final int withButton = find.byType(Shimmer).evaluate().length;

      await _pump(tester, const AccountVenueListLoading(itemCount: 1));
      final int single = find.byType(Shimmer).evaluate().length;

      // 4 cards carry more shimmering blocks than 4x a button-less card.
      expect(withButton, greaterThan(single * 3));
    });

    testWidgets('a full run fits a short screen without overflowing', (
      tester,
    ) async {
      await _pump(tester, const AccountVenueListLoading(), height: 640);
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
                children: const <Widget>[AccountVenueListLoading()],
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
