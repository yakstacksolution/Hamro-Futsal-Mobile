import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';
import 'package:hamro_futsal/features/message/domain/model/message_mentions.dart';

void main() {
  const List<MentionCandidate> people = <MentionCandidate>[
    MentionCandidate(userId: 5, name: 'Ram'),
    MentionCandidate(userId: 4, name: 'Dilli Bhandari'),
    MentionCandidate(userId: 20, name: 'We Futsal'),
  ];

  group('resolving a body', () {
    test('one name resolves to one id', () {
      final ResolvedMentions result = resolveMentions('Hello @Ram', people);

      expect(result.userIds, <int>[5]);
      expect(result.mentionAll, isFalse);
    });

    test('@all sets the flag and names nobody', () {
      final ResolvedMentions result = resolveMentions('Hello @all', people);

      expect(result.userIds, isEmpty);
      expect(result.mentionAll, isTrue);
    });

    test('a name with a space is matched whole', () {
      final ResolvedMentions result = resolveMentions(
        'ping @Dilli Bhandari please',
        people,
      );

      expect(result.userIds, <int>[4]);
    });

    test('the longest matching name wins', () {
      const List<MentionCandidate> overlapping = <MentionCandidate>[
        MentionCandidate(userId: 1, name: 'Dilli'),
        MentionCandidate(userId: 4, name: 'Dilli Bhandari'),
      ];

      expect(resolveMentions('@Dilli Bhandari hi', overlapping).userIds, <int>[
        4,
      ]);
      expect(resolveMentions('@Dilli hi', overlapping).userIds, <int>[1]);
    });

    test('several mentions keep their order and never repeat', () {
      final ResolvedMentions result = resolveMentions(
        '@Ram and @We Futsal and @Ram again',
        people,
      );

      expect(result.userIds, <int>[5, 20]);
    });

    test('@name and @all can both appear', () {
      final ResolvedMentions result = resolveMentions('@all plus @Ram', people);

      expect(result.userIds, <int>[5]);
      expect(result.mentionAll, isTrue);
    });

    test('a partial name is not a mention', () {
      expect(resolveMentions('@Rama is here', people).isEmpty, isTrue);
      expect(resolveMentions('@Ra', people).isEmpty, isTrue);
    });

    test('an email address is not a mention', () {
      expect(
        resolveMentions('write to ram@Ram.com', people).isEmpty,
        isTrue,
        reason: 'the @ must open a word',
      );
    });

    test('an unknown name resolves to nothing', () {
      expect(resolveMentions('@Nobody hello', people).isEmpty, isTrue);
    });

    test('matching ignores case', () {
      expect(resolveMentions('hi @ram', people).userIds, <int>[5]);
      expect(resolveMentions('hi @ALL', people).mentionAll, isTrue);
    });

    test('a direct chat has no candidates, so @ is just text', () {
      expect(
        resolveMentions('@Ram @all', const <MentionCandidate>[]).isEmpty,
        isTrue,
      );
    });
  });

  group('highlighting', () {
    test('spans cover exactly the mention text', () {
      final List<MentionSpan> spans = findMentionSpans('Hi @Ram!', people);

      expect(spans, hasLength(1));
      expect(spans.single.text, '@Ram');
      expect(
        'Hi @Ram!'.substring(spans.single.start, spans.single.end),
        '@Ram',
      );
    });
  });

  group('the composer picker', () {
    test('a query opens at the @ and grows with the name', () {
      expect(activeMentionQuery('Hello @', 7)?.query, '');
      expect(activeMentionQuery('Hello @Ra', 9)?.query, 'Ra');
      expect(activeMentionQuery('Hello @Dilli Bh', 15)?.query, 'Dilli Bh');
      expect(activeMentionQuery('Hello @Ram', 10)?.start, 6);
    });

    test('there is no query without an @, or across a newline', () {
      expect(activeMentionQuery('Hello there', 11), isNull);
      expect(activeMentionQuery('@Ram\nhello', 10), isNull);
    });

    test('an email does not open a query', () {
      expect(activeMentionQuery('ram@example', 11), isNull);
    });

    test('picking a name replaces the query and leaves a trailing space', () {
      final ({String text, int caret}) result = insertMention(
        text: 'Hello @Ra there',
        start: 6,
        caret: 9,
        handle: 'Ram',
      );

      expect(result.text, 'Hello @Ram  there');
      expect(result.caret, 11);
      expect(resolveMentions(result.text, people).userIds, <int>[5]);
    });
  });

  group('reading a message back', () {
    ChatMessageModel parse(Map<String, dynamic> json) =>
        ChatMessageModel.fromJson(<String, dynamic>{
          'id': 1,
          'conversation_id': 91,
          'sender_id': 20,
          'body': 'Hello',
          'created_at': '2026-09-13 14:06:50',
          ...json,
        });

    test('mentions, mention_all and is_mentioned are read', () {
      final ChatMessageModel message = parse(<String, dynamic>{
        'mentions': <int>[5, 4],
        'mention_all': false,
        'is_mentioned': true,
      });

      expect(message.mentions, <int>[5, 4]);
      expect(message.mentionAll, isFalse);
      expect(message.isMentioned, isTrue);
      expect(message.mentionsUser(5), isTrue);
    });

    test('mentions sent as objects are read by user id', () {
      final ChatMessageModel message = parse(<String, dynamic>{
        'mentions': <Map<String, dynamic>>[
          <String, dynamic>{'user_id': 5, 'name': 'Ram'},
        ],
      });

      expect(message.mentions, <int>[5]);
    });

    test('@all counts as mentioning everyone', () {
      final ChatMessageModel message = parse(<String, dynamic>{
        'mention_all': true,
        'mentions': <int>[],
        'is_mentioned': false,
      });

      expect(message.mentionsUser(999), isTrue);
    });

    test('a message naming someone else does not name me', () {
      final ChatMessageModel message = parse(<String, dynamic>{
        'mentions': <int>[5],
        'mention_all': false,
        'is_mentioned': false,
      });

      expect(message.mentionsUser(4), isFalse);
    });
  });
}
