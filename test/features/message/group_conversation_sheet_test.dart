import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/group_conversation_sheet.dart';

void main() {
  testWidgets('creates a group from the redesigned bottom sheet', (
    tester,
  ) async {
    GroupConversationDraft? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showGroupConversationSheet(
                    context: context,
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
    expect(find.text('Create a new group'), findsOneWidget);
    expect(find.text('No participants selected yet'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Weekend Team');
    await tester.tap(find.text('Ram'));
    await tester.pump();
    expect(find.text('1 participant selected'), findsOneWidget);

    await tester.tap(find.text('Create group with 1'));
    await tester.pumpAndSettle();

    expect(result?.title, 'Weekend Team');
    expect(result?.participantIds, [9]);
  });
}
