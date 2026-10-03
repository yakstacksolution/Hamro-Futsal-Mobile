import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/widgets/dashboard_layout.dart';

void main() {
  testWidgets('cards in a dashboard row share the tallest height', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1000,
              child: DashboardEqualHeightRow(
                flexes: <int>[1, 2],
                gap: 20,
                children: const <Widget>[
                  // A short card and a tall one, laid out by a LayoutBuilder
                  // as the real KPI grids are (no intrinsic height).
                  ColoredBox(
                    key: Key('short'),
                    color: Colors.red,
                    child: SizedBox(height: 120),
                  ),
                  LayoutBuilderBox(key: Key('tall'), height: 300),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final Rect short = tester.getRect(find.byKey(const Key('short')));
    final Rect tall = tester.getRect(find.byKey(const Key('tall')));
    expect(short.height, 300);
    expect(tall.height, 300);
    expect(short.top, tall.top);
    // 1 : 2 columns with a 20px gap across 1000px.
    expect(short.width, closeTo(326.7, 0.1));
    expect(tall.left - short.right, closeTo(20, 0.01));
  });
}

class LayoutBuilderBox extends StatelessWidget {
  const LayoutBuilderBox({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints c) =>
        SizedBox(height: height),
  );
}
