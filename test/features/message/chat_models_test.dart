import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';
import 'package:hamro_futsal/features/message/data/model/chat_send_request.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_page_model.dart';

void main() {
  test('parses conversation items and dynamic pagination metadata', () {
    final page = ConversationPageModel.fromResponse(<String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{'id': 12, 'type': 'direct', 'unread_count': 0},
        ],
        'pagination': <String, dynamic>{
          'current_page': 2,
          'last_page': 4,
          'per_page': 15,
          'total': 52,
          'has_more_pages': true,
        },
      },
    });

    expect(page.items.single.id, 12);
    expect(page.currentPage, 2);
    expect(page.lastPage, 4);
    expect(page.perPage, 15);
    expect(page.total, 52);
    expect(page.hasMorePages, isTrue);
  });

  test('parses the documented conversation resource', () {
    final conversation = ConversationModel.fromJson({
      'id': 11,
      'type': 'group',
      'title': 'Team Coordination',
      'status': 'active',
      'venue_id': 3,
      'conversationable_type': 'team',
      'conversationable_id': 8,
      'unread_count': 2,
      'is_muted': true,
      'is_pinned': false,
      'is_archived': false,
      'participants': [
        {
          'id': 1,
          'user_id': 12,
          'name': 'Vendor Name',
          'role': 'vendor',
          'avatar': {'id': 5, 'url': 'https://example.com/avatar.jpg'},
          'joined_at': '2026-06-04 10:00:00',
          'is_blocked': true,
          'unread_count': 1,
        },
      ],
      'created_at': '2026-06-04 10:00:00',
    });

    expect(conversation.isGroup, isTrue);
    expect(conversation.conversationableId, 8);
    expect(conversation.participants.single.avatarUrl, contains('avatar.jpg'));
    expect(conversation.participants.single.isBlocked, isTrue);
  });

  test('parses reply, metadata, media, edit, and delete message fields', () {
    final message = ChatMessageModel.fromJson({
      'id': 55,
      'conversation_id': 10,
      'sender_id': 7,
      'type': 'mixed',
      'body': 'Hello',
      'metadata': {'latitude': 27.7},
      'reply_to_message_id': 54,
      'reply_to': {'id': 54, 'sender_id': 8, 'body': 'Earlier'},
      'media': [
        {
          'id': 90,
          'name': 'photo.jpg',
          'mime_type': 'image/jpeg',
          'url': '/api/chat/media/90',
          'custom_properties': {'width': 800},
        },
      ],
      'is_edited': true,
      'edited_at': '2026-06-04 10:18:00',
      'deleted_at': '2026-06-04 10:19:00',
      'created_at': '2026-06-04 10:16:00',
    });

    expect(message.replyTo?.id, 54);
    expect(message.media.single.isImage, isTrue);
    expect(message.media.single.customProperties['width'], 800);
    expect(message.isEdited, isTrue);
    expect(message.isDeleted, isTrue);
  });

  test('infers multipart message types', () {
    expect(const ChatSendRequest(body: 'Hi').resolvedType, 'text');
    expect(
      ChatSendRequest(
        attachments: <UploadAttachment>[
          UploadAttachment(
            filename: 'photo.jpg',
            bytes: Uint8List.fromList(<int>[1]),
          ),
        ],
      ).resolvedType,
      'image',
    );
    expect(
      ChatSendRequest(
        body: 'See this',
        attachments: <UploadAttachment>[
          UploadAttachment(
            filename: 'file.pdf',
            bytes: Uint8List.fromList(<int>[1]),
          ),
        ],
      ).resolvedType,
      'mixed',
    );
  });
}
