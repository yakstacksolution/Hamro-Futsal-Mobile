import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/widgets/confirm_word_sheet.dart';

/// The confirm button is the only way to say yes, and it must stay shut until
/// the exact word is typed — that gate is the whole point of the sheet.
void main() {
  Future<bool?> openSheet(WidgetTester tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  result = await showConfirmWordSheet(
                    context: context,
                    title: 'Delete your account?',
                    message: 'This cannot be undone.',
                    confirmationWord: 'DELETE',
                    confirmText: 'Delete Account',
                  );
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
    return result;
  }

  testWidgets('confirm does nothing until the word matches', (tester) async {
    await openSheet(tester);

    // Nothing typed yet: the button is inert and the sheet stays up.
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Account'), findsOneWidget);

    // A near miss is still a miss.
    await tester.enterText(find.byType(TextFormField), 'DELET');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Account'), findsOneWidget);
  });

  testWidgets('typing the word confirms', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField), 'DELETE');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Account'), findsNothing);
  });

  testWidgets('cancel returns without confirming', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField), 'DELETE');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Account'), findsNothing);
  });
}
