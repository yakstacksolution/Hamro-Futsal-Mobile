import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';

/// One row of the real `/api/conversations?archived=false` payload: a group
/// that has a picture, plus the direct rows that have none.
Map<String, dynamic> _groupJson() => <String, dynamic>{
  'id': 91,
  'type': 'group',
  'title': 'Neww',
  'image_id': 391,
  'image': <String, dynamic>{
    'id': 391,
    'name': 'camera_1786257511497906',
    'url': 'https://hamrofutsal.com//storage/users/20/library/391/c.jpg',
  },
  'status': 'active',
  'invitation_status': 'accepted',
  'can_accept_invitation': false,
  'can_decline_invitation': false,
  'unread_count': 0,
  'participants': const <Map<String, dynamic>>[
    {'id': 195, 'user_id': 20, 'name': 'We Futsal', 'role': 'vendor'},
    {'id': 196, 'user_id': 1031, 'name': 'Candidate 10', 'role': 'vendor'},
  ],
  'created_at': '2026-09-13 14:06:40',
};

Map<String, dynamic> _directJson() => <String, dynamic>{
  'id': 76,
  'type': 'direct',
  'title': null,
  'image_id': null,
  'image': null,
  'status': 'active',
  'invitation_status': 'accepted',
  'venue_id': 38,
  'venue': <String, dynamic>{'id': 38, 'name': 'UN park futsal'},
  'unread_count': 0,
  'participants': const <Map<String, dynamic>>[
    {
      'id': 162,
      'user_id': 4,
      'name': 'Dilli Bhandari',
      'role': 'vendor',
      'avatar': {'id': 403, 'url': 'https://hamrofutsal.com/a/403.jpg'},
    },
    {
      'id': 163,
      'user_id': 20,
      'name': 'We Futsal',
      'role': 'vendor',
      'avatar': {'id': 379, 'url': 'https://hamrofutsal.com/a/379.jpg'},
    },
  ],
  'created_at': '2026-09-08 21:18:42',
};

void main() {
  group('conversation list image', () {
    test('a group carries its picture and media id', () {
      final c = ConversationModel.fromJson(_groupJson());

      expect(
        c.imageUrl,
        'https://hamrofutsal.com//storage/users/20/library/391/c.jpg',
      );
      expect(c.imageId, 391);
    });

    test('the group picture is what the inbox row shows', () {
      final c = ConversationModel.fromJson(_groupJson());

      expect(c.displayAvatar(20), c.imageUrl);
    });

    test('a group without a picture falls back to the placeholder', () {
      final json = _groupJson()
        ..['image'] = null
        ..['image_id'] = null;

      final c = ConversationModel.fromJson(json);

      expect(c.imageUrl, '');
      expect(c.imageId, isNull);
      expect(c.displayAvatar(20), '');
    });

    test('a direct row still shows the other person', () {
      final c = ConversationModel.fromJson(_directJson());

      expect(c.displayAvatar(20), 'https://hamrofutsal.com/a/403.jpg');
      expect(c.imageId, isNull);
    });

    test('a new message does not drop the group picture', () {
      final c = ConversationModel.fromJson(_groupJson());

      final updated = c.withLatestMessage(
        ChatMessageModel(
          id: 999,
          conversationId: 91,
          senderId: 20,
          body: 'Hhh',
          createdAt: DateTime(2026, 9, 13, 14, 6, 50),
        ),
      );

      expect(updated.imageUrl, c.imageUrl);
      expect(updated.imageId, 391);
    });
  });
}
