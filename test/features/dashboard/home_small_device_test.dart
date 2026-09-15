import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/utils/text_scaling.dart';
import 'package:hamro_futsal/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_futsal/features/dashboard/presentation/page/futsal_home_page.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/loading/home_body_loading.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/search_bar_widget.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';

/// The smallest screens the app still has to look right on: an iPhone SE (1st
/// gen) / small Android at 320pt, and a 360pt Android, which is the most
/// common width in Nepal.
const Size _tiny = Size(320, 568);
const Size _small = Size(360, 640);

/// A venue with the long name, long address and 4-digit price that squeeze a
/// narrow card hardest.
const PublicListingVenueModel _venue = PublicListingVenueModel(
  id: 1,
  name: 'Chyasal Futsal and Sports Academy Center',
  address: 'Chyasal, Lalitpur, Bagmati Province, Nepal',
  price: 1500,
  isOpen: true,
  isVerified: true,
  distanceKm: 12.75,
);

/// Pumps [child] at [size] through the app's real shell: ScreenUtil, the
/// device text scaling and the page insets the home tab uses.
Future<void> _pumpHome(
  WidgetTester tester,
  Size size,
  Widget child, {
  double? userTextScale,
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
        builder: (BuildContext context, Widget? inner) {
          Widget wrapped = AppTextScaling(
            child: inner ?? const SizedBox.shrink(),
          );
          if (userTextScale != null) {
            wrapped = MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(userTextScale),
              ),
              child: wrapped,
            );
          }
          return wrapped;
        },
        home: Scaffold(
          body: Padding(
            // The horizontal inset the home header and feed both use.
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() async {
    // The search bar reads its recent searches from AppSettings.
    await AppSettings().init(_MemoryPreferences());
  });

  group('HomeGreeting', () {
    for (final (String label, Size size) in <(String, Size)>[
      ('320pt', _tiny),
      ('360pt', _small),
    ]) {
      testWidgets('$label ellipsises a long greeting instead of overflowing', (
        WidgetTester tester,
      ) async {
        await _pumpHome(
          tester,
          size,
          const HomeGreeting(
            text: 'Good afternoon, Bhandarikrishna 👋',
            trailing: SizedBox.square(dimension: 44),
          ),
        );

        expect(tester.takeException(), isNull);
        // Greeting and button share one line, inside the content width.
        final Rect greeting = tester.getRect(
          find.text('Good afternoon, Bhandarikrishna 👋'),
        );
        final Rect trailing = tester.getRect(find.byType(SizedBox).first);
        expect(greeting.right, lessThanOrEqualTo(trailing.left));
        expect(trailing.right, lessThanOrEqualTo(size.width - 20));
      });
    }

    testWidgets('holds up at the maximum text scale', (
      WidgetTester tester,
    ) async {
      await _pumpHome(
        tester,
        _tiny,
        const HomeGreeting(
          text: 'Good afternoon, Bhandarikrishna 👋',
          trailing: SizedBox.square(dimension: 44),
        ),
        userTextScale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Home feed on a small device', () {
    for (final (String label, Size size) in <(String, Size)>[
      ('320pt', _tiny),
      ('360pt', _small),
    ]) {
      testWidgets('$label renders a venue card without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpHome(
          tester,
          size,
          ListView(
            children: const <Widget>[CourtCard(publicListingVenueModel: _venue)],
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.textContaining('Rs. 1500'), findsOneWidget);
        expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
        // The card stays inside the content width.
        expect(
          tester.getSize(find.byType(CourtCard)).width,
          closeTo(size.width - 40, 1),
        );
      });

      testWidgets('$label renders the card at the maximum text scale', (
        WidgetTester tester,
      ) async {
        await _pumpHome(
          tester,
          size,
          ListView(
            children: const <Widget>[CourtCard(publicListingVenueModel: _venue)],
          ),
          userTextScale: 2,
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets('$label lays out the skeleton in one column', (
        WidgetTester tester,
      ) async {
        await _pumpHome(tester, size, const HomeBodyLoading());
        expect(tester.takeException(), isNull);
      });

      testWidgets('$label keeps the search field usable beside its buttons', (
        WidgetTester tester,
      ) async {
        await _pumpHome(
          tester,
          size,
          ExpandableFocusSearchBar(
            onSubmitted: (_) {},
            onFilterTap: () {},
            filterCount: 3,
          ),
        );

        expect(tester.takeException(), isNull);
        // Not squeezed to nothing by the clear/filter buttons.
        expect(
          tester.getSize(find.byType(TextField)).width,
          greaterThan(120),
          reason: 'search input collapsed on a $label screen',
        );
      });
    }
  });
}

/// In-memory [Preferences] so widgets that touch AppSettings can be pumped.
final class _MemoryPreferences implements Preferences {
  final Map<String, Object> _values = <String, Object>{};

  @override
  String? getString(String key) => _values[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  List<String> getStringList(String key) =>
      (_values[key] as List<String>?) ?? <String>[];
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _values[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _values[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => _values[key] as double?;
  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _values[key] as int?;
  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}
