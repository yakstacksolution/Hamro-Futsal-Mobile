import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';

/// Client-side filter chips on the conversations list.
enum ConversationFilter { all, unread, direct, group, archived }

extension ConversationFilterX on ConversationFilter {
  String get label => switch (this) {
    ConversationFilter.all => 'All',
    ConversationFilter.unread => 'Unread',
    ConversationFilter.direct => 'Direct',
    ConversationFilter.group => 'Groups',
    ConversationFilter.archived => 'Archived',
  };
}

/// One member of a conversation (`participants[]` of ConversationResource).
class ParticipantModel {
  const ParticipantModel({
    required this.id,
    required this.userId,
    required this.name,
    String? email,
    this.role = '',
    this.invitationStatus = '',
    this.invitedAt,
    this.respondedAt,
    this.avatarId,
    this.avatarUrl = '',
    this.isBlocked = false,
    this.isOnline = false,
    this.lastSeenAt,
    this.joinedAt,
    this.leftAt,
    this.isMuted = false,
    this.isPinned = false,
    this.isArchived = false,
    this.unreadCount = 0,
  }) : _email = email;

  final int id;
  final int userId;
  final String name;
  final String? _email;
  String get email => _email ?? '';
  final String role;

  /// Where this member stands on their invitation: `accepted`, `pending`, or
  /// `declined`. Empty when the server does not report one.
  final String invitationStatus;
  final DateTime? invitedAt;
  final DateTime? respondedAt;

  /// Still waiting on this member to answer their group invitation.
  bool get isInvitePending => invitationStatus.toLowerCase() == 'pending';

  /// Media library id behind [avatarUrl] (`avatar.id`), null when unset.
  final int? avatarId;
  final String avatarUrl;
  final bool isBlocked;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final bool isMuted;
  final bool isPinned;
  final bool isArchived;
  final int unreadCount;

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final dynamic avatar = json['avatar'];
    return ParticipantModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? json['user']?['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      invitationStatus: (json['invitation_status'] ?? '').toString(),
      invitedAt: DateTime.tryParse(json['invited_at']?.toString() ?? ''),
      respondedAt: DateTime.tryParse(json['responded_at']?.toString() ?? ''),
      avatarId: avatar is Map
          ? int.tryParse(avatar['id']?.toString() ?? '')
          : null,
      // `avatar` is an object (`{id, url}`) or null; tolerate a bare url too.
      avatarUrl: avatar is Map
          ? (avatar['url'] ?? '').toString()
          : (avatar ?? '').toString(),
      isBlocked: _asBool(json['is_blocked']),
      isOnline: _asBool(json['is_online']),
      lastSeenAt: DateTime.tryParse(json['last_seen_at']?.toString() ?? ''),
      joinedAt: DateTime.tryParse(json['joined_at']?.toString() ?? ''),
      leftAt: DateTime.tryParse(json['left_at']?.toString() ?? ''),
      isMuted: _asBool(json['is_muted']),
      isPinned: _asBool(json['is_pinned']),
      isArchived: _asBool(json['is_archived']),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
    );
  }

  ParticipantModel copyWith({
    bool? isBlocked,
    bool? isOnline,
    DateTime? lastSeenAt,
  }) => ParticipantModel(
    id: id,
    userId: userId,
    name: name,
    email: email,
    role: role,
    invitationStatus: invitationStatus,
    invitedAt: invitedAt,
    respondedAt: respondedAt,
    avatarId: avatarId,
    avatarUrl: avatarUrl,
    isBlocked: isBlocked ?? this.isBlocked,
    isOnline: isOnline ?? this.isOnline,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    joinedAt: joinedAt,
    leftAt: leftAt,
    isMuted: isMuted,
    isPinned: isPinned,
    isArchived: isArchived,
    unreadCount: unreadCount,
  );
}

class ConversationVenueModel {
  const ConversationVenueModel({required this.id, required this.name});

  final int id;
  final String name;

