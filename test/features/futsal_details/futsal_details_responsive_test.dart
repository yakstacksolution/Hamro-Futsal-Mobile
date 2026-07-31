import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_amenities.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/details_image_gallery.dart';

/// Sizes representing each breakpoint.
const Size _phone = Size(411, 891);
const Size _tabletPortrait = Size(800, 1280);
const Size _desktopWindow = Size(1440, 900);

/// On desktop the details content shares the window with the booking panel, so
/// the pane the gallery actually gets is narrower than the window.
double _desktopPaneWidth(double windowWidth) =>
    windowWidth - AppDimens.venueBookingPanelWidth;

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  Widget child, {
  double? paneWidth,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) {
        return MaterialApp(
          home: Scaffold(
            body: paneWidth == null
                ? child
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: paneWidth, child: child),
                      const Spacer(),
                    ],
                  ),
          ),
        );
      },
    ),
  );
  await tester.pump();
}

const List<String> _images = <String>[
  'https://example.com/1.jpg',
  'https://example.com/2.jpg',
  'https://example.com/3.jpg',
  'https://example.com/4.jpg',
];

void main() {
  group('DetailsImageGallery', () {
    testWidgets('phone keeps the original fixed 340px hero', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _phone, const DetailsImageGallery(images: _images));

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PageView)).height, 340);
      // Dots, no thumbnail strip.
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('tablet scales the hero 16:9 and adds thumbnails', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _tabletPortrait,
        const DetailsImageGallery(images: _images),
      );

      expect(tester.takeException(), isNull);
      final double heroHeight = tester.getSize(find.byType(PageView)).height;
      // 800 * 9/16 = 450, under the 460 cap.
      expect(heroHeight, closeTo(800 * 9 / 16, 1));
      expect(heroHeight, lessThanOrEqualTo(AppDimens.venueHeroMaxHeight));

      // One thumbnail per image (the tile is the AnimatedContainer; the
      // ListView contributes GestureDetectors of its own for scrolling).
      expect(find.byType(ListView), findsOneWidget);
      final Finder thumbs = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(AnimatedContainer),
      );
      expect(thumbs, findsNWidgets(_images.length));
      expect(tester.getSize(thumbs.first).width, AppDimens.venueThumbnailSize);
    });

    testWidgets('hero is capped so a wide window does not get a giant band', (
      WidgetTester tester,
    ) async {
      // A 1440 window would give 810px at 16:9 without the cap.
      await _pumpAt(
        tester,
        _desktopWindow,
        const DetailsImageGallery(images: _images),
        paneWidth: _desktopPaneWidth(_desktopWindow.width),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(PageView)).height,
        AppDimens.venueHeroMaxHeight,
      );
    });

    testWidgets('a single image shows no thumbnail strip', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _tabletPortrait,
        const DetailsImageGallery(images: <String>['https://x/1.jpg']),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('empty image list does not crash at any width', (
      WidgetTester tester,
    ) async {
      for (final Size size in <Size>[_phone, _tabletPortrait]) {
        await _pumpAt(tester, size, const DetailsImageGallery());
        expect(tester.takeException(), isNull, reason: '$size');
      }
    });
  });

  group('CourtAmenitiesSection', () {
    // Long enough to need several rows in any pane.
    const List<String> features = <String>[
      'Free Parking',
      'Changing Rooms',
      'Floodlights',
      'Drinking Water',
      'First Aid Kit',
      'Cafeteria',
      'Wi-Fi',
      'Lockers',
      'Showers',
      'Spectator Seating',
      'Equipment Rental',
      'CCTV Security',
    ];

    for (final (String label, Size size, double? pane)
        in <(String, Size, double?)>[
          ('phone', _phone, null),
          ('tablet', _tabletPortrait, AppDimens.venueContentMaxWidth),
          (
            'desktop pane',
            _desktopWindow,
            1440 - AppDimens.venueBookingPanelWidth,
          ),
        ]) {
      testWidgets('$label wraps amenity tiles without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpAt(
          tester,
          size,
          const SingleChildScrollView(
            child: CourtAmenitiesSection(features: features),
          ),
          paneWidth: pane,
        );

        expect(tester.takeException(), isNull);
        // The Wrap must produce more than one row, i.e. tiles are not all on
        // a single line running off the edge.
        final Size wrapSize = tester.getSize(find.byType(Wrap).first);
        final double tileHeight = tester
            .getSize(find.byType(IntrinsicWidth).first)
            .height;
        expect(
          wrapSize.height,
          greaterThan(tileHeight * 1.5),
          reason: 'tiles should span multiple rows',
        );
      });
    }
  });
}
