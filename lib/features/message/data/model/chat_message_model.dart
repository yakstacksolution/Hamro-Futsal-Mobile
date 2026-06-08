/// One attachment of a message (`media[]` of MessageResource).
class ChatMediaModel {
  const ChatMediaModel({
    required this.id,
    required this.name,
    this.mimeType = '',
    this.size = 0,
    this.humanReadableSize = '',
    this.url = '',
  });

  final int id;
  final String name;
  final String mimeType;
  final int size;
  final String humanReadableSize;

  /// Relative API path (`/api/chat/media/{id}`) — requires the bearer token.
  final String url;

  bool get isImage => mimeType.startsWith('image/');

  factory ChatMediaModel.fromJson(Map<String, dynamic> json) =>
      ChatMediaModel(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        name: (json['name'] ?? json['file_name'] ?? '').toString(),
        mimeType: (json['mime_type'] ?? '').toString(),
        size: int.tryParse(json['size']?.toString() ?? '') ?? 0,
        humanReadableSize: (json['human_readable_size'] ?? '').toString(),
        url: (json['url'] ?? '').toString(),
      );
}

/// `MessageResource` from `GET /conversations/{id}/messages`.
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName = '',
    this.senderAvatar = '',
    this.type = 'text',
    this.body = '',
    this.status = 'sent',
    this.replyToMessageId,
    this.media = const [],
    this.isEdited = false,
    required this.createdAt,
  });

  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String senderAvatar;

  /// text | image | video | audio | file | mixed | location.
  final String type;
  final String body;

  /// sent | delivered | read.
  final String status;
  final int? replyToMessageId;
  final List<ChatMediaModel> media;
  final bool isEdited;
  final DateTime createdAt;

  bool isMine(int currentUserId) => senderId == currentUserId;

  bool get isRead => status == 'read';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawMedia = json['media'];
    return ChatMessageModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      conversationId:
          int.tryParse(json['conversation_id']?.toString() ?? '') ?? 0,
      senderId: int.tryParse(json['sender_id']?.toString() ?? '') ?? 0,
      senderName: (json['sender_name'] ?? '').toString(),
      senderAvatar: (json['sender_avatar'] ?? '').toString(),
      type: (json['type'] ?? 'text').toString(),
      body: (json['body'] ?? '').toString(),
      status: (json['status'] ?? 'sent').toString(),
      replyToMessageId: int.tryParse(
        json['reply_to_message_id']?.toString() ?? '',
      ),
      media: rawMedia is List
          ? rawMedia
                .whereType<Map>()
                .map(
                  (m) => ChatMediaModel.fromJson(Map<String, dynamic>.from(m)),
                )
                .toList(growable: false)
          : const [],
      isEdited: json['is_edited'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
