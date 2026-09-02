import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/dashboard/presentation/page/futsal_home_page.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/dashboard_nav_destinations.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/dashboard_side_nav.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/loading/home_body_loading.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/venue_status_widget.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';

/// Sizes representing each breakpoint.
const Size _phone = Size(411, 891);
const Size _tabletPortrait = Size(800, 1280);
const Size _tabletLandscape = Size(1280, 800);
const Size _desktopNarrow = Size(1100, 800);
const Size _desktopWindow = Size(1440, 900);

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) {
        return MaterialApp(home: Scaffold(body: child));
      },
    ),
  );
  await tester.pump();
}

/// The column count a `SliverGridDelegateWithFixedCrossAxisCount` in the tree
/// resolved to, or 1 when the layout used a plain list instead.
int _resolvedColumns(WidgetTester tester) {
  final Iterable<GridView> grids = tester.widgetList<GridView>(
    find.byType(GridView),
  );
  if (grids.isEmpty) return 1;
  final SliverGridDelegate delegate = grids.first.gridDelegate;
  return (delegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount;
}

void main() {
  group('DashboardSideNav', () {
    testWidgets('collapsed rail is icon-only at the rail width', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _tabletPortrait,
        DashboardSideNav(currentIndex: 0, onTap: (_) {}),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(DashboardSideNav)).width,
        AppDimens.dashboardRailWidth,
      );
      // Labels are tooltips only, not visible text.
      expect(find.text(StringConstants.home), findsNothing);
      expect(
        find.byType(Tooltip),
        findsNWidgets(dashboardNavDestinations.length),
      );
    });

    testWidgets('extended sidebar shows every label at the wider width', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _desktopWindow,
        DashboardSideNav(currentIndex: 0, onTap: (_) {}, extended: true),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(DashboardSideNav)).width,
        AppDimens.dashboardRailExtendedWidth,
      );
      for (final DashboardNavDestination d in dashboardNavDestinations) {
        expect(find.text(d.label), findsOneWidget, reason: d.label);
      }
    });

    testWidgets('destinations sit at the top-left of the pane', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _tabletPortrait,
        DashboardSideNav(currentIndex: 0, onTap: (_) {}),
      );

      final Rect nav = tester.getRect(find.byType(DashboardSideNav));
      final Iterable<Rect> items = tester
          .widgetList<InkWell>(find.byType(InkWell))
          .map((InkWell w) => tester.getRect(find.byWidget(w)));

      // Top: the first destination starts near the top of the pane, nowhere
      // near vertically centred.
      final double firstTop = items.first.top;
      expect(firstTop - nav.top, lessThan(40));
      expect(firstTop, lessThan(nav.center.dy));

      // Left: every destination hugs the left edge.
      for (final Rect item in items) {
        expect(item.left - nav.left, lessThan(20), reason: '$item');
      }
    });

    testWidgets('tapping a destination reports its index', (
      WidgetTester tester,
    ) async {
      final List<int> taps = <int>[];
      await _pumpAt(
        tester,
        _desktopWindow,
        DashboardSideNav(currentIndex: 0, onTap: taps.add, extended: true),
      );

      await tester.tap(find.text(StringConstants.wishlist));
      await tester.pump();
      expect(taps, <int>[3]);
    });
  });

  group('Home feed skeleton column count', () {
    for (final (String label, Size size, int expected) in <(String, Size, int)>[
      ('phone', _phone, 1),
      ('tablet portrait', _tabletPortrait, 2),
      ('narrow desktop', _desktopNarrow, 3),
      // Capped at 3 -- a 4th column would leave ~320px cells.
      ('tablet landscape', _tabletLandscape, 3),
      ('desktop window', _desktopWindow, 3),
    ]) {
      testWidgets('$label uses $expected column(s)', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size, const HomeBodyLoading());

        expect(tester.takeException(), isNull);
        expect(_resolvedColumns(tester), expected);
      });
    }
  });

  group('CourtCard in a fixed-height grid cell', () {
    const PublicListingVenueModel venue = PublicListingVenueModel(
      id: 1,
      name: 'Test Futsal Arena',
      address: 'Some long street address that should ellipsize, Kathmandu',
      price: 1500,
      isOpen: true,
    );

    // The main risk in the grid layout: a fixed cell height with a card whose
    // cover was originally pinned to 200px.
    for (final (String label, Size size, int columns) in <(String, Size, int)>[
      ('tablet portrait', _tabletPortrait, 2),
      ('narrow desktop', _desktopNarrow, 3),
      ('desktop window', _desktopWindow, 3),
    ]) {
      testWidgets('$label fits $columns per row without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpAt(
          tester,
          size,
          GridView.builder(
            itemCount: columns * 2,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: AppDimens.sizeX20,
              mainAxisSpacing: AppDimens.sizeX20,
              mainAxisExtent: AppDimens.courtCardGridExtent,
            ),
            itemBuilder: (BuildContext context, int index) => const CourtCard(
              publicListingVenueModel: venue,
              flexibleCover: true,
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        // Cards fill their cell height exactly.
        expect(
          tester.getSize(find.byType(CourtCard).first).height,
          AppDimens.courtCardGridExtent,
        );
      });
    }

    // Regression: on a ~600px tablet the grid cell is only ~220px wide once the
    // 72px side rail and the pane padding are taken out, and the price
    // collapsed to "R..." -- so these cases must include the rail, and must
    // measure the rendered width. `find.textContaining` alone passes even when
    // the text is ellipsized away.
    for (final (String label, Size size, double scale)
        in <(String, Size, double)>[
          ('600px tablet', Size(600, 960), 1.0),
          ('600px tablet, large font', Size(601, 960), 1.3),
          ('tablet portrait', _tabletPortrait, 1.0),
          ('tablet portrait, large font', _tabletPortrait, 1.3),
          ('desktop window', _desktopWindow, 1.0),
        ]) {
      testWidgets('$label renders the full price beside the rail', (
        WidgetTester tester,
      ) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);

        late int columns;
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (BuildContext context, Widget? _) => MaterialApp(
              builder: (BuildContext context, Widget? child) =>
                  MediaQuery.withClampedTextScaling(
                    minScaleFactor: scale,
                    maxScaleFactor: scale,
                    child: child!,
                  ),
              // Mirrors the shell: rail + padded content pane.
              home: Scaffold(
                body: Row(
                  children: <Widget>[
                    const SizedBox(width: AppDimens.dashboardRailWidth),
                    Expanded(
                      child: Builder(
                        builder: (BuildContext context) {
                          columns = venueGridColumns(
                            context,
                            MediaQuery.sizeOf(context).width -
                                AppDimens.dashboardRailWidth -
                                AppDimens.paddingX32 * 2,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingX32,
                            ),
                            child: GridView.builder(
                              itemCount: columns,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: AppDimens.sizeX20,
                                    mainAxisSpacing: AppDimens.sizeX20,
                                    mainAxisExtent:
                                        AppDimens.courtCardGridExtent,
                                  ),
                              itemBuilder: (BuildContext context, int index) =>
                                  const CourtCard(
                                    publicListingVenueModel: venue,
                                    flexibleCover: true,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final Finder price = find.textContaining('Rs. 1500').first;
        expect(price, findsOneWidget);

        // Price and status share one line, pushed to opposite edges.
        final Rect priceRect = tester.getRect(price);
        final Rect statusRect = tester.getRect(
          find.byType(VenueStatusWidget).first,
        );
        expect(
          statusRect.left,
          greaterThan(priceRect.right),
          reason: 'status should sit to the right of the price',
        );
        expect(
          (statusRect.center.dy - priceRect.center.dy).abs(),
          lessThan(12),
          reason: 'status wrapped onto a second line instead of spacing out',
        );
        final Rect cardRect = tester.getRect(find.byType(CourtCard).first);
        // Price hugs the left inset, status hugs the right one.
        expect(priceRect.left - cardRect.left, lessThan(24));
        expect(cardRect.right - statusRect.right, lessThan(24));
        // Wide enough for the digits: an ellipsized price measured ~17-29px.
        expect(
          tester.getSize(price).width,
          greaterThan(80),
          reason: 'price collapsed to an ellipsis',
        );
        // Stays inside its card.
        final Rect card = tester.getRect(find.byType(CourtCard).first);
        expect(tester.getRect(price).bottom, lessThanOrEqualTo(card.bottom));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('wide card shows the same parts as the phone card', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _desktopWindow,
        const CourtCard(publicListingVenueModel: venue, flexibleCover: true),
      );

      expect(tester.takeException(), isNull);
      // Same content as phone: name, address, price and the status pill in the
      // bottom row. Only sizing and pointer affordances differ.
      expect(find.text('Test Futsal Arena'), findsOneWidget);
      expect(
        find.text('Some long street address that should ellipsize, Kathmandu'),
        findsOneWidget,
      );
      expect(find.textContaining('Rs. 1500'), findsOneWidget);
      expect(find.byType(VenueStatusWidget), findsOneWidget);
      expect(find.byType(MouseRegion), isNot(findsNothing));
    });

    testWidgets('hovering a wide card lifts it', (WidgetTester tester) async {
      await _pumpAt(
        tester,
        _desktopWindow,
        const CourtCard(publicListingVenueModel: venue, flexibleCover: true),
      );

      final TestGesture pointer = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await pointer.addPointer(location: Offset.zero);
      addTearDown(pointer.removePointer);

      await pointer.moveTo(tester.getCenter(find.byType(CourtCard)));
      await tester.pumpAndSettle();

      // The lift is a scale change on the card's AnimatedScale.
      final Transform lifted = tester.widget<Transform>(
        find
            .descendant(
              of: find.byType(CourtCard),
              matching: find.byType(Transform),
            )
            .first,
      );
      expect(lifted.transform.getMaxScaleOnAxis(), greaterThan(1.0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone card shows the same parts', (WidgetTester tester) async {
      await _pumpAt(
        tester,
        _phone,
        ListView(
          children: const <Widget>[CourtCard(publicListingVenueModel: venue)],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Test Futsal Arena'), findsOneWidget);
      expect(
        find.text('Some long street address that should ellipsize, Kathmandu'),
        findsOneWidget,
      );
      expect(find.textContaining('Rs. 1500'), findsOneWidget);
      expect(find.byType(VenueStatusWidget), findsOneWidget);
    });

    testWidgets('phone list keeps the original fixed 200px cover', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _phone,
        ListView(
          children: const <Widget>[CourtCard(publicListingVenueModel: venue)],
        ),
      );

      expect(tester.takeException(), isNull);
      // Free height: cover 200 + the natural text block, so taller than the
      // grid cell would be but never clipped.
      expect(
        tester.getSize(find.byType(CourtCard)).height,
        greaterThan(AppDimens.sizeX200),
      );
    });
  });
}
