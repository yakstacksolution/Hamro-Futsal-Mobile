import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:hamro_futsal/features/products/data/model/product_models.dart';

void main() {
  group('money reads the same everywhere', () {
    test('a product price is spelled like every other figure', () {
      const ProductModel product = ProductModel(
        id: 25,
        venueId: 34,
        name: 'Water',
        price: 1250,
        isActive: true,
      );
      // Was `Rs. 1250` — three spellings of one figure across the app is what
      // made the sheet look like a different product to the cards.
      expect(product.formattedPrice, 'NPR 1,250');
      expect(product.formattedPrice, Money.npr(1250));
    });

    test('paisa survive and only show when there are any', () {
      expect(Money.npr(7.5), 'NPR 7.50');
      expect(Money.npr(1200), 'NPR 1,200');
      expect(Money.npr(1234567.89), 'NPR 1,234,567.89');
    });
  });

  group('CountBadge', () {
    Future<Rect> pumpBadge(WidgetTester tester, String count) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) => MaterialApp(
            home: Scaffold(
              body: Center(
                child: CountBadge(
                  count: count,
                  background: Colors.green.withValues(alpha: 0.16),
                  foreground: Colors.green,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.getRect(find.byType(CountBadge));
    }

    testWidgets('a single digit is a circle, not an oval', (tester) async {
      final Rect box = await pumpBadge(tester, '4');
      expect(box.width, box.height);

      final BoxDecoration decoration =
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byType(CountBadge),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration!
              as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.borderRadius, isNull);
    });

    testWidgets('two digits stay in the same circle', (tester) async {
      final Rect box = await pumpBadge(tester, '12');
      expect(box.width, box.height);
    });

    testWidgets('three characters become a pill rather than clipping', (
      tester,
    ) async {
      final Rect box = await pumpBadge(tester, '99+');
      expect(box.width, greaterThan(box.height));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the digits sit centred in the dot', (tester) async {
      final Rect box = await pumpBadge(tester, '4');
      final Rect digit = tester.getRect(find.text('4'));
      expect((digit.center.dx - box.center.dx).abs(), lessThan(0.6));
      expect((digit.center.dy - box.center.dy).abs(), lessThan(0.6));
    });
  });

  group('DataCard selected state', () {
    Future<void> pump(WidgetTester tester, {required bool selected}) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) => MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: DataCard(
                  selected: selected,
                  animate: true,
                  child: const Text('Water'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('tints the panel without changing its shape', (tester) async {
      await pump(tester, selected: false);
      final Rect plain = tester.getRect(find.byType(DataCard));
      final BoxDecoration plainBox =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;

      await pump(tester, selected: true);
      final Rect chosen = tester.getRect(find.byType(DataCard));
      final BoxDecoration chosenBox =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;

      // Same footprint — a selected card must not shift the list.
      expect(chosen.size, plain.size);
      expect(chosenBox.borderRadius, plainBox.borderRadius);
      // But a different surface and border.
      expect(chosenBox.color, isNot(plainBox.color));
      expect(chosenBox.border, isNot(plainBox.border));
    });
  });
}
