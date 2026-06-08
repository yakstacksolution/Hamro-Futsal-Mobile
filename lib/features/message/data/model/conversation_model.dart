import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';

/// Client-side filter chips on the conversations list.
enum ConversationFilter { all, unread, direct, group }

extension ConversationFilterX on ConversationFilter {
  String get label => switch (this) {
    ConversationFilter.all => 'All',
    ConversationFilter.unread => 'Unread',
    ConversationFilter.direct => 'Direct',
    ConversationFilter.group => 'Groups',
  };
}

/// One member of a conversation (`participants[]` of ConversationResource).
class ParticipantModel {
  const ParticipantModel({
    required this.id,
    required this.userId,
    required this.name,
    this.role = '',
    this.avatarUrl = '',
    this.isBlocked = false,
  });

  final int id;
  final int userId;
  final String name;
  final String role;
  final String avatarUrl;
  final bool isBlocked;

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final dynamic avatar = json['avatar'];
    return ParticipantModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      avatarUrl: avatar is Map ? (avatar['url'] ?? '').toString() : '',
      isBlocked: json['is_blocked'] == true,
    );
  }
}

/// `ConversationResource` from `GET /conversations`.
class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.type,
    this.title,
    this.status = '',
    this.venueId,
    this.lastMessage,
    this.lastMessageDetail,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.isArchived = false,
    this.participants = const [],
    this.createdAt,
  });

  final int id;

  /// `direct` | `group`.
  final String type;
  final String? title;
  final String status;
  final int? venueId;

  /// Preview text of the latest message (its body, or an attachment label).
  final String? lastMessage;

  /// The latest message in full — the API sends a nested MessageResource.
  final ChatMessageModel? lastMessageDetail;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final bool isArchived;
  final List<ParticipantModel> participants;
  final DateTime? createdAt;

  bool get isGroup => type == 'group';
  bool get isUnread => unreadCount > 0;

  /// The participant who isn't the signed-in user (direct chats).
  ParticipantModel? otherParticipant(int currentUserId) {
    for (final p in participants) {
      if (p.userId != currentUserId) return p;
    }
    return participants.isEmpty ? null : participants.first;
  }

  /// Group title, or the other side's name for direct chats.
  String displayTitle(int currentUserId) {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return otherParticipant(currentUserId)?.name ?? 'Conversation';
  }

  String displayAvatar(int currentUserId) =>
      isGroup ? '' : (otherParticipant(currentUserId)?.avatarUrl ?? '');

  /// Inbox preview line, prefixed with `You:` when the latest message was
  /// sent by the signed-in user.
  String preview(int currentUserId) {
    final text = lastMessage?.trim() ?? '';
    if (text.isEmpty) return 'No messages yet — say hello!';
    final mine = lastMessageDetail?.senderId == currentUserId;
    return mine ? 'You: $text' : text;
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawParticipants = json['participants'];

    // `last_message` arrives as a nested MessageResource (or null); tolerate
    // a plain string too.
    final dynamic rawLast = json['last_message'];
    ChatMessageModel? lastDetail;
    String? lastMessage;
    if (rawLast is Map) {
      lastDetail = ChatMessageModel.fromJson(
        Map<String, dynamic>.from(rawLast),
      );
      lastMessage = lastDetail.body.trim().isNotEmpty
          ? lastDetail.body.trim()
          : lastDetail.media.isNotEmpty
          ? '📎 ${lastDetail.media.first.name}'
          : null;
    } else {
      lastMessage = rawLast?.toString();
    }

    return ConversationModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: (json['type'] ?? 'direct').toString(),
      title: json['title']?.toString(),
      status: (json['status'] ?? '').toString(),
      venueId: int.tryParse(json['venue_id']?.toString() ?? ''),
      lastMessage: lastMessage,
      lastMessageDetail: lastDetail,
      lastMessageAt: DateTime.tryParse(
        json['last_message_at']?.toString() ?? '',
      ),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
      isMuted: json['is_muted'] == true,
      isPinned: json['is_pinned'] == true,
      isArchived: json['is_archived'] == true,
      participants: rawParticipants is List
          ? rawParticipants
                .whereType<Map>()
                .map(
                  (p) =>
                      ParticipantModel.fromJson(Map<String, dynamic>.from(p)),
                )
                .toList(growable: false)
          : const [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  ConversationModel copyWith({int? unreadCount}) => ConversationModel(
    id: id,
    type: type,
    title: title,
    status: status,
    venueId: venueId,
    lastMessage: lastMessage,
    lastMessageDetail: lastMessageDetail,
    lastMessageAt: lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
    isMuted: isMuted,
    isPinned: isPinned,
    isArchived: isArchived,
    participants: participants,
    createdAt: createdAt,
  );
}
