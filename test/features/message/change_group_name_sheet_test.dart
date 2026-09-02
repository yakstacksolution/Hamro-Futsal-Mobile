import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/presentation/pages/group_profile_page.dart';

void main() {
  // Semantics on: the sheet replaced an AlertDialog whose actions tripped the
  // framework's `!semantics.parentDataDirty` assertion, which only fires while
  // a semantics tree is being compiled.
  testWidgets('renaming a group returns the new name', (tester) async {
    final handle = tester.ensureSemantics();
    String? result = 'unset';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showChangeGroupNameDialog(
                    context: context,
                    currentTitle: 'Weekend Team',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Change group name'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Team Strategy Room');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'Team Strategy Room');
    handle.dispose();
  });

  testWidgets('an unchanged name asks for nothing', (tester) async {
    final handle = tester.ensureSemantics();
    String? result = 'unset';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showChangeGroupNameDialog(
                    context: context,
                    currentTitle: 'Weekend Team',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNull);

    handle.dispose();
  });

  testWidgets('an empty name is refused in place', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showChangeGroupNameDialog(
                  context: context,
                  currentTitle: 'Weekend Team',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a group name.'), findsOneWidget);
    expect(find.text('Change group name'), findsOneWidget);
    handle.dispose();
  });
}
