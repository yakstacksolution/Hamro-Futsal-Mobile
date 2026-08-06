import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/top_snack_bar.dart';

void main() {
  testWidgets('long snackbar messages fit in two lines without overflowing', (
    WidgetTester tester,
  ) async {
    const String message =
        'This is a deliberately long message that must remain inside the '
        'available snackbar width and stop cleanly after two readable lines.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 280,
              child: CustomSnackBar.error(message: message),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    final Text messageText = tester.widget<Text>(find.text(message));
    expect(messageText.maxLines, 2);
    expect(messageText.softWrap, isTrue);
    expect(messageText.overflow, TextOverflow.ellipsis);
  });
}
