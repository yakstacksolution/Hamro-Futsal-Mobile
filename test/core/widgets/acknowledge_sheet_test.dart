import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/widgets/acknowledge_sheet.dart';

/// The caller acts once this sheet returns, so a dismissal must not be able to
/// stand in for the user actually acknowledging it.
void main() {
  Future<bool> pumpSheet(WidgetTester tester) async {
    bool acknowledged = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  await showAcknowledgeSheet(
                    context: context,
                    title: 'Your booking is completed',
                    message: 'The court is held for your match.',
                    details: const <AcknowledgeLine>[
                      (icon: Icons.location_on_outlined, text: 'Star Futsal'),
                    ],
                  );
                  acknowledged = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return acknowledged;
  }

  testWidgets('a barrier tap does not close it', (tester) async {
    await pumpSheet(tester);
    expect(find.text('Your booking is completed'), findsOneWidget);

    // Well above the sheet: this is the modal barrier.
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();

    expect(find.text('Your booking is completed'), findsOneWidget);
  });

  testWidgets('a drag down does not close it', (tester) async {
    await pumpSheet(tester);

    await tester.drag(
      find.text('Your booking is completed'),
      const Offset(0, 400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your booking is completed'), findsOneWidget);
  });

  testWidgets('the button closes it and lets the caller continue', (
    tester,
  ) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Okay'));
    await tester.pumpAndSettle();

    expect(find.text('Your booking is completed'), findsNothing);
  });
}
