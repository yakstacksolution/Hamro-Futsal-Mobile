import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';

/// The operational home greets the vendor as the futsal home does —
/// "Good evening, Ram 👋" — where the date controls used to be.
void main() {
  setUp(() {
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 4, 15));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  final RegExp greeting = RegExp(r'^Good (morning|afternoon|evening), ');

  Future<void> pump(WidgetTester tester, Size size, {String? name}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: FutsalTheme.lightTheme,
        home: Scaffold(
          body: VendorOperationsHome(demo: true, userName: name),
        ),
      ),
    );
    for (int i = 0; i < 8; i++) {
      await tester.pump(VendorOpsDemoStore.latency ~/ 2);
    }
  }

  for (final Size size in const <Size>[Size(320, 900), Size(1440, 1000)]) {
    testWidgets('greets by first name at ${size.width.toInt()} px', (
      tester,
    ) async {
      await pump(tester, size, name: 'Ram');
      final Finder text = find.textContaining(greeting);
      expect(text, findsOneWidget);
      expect((tester.widget<Text>(text)).data, endsWith(', Ram 👋'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('before the profile loads it says "there"', (tester) async {
    await pump(tester, const Size(390, 900));
    final Finder text = find.textContaining(greeting);
    expect((tester.widget<Text>(text)).data, endsWith(', there 👋'));
  });
}