  factory ConversationVenueModel.fromJson(Map<String, dynamic> json) =>
      ConversationVenueModel(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        name: (json['name'] ?? '').toString(),
      );
}

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.type,
    this.title,
    this.status = '',
    this.invitationStatus = '',
    this.canAcceptInvitation = false,
    this.canDeclineInvitation = false,
    this.venueId,
    this.venue,
    this.conversationableType,
    this.conversationableId,
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

  final String type;
  final String? title;
  final String status;

  /// The signed-in user's own standing in this conversation: `accepted`,
  /// `pending` or `declined`. A group someone added them to arrives `pending`
  /// and must be answered before the thread opens.
  final String invitationStatus;
  final bool canAcceptInvitation;
  final bool canDeclineInvitation;
  final int? venueId;
  final ConversationVenueModel? venue;
  final String? conversationableType;
  final int? conversationableId;

  final String? lastMessage;

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

  /// An invitation this user has not answered yet. The server's two `can_*`
  /// flags are the authority — the status alone can read `pending` on a row
  /// the user is not the one being asked about.
  bool get isInvitePending =>
      invitationStatus.toLowerCase() == 'pending' &&
      (canAcceptInvitation || canDeclineInvitation);

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

  bool isPeerOnline(int currentUserId) =>
      !isGroup && (otherParticipant(currentUserId)?.isOnline ?? false);

  DateTime? peerLastSeenAt(int currentUserId) =>
      isGroup ? null : otherParticipant(currentUserId)?.lastSeenAt;

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
      invitationStatus: (json['invitation_status'] ?? '').toString(),
      canAcceptInvitation: _asBool(json['can_accept_invitation']),
      canDeclineInvitation: _asBool(json['can_decline_invitation']),
      venueId: int.tryParse(json['venue_id']?.toString() ?? ''),
      venue: json['venue'] is Map
          ? ConversationVenueModel.fromJson(
              Map<String, dynamic>.from(json['venue'] as Map),
            )
          : null,
      conversationableType: json['conversationable_type']?.toString(),
      conversationableId: int.tryParse(
        json['conversationable_id']?.toString() ?? '',
      ),
      lastMessage: lastMessage,
      lastMessageDetail: lastDetail,
      lastMessageAt: DateTime.tryParse(
        json['last_message_at']?.toString() ?? '',
      ),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
      isMuted: _asBool(json['is_muted']),
      isPinned: _asBool(json['is_pinned']),
      isArchived: _asBool(json['is_archived']),
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

  ConversationModel copyWith({
    String? title,
    String? invitationStatus,
    bool? canAcceptInvitation,
    bool? canDeclineInvitation,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
    bool? isArchived,
    List<ParticipantModel>? participants,
  }) => ConversationModel(
    id: id,
    type: type,
    title: title ?? this.title,
    status: status,
    invitationStatus: invitationStatus ?? this.invitationStatus,
    canAcceptInvitation: canAcceptInvitation ?? this.canAcceptInvitation,
    canDeclineInvitation: canDeclineInvitation ?? this.canDeclineInvitation,
    venueId: venueId,
    venue: venue,
    conversationableType: conversationableType,
    conversationableId: conversationableId,
    lastMessage: lastMessage,
    lastMessageDetail: lastMessageDetail,
    lastMessageAt: lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
    isMuted: isMuted ?? this.isMuted,
    isPinned: isPinned ?? this.isPinned,
    isArchived: isArchived ?? this.isArchived,
    participants: participants ?? this.participants,
    createdAt: createdAt,
  );

  /// Returns a copy with [message] as the conversation's latest message —
  /// refreshing the inbox preview line, the full detail and the timestamp.
  /// Pass [incrementUnread] for messages from the other side that arrive while
  /// the thread isn't open. The `You:` prefix is derived later from
  /// [lastMessageDetail]'s sender, so this works for messages from either side.
  ConversationModel withLatestMessage(
    ChatMessageModel message, {
    bool incrementUnread = false,
  }) {
    final body = message.body.trim();
    final preview = body.isNotEmpty
        ? body
        : message.media.isNotEmpty
        ? '📎 ${message.media.first.name}'
        : lastMessage;

    return ConversationModel(
      id: id,
      type: type,
      title: title,
      status: status,
      invitationStatus: invitationStatus,
      canAcceptInvitation: canAcceptInvitation,
      canDeclineInvitation: canDeclineInvitation,
      venueId: venueId,
      venue: venue,
      conversationableType: conversationableType,
      conversationableId: conversationableId,
      lastMessage: preview,
      lastMessageDetail: message,
      lastMessageAt: message.createdAt,
      unreadCount: incrementUnread ? unreadCount + 1 : unreadCount,
      isMuted: isMuted,
      isPinned: isPinned,
      isArchived: isArchived,
      participants: participants,
      createdAt: createdAt,
    );
  }
}

bool _asBool(dynamic value) =>
    value == true ||
    value == 1 ||
    value?.toString().toLowerCase() == 'true' ||
    value?.toString() == '1';
