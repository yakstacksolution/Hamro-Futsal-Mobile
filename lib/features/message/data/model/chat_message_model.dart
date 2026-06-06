/// One bubble inside a conversation thread.
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.isMe,
    this.seen = false,
  });

  final String id;
  final String text;
  final DateTime sentAt;

  /// True when sent by the current user (right-aligned bubble).
  final bool isMe;

  /// Read receipt for own messages.
  final bool seen;
}
