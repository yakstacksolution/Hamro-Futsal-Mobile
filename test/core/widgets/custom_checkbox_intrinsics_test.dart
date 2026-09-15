import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/widgets/custom_checkbox.dart';

/// The checkbox decided its layout with a `LayoutBuilder`, which cannot answer
/// an intrinsic measurement. Any ancestor that asks for one — an
/// `IntrinsicHeight` row, `AlertDialog`'s `OverflowBar`, an `IntrinsicWidth` —
/// crashed with "LayoutBuilder does not support returning intrinsic
/// dimensions", and the half-finished layout then left the InkWell's ink box
/// unsized ("RenderBox was not laid out: _RenderInkFeatures").
Widget _checkbox({bool isExpanded = false}) => CustomCheckbox(
  value: true,
  isExpanded: isExpanded,
  label: 'I agree to the terms and conditions of Hamro Futsal',
  onChanged: (_) {},
);

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('lays out inside an IntrinsicHeight row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: _checkbox(isExpanded: true)),
              const VerticalDivider(width: 8),
              Expanded(child: _checkbox()),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomCheckbox), findsNWidgets(2));
  });

  testWidgets('lays out inside an IntrinsicWidth column', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_checkbox(), _checkbox(isExpanded: true)],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out as a dialog action, where OverflowBar measures it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        AlertDialog(
          content: const Text('Delete this booking?'),
          actions: <Widget>[_checkbox()],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  // The unbounded case the LayoutBuilder existed for: a flex child would throw
  // here if it were handed an infinite width.
  testWidgets('lays out under an unbounded width', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: <Widget>[_checkbox(), _checkbox()]),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomCheckbox), findsNWidgets(2));
  });

  testWidgets('still fills the row when expanded and bounded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(SizedBox(width: 400, child: _checkbox(isExpanded: true))),
    );

    expect(tester.takeException(), isNull);
    final Size size = tester.getSize(find.byType(CustomCheckbox));
    expect(size.width, 400);
  });

  testWidgets('taps still toggle', (WidgetTester tester) async {
    bool? toggled;
    await tester.pumpWidget(
      _host(
        CustomCheckbox(
          value: false,
          label: 'Remember me',
          onChanged: (bool? v) => toggled = v,
        ),
      ),
    );

    await tester.tap(find.text('Remember me'));
    expect(toggled, isTrue);
  });
}
