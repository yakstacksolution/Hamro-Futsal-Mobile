part of 'message_bloc.dart';

sealed class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the conversations list. [silent] refreshes in the background.
final class LoadConversationsEvent extends MessageEvent {
  const LoadConversationsEvent({this.silent = false});
  final bool silent;

  @override
  List<Object?> get props => [silent];
}

/// Opens a conversation: loads its messages and subscribes to its
/// realtime streams.
final class LoadChatEvent extends MessageEvent {
  const LoadChatEvent(this.conversationId);
  final int conversationId;

  @override
  List<Object?> get props => [conversationId];
}

/// Leaves the active conversation (cancels realtime subscriptions).
final class CloseChatEvent extends MessageEvent {
  const CloseChatEvent();
}

final class SendMessageEvent extends MessageEvent {
  const SendMessageEvent(this.conversationId, this.body);
  final int conversationId;
  final String body;

  @override
  List<Object?> get props => [conversationId, body];
}

/// A realtime message arrived over the socket.
final class ChatMessageReceivedEvent extends MessageEvent {
  const ChatMessageReceivedEvent(this.message);
  final ChatMessageModel message;

  @override
  List<Object?> get props => [message];
}

/// The other side started/stopped typing (socket).
final class PeerTypingChangedEvent extends MessageEvent {
  const PeerTypingChangedEvent(this.isTyping);
  final bool isTyping;

  @override
  List<Object?> get props => [isTyping];
}

/// Broadcasts the signed-in user's typing state.
final class SendTypingEvent extends MessageEvent {
  const SendTypingEvent(this.conversationId, this.typing);
  final int conversationId;
  final bool typing;

  @override
  List<Object?> get props => [conversationId, typing];
}

final class MarkConversationReadEvent extends MessageEvent {
  const MarkConversationReadEvent(this.conversationId);
  final int conversationId;

  @override
  List<Object?> get props => [conversationId];
}
