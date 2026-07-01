/// One attachment of a message (`media[]` of MessageResource).
class ChatMediaModel {
  const ChatMediaModel({
    required this.id,
    required this.name,
    this.mimeType = '',
    this.size = 0,
    this.humanReadableSize = '',
    this.url = '',
    this.customProperties = const <String, dynamic>{},
    this.createdAt,
  });

  final int id;
  final String name;
  final String mimeType;
  final int size;
  final String humanReadableSize;

  /// Relative API path (`/api/chat/media/{id}`) — requires the bearer token.
  final String url;
  final Map<String, dynamic> customProperties;
  final DateTime? createdAt;

  bool get isImage => mimeType.startsWith('image/');

  factory ChatMediaModel.fromJson(Map<String, dynamic> json) => ChatMediaModel(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    name: (json['name'] ?? json['file_name'] ?? '').toString(),
    mimeType: (json['mime_type'] ?? '').toString(),
    size: int.tryParse(json['size']?.toString() ?? '') ?? 0,
    humanReadableSize: (json['human_readable_size'] ?? '').toString(),
    url: (json['url'] ?? '').toString(),
    customProperties: json['custom_properties'] is Map
        ? Map<String, dynamic>.from(json['custom_properties'] as Map)
        : const <String, dynamic>{},
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
  );
}

final class ChatReplyModel {
  const ChatReplyModel({
    required this.id,
    this.senderId = 0,
    this.senderName = '',
    this.type = 'text',
    this.body = '',
    this.isDeleted = false,
  });

  final int id;
  final int senderId;
  final String senderName;
  final String type;
  final String body;
  final bool isDeleted;

  factory ChatReplyModel.fromJson(Map<String, dynamic> json) => ChatReplyModel(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    senderId: int.tryParse(json['sender_id']?.toString() ?? '') ?? 0,
    senderName: (json['sender_name'] ?? '').toString(),
    type: (json['type'] ?? 'text').toString(),
    body: (json['body'] ?? '').toString(),
    isDeleted: json['deleted_at'] != null,
  );
}

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
    this.replyTo,
    this.metadata = const <String, dynamic>{},
    this.media = const [],
    this.isEdited = false,
    this.editedAt,
    this.deletedAt,
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
  final ChatReplyModel? replyTo;
  final Object metadata;
  final List<ChatMediaModel> media;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;

  bool isMine(int currentUserId) => senderId == currentUserId;

  bool get isRead => status.toLowerCase() == 'read';
  bool get isDeleted => deletedAt != null;

  ChatMessageModel copyWith({String? status}) => ChatMessageModel(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    senderName: senderName,
    senderAvatar: senderAvatar,
    type: type,
    body: body,
    status: status ?? this.status,
    replyToMessageId: replyToMessageId,
    replyTo: replyTo,
    metadata: metadata,
    media: media,
    isEdited: isEdited,
    editedAt: editedAt,
    deletedAt: deletedAt,
    createdAt: createdAt,
  );

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
      replyTo: json['reply_to'] is Map
          ? ChatReplyModel.fromJson(
              Map<String, dynamic>.from(json['reply_to'] as Map),
            )
          : null,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : json['metadata'] is List
          ? List<Object?>.from(json['metadata'] as List)
          : const <String, dynamic>{},
      media: rawMedia is List
          ? rawMedia
                .whereType<Map>()
                .map(
                  (m) => ChatMediaModel.fromJson(Map<String, dynamic>.from(m)),
                )
                .toList(growable: false)
          : const [],
      isEdited: json['is_edited'] == true,
      editedAt: DateTime.tryParse(json['edited_at']?.toString() ?? ''),
      deletedAt: DateTime.tryParse(json['deleted_at']?.toString() ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
