part of 'message_bloc.dart';

enum MessageStatus { initial, loading, success, failure }

final class MessageState extends Equatable {
  const MessageState({
    this.currentUserId = 0,
    this.conversationsStatus = MessageStatus.initial,
    this.conversations = const [],
    this.chatStatus = MessageStatus.initial,
    this.activeConversationId,
    this.messages = const [],
    this.sending = false,
    this.peerTyping = false,
    this.errorMessage,
  });

  /// Signed-in user's id — own messages render right-aligned.
  final int currentUserId;
  final MessageStatus conversationsStatus;
  final List<ConversationModel> conversations;

  /// Thread of the conversation currently open in [activeConversationId].
  final MessageStatus chatStatus;
  final int? activeConversationId;
  final List<ChatMessageModel> messages;
  final bool sending;

  /// True while the other side is typing (realtime).
  final bool peerTyping;
  final String? errorMessage;

  int get unreadTotal =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  MessageState copyWith({
    int? currentUserId,
    MessageStatus? conversationsStatus,
    List<ConversationModel>? conversations,
    MessageStatus? chatStatus,
    int? activeConversationId,
    bool clearActiveConversation = false,
    List<ChatMessageModel>? messages,
    bool? sending,
    bool? peerTyping,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MessageState(
      currentUserId: currentUserId ?? this.currentUserId,
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversations: conversations ?? this.conversations,
      chatStatus: chatStatus ?? this.chatStatus,
      activeConversationId: clearActiveConversation
          ? null
          : activeConversationId ?? this.activeConversationId,
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      peerTyping: peerTyping ?? this.peerTyping,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentUserId,
    conversationsStatus,
    conversations,
    chatStatus,
    activeConversationId,
    messages,
    sending,
    peerTyping,
    errorMessage,
  ];
}
