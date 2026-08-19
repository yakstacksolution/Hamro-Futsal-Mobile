import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/venue_status_widget.dart';

/// Sizes representing each breakpoint.
const Size _phone = Size(411, 891);
const Size _tabletSmall = Size(600, 960);
const Size _tabletPortrait = Size(800, 1280);
const Size _desktopWindow = Size(1440, 900);

const PublicListingVenueModel _venue = PublicListingVenueModel(
  id: 1,
  name: 'Saved Futsal Arena',
  address: 'Some long street address that should ellipsize, Kathmandu',
  price: 1500,
  isOpen: true,
);

/// Rebuilds what the wishlist body renders, inside the real shell geometry
/// (side rail + padded content pane). `WishlistPage` itself calls the wishlist
/// endpoint in `initState`, so it is not directly pumpable.
Future<void> _pumpWishlistBody(
  WidgetTester tester,
  Size size, {
  int itemCount = 6,
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
          body: Row(
            children: <Widget>[
              // The dashboard rail is present at tablet widths and up.
              if (size.width >= AppDimens.venueContentMaxWidth - 200)
                const SizedBox(width: AppDimens.dashboardRailWidth),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int columns = venueGridColumns(
                      context,
                      constraints.maxWidth - AppDimens.paddingX32 * 2,
                    );
                    if (columns == 1) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppDimens.paddingX20),
                        itemCount: itemCount,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppDimens.sizeX20),
                        itemBuilder: (_, __) =>
                            const CourtCard(publicListingVenueModel: _venue),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(AppDimens.paddingX32),
                      itemCount: itemCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppDimens.sizeX20,
                        mainAxisSpacing: AppDimens.sizeX20,
                        mainAxisExtent: AppDimens.courtCardGridExtent,
                      ),
                      itemBuilder: (_, __) => const CourtCard(
                        publicListingVenueModel: _venue,
                        flexibleCover: true,
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
}

void main() {
  group('Wishlist listing', () {
    testWidgets('phone keeps the single-column list', (
      WidgetTester tester,
    ) async {
      await _pumpWishlistBody(tester, _phone);

      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      // Free-height card: the original fixed 200px cover plus its text block.
      expect(
        tester.getSize(find.byType(CourtCard).first).height,
        greaterThan(AppDimens.sizeX200),
      );
    });

    for (final (String label, Size size) in <(String, Size)>[
      ('600px tablet', _tabletSmall),
      ('tablet portrait', _tabletPortrait),
      ('desktop window', _desktopWindow),
    ]) {
      testWidgets('$label lays out cards without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpWishlistBody(tester, size);

        expect(tester.takeException(), isNull);
        // Whatever the column count resolves to, the cards must render their
        // price and status pill fully -- same contract as the home feed.
        final Finder price = find.textContaining('Rs. 1500').first;
        expect(tester.getSize(price).width, greaterThan(80));
        expect(find.byType(VenueStatusWidget), findsWidgets);
      });
    }

    testWidgets('tablet and desktop use a grid with the shared column count', (
      WidgetTester tester,
    ) async {
      await _pumpWishlistBody(tester, _tabletPortrait);

      expect(find.byType(GridView), findsOneWidget);
      final GridView grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, greaterThan(1));
      // Cards fill the fixed cell exactly, as on the home feed.
      expect(
        tester.getSize(find.byType(CourtCard).first).height,
        AppDimens.courtCardGridExtent,
      );
    });
  });
}
