import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';
import 'package:hamro_futsal/features/message/domain/model/message_mentions.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/chat_bubble.dart';

void main() {
  ChatMessageModel message(String body) => ChatMessageModel(
    id: 1,
    conversationId: 2,
    senderId: 3,
    senderName: 'Ram',
    body: body,
    createdAt: DateTime(2026, 9, 16, 19),
  );

  Future<void> pump(
    WidgetTester tester,
    String body, {
    List<MentionCandidate> candidates = const <MentionCandidate>[],
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatBubble(
            message: message(body),
            isMe: false,
            showSender: true,
            mentionCandidates: candidates,
          ),
        ),
      ),
    );
  }

  /// The runs of the bubble's body that carry a tap recognizer.
  List<String> tappableRuns(WidgetTester tester) {
    final List<String> runs = <String>[];
    for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
      text.textSpan?.visitChildren((InlineSpan span) {
        if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
          runs.add(span.text ?? '');
        }
        return true;
      });
    }
    return runs;
  }

  testWidgets('a venue link shared in a chat is tappable', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      'Booked https://hamrofutsal.com/venues/un-park-futsal?venue=38 for 7pm',
    );

    expect(tappableRuns(tester), <String>[
      'https://hamrofutsal.com/venues/un-park-futsal?venue=38',
    ]);
  });

  testWidgets('a group message can carry a mention and a link at once', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      '@Ram see https://hamrofutsal.com/venues/goal-zone?venue=7',
      candidates: const <MentionCandidate>[
        MentionCandidate(userId: 3, name: 'Ram'),
      ],
    );

    expect(tappableRuns(tester), <String>[
      'https://hamrofutsal.com/venues/goal-zone?venue=7',
    ]);
    expect(find.textContaining('@Ram', findRichText: true), findsOneWidget);
  });

  testWidgets('a body with no link stays plain text', (
    WidgetTester tester,
  ) async {
    await pump(tester, 'see you at 7');

    expect(tappableRuns(tester), isEmpty);
  });

  testWidgets('a deleted message shows no link from its old body', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatBubble(
            message: ChatMessageModel(
              id: 1,
              conversationId: 2,
              senderId: 3,
              body: 'https://hamrofutsal.com/venues/un-park-futsal?venue=38',
              deletedAt: DateTime(2026, 9, 16),
              createdAt: DateTime(2026, 9, 16),
            ),
            isMe: false,
          ),
        ),
      ),
    );

    expect(tappableRuns(tester), isEmpty);
    expect(find.text('Message deleted'), findsOneWidget);
  });
}
