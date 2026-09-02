import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/presentation/pages/create_group_conversation_page.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_member_widgets.dart';

void main() {
  testWidgets('creates a group from the create-group page', (tester) async {
    GroupConversationDraft? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  result = await CreateGroupConversationPage.open(
                    context,
                    currentUserId: 4,
                    participants: const [
                      ParticipantModel(id: 1, userId: 9, name: 'Ram'),
                    ],
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
    expect(find.text('Create Group'), findsOneWidget);
    expect(find.text('Add members'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Weekend Team');
    await tester.tap(find.text('Ram'));
    await tester.pumpAndSettle();

    // The header switches to the running count once someone is picked.
    expect(find.text('1 of 50 selected'), findsOneWidget);

    await tester.tap(find.text('Create group · 1'));
    await tester.pumpAndSettle();

    expect(result?.title, 'Weekend Team');
    expect(result?.participantIds, [9]);
  });

  testWidgets('an incomplete form says what is missing instead of doing '
      'nothing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => CreateGroupConversationPage.open(
                  context,
                  currentUserId: 4,
                  participants: const [
                    ParticipantModel(id: 1, userId: 9, name: 'Ram'),
                  ],
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

    // No name, nobody selected: the button is live and reports the first
    // thing that is missing.
    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a group name.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Weekend Team');
    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();
    expect(find.text('Select at least one member.'), findsOneWidget);
  });
}
