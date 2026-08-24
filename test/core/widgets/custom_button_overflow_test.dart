import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

/// A button narrower than its label must shrink the label, not overflow — the
/// two-button confirm dialog gives each side about half the dialog width.
void main() {
  testWidgets('a long label fits a narrow button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 140,
              child: CustomButton(
                text: 'Select This Opponent',
                icon: Icons.handshake_outlined,
                onPressed: null,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('an unbounded width does not bring the subtree down', (
    tester,
  ) async {
    // A button placed straight into a Row (no Expanded) is offered unbounded
    // width. Filling it with double.infinity is an invalid constraint, and the
    // failure surfaced far away — as a null-check crash painting the ListView.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              Row(
                children: const <Widget>[
                  Expanded(
                    child: Text('a long line that eats most of the row'),
                  ),
                  SizedBox(
                    height: 36,
                    child: CustomButton(
                      text: 'Chat',
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Chat'), findsOneWidget);
  });

  testWidgets('side-by-side buttons fit their labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(text: 'Cancel', onPressed: null),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Confirm opponent',
                      onPressed: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
