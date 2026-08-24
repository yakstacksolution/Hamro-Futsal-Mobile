part of 'message_bloc.dart';

sealed class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the conversations list. [silent] refreshes in the background.
final class LoadConversationsEvent extends MessageEvent {
  const LoadConversationsEvent({
    this.silent = false,
    this.archived = false,
    this.loadMore = false,
  });
  final bool silent;
  final bool archived;
  final bool loadMore;

  @override
  List<Object?> get props => [silent, archived, loadMore];
}

/// Opens a conversation: loads its messages and subscribes to its
/// realtime streams.
final class LoadChatEvent extends MessageEvent {
  const LoadChatEvent(this.conversationId, {this.conversation});
  final int conversationId;
  final ConversationModel? conversation;

  @override
  List<Object?> get props => [conversationId, conversation];
}

/// Fetches the next page of older messages for the open conversation and
/// prepends it above what is already rendered (top-of-thread pagination).
final class LoadOlderMessagesEvent extends MessageEvent {
  const LoadOlderMessagesEvent(this.conversationId);
  final int conversationId;

  @override
  List<Object?> get props => [conversationId];
}

/// Leaves the active conversation (cancels realtime subscriptions).
final class CloseChatEvent extends MessageEvent {
  const CloseChatEvent();
}

final class SendMessageEvent extends MessageEvent {
  const SendMessageEvent(this.conversationId, this.request);
  final int conversationId;
  final ChatSendRequest request;

  @override
  List<Object?> get props => [conversationId, request];
}

final class CreateGroupConversationEvent extends MessageEvent {
  const CreateGroupConversationEvent({
    required this.title,
    required this.participantIds,
    this.venueId,
  });

  final String title;
  final List<int> participantIds;
  final int? venueId;

  @override
  List<Object?> get props => [title, participantIds, venueId];
}

final class ClearCreatedGroupEvent extends MessageEvent {
  const ClearCreatedGroupEvent();
}

/// Renames a group.
final class RenameGroupConversationEvent extends MessageEvent {
  const RenameGroupConversationEvent(this.conversationId, this.title);

  final int conversationId;
  final String title;

  @override
  List<Object?> get props => [conversationId, title];
}

/// Leaves a group. The conversation stays for its other members; it drops off
/// this user's inbox.
final class LeaveGroupConversationEvent extends MessageEvent {
  const LeaveGroupConversationEvent(this.conversationId);

  final int conversationId;

  @override
  List<Object?> get props => [conversationId];
}

/// Clears [MessageState.leftConversationId] once the UI has acted on it.
final class ClearLeftConversationEvent extends MessageEvent {
  const ClearLeftConversationEvent();
}

final class AddGroupMembersEvent extends MessageEvent {
  const AddGroupMembersEvent(this.conversationId, this.participantIds);
  final int conversationId;
  final List<int> participantIds;

  @override
  List<Object?> get props => [conversationId, participantIds];
}

/// Loads the view-only profile of another user for the profile sheet.
final class LoadMessageProfileEvent extends MessageEvent {
  const LoadMessageProfileEvent(this.userId);
  final int userId;

  @override
  List<Object?> get props => [userId];
}

/// Drops the loaded profile when the sheet closes.
final class ClearMessageProfileEvent extends MessageEvent {
  const ClearMessageProfileEvent();
}

final class SetConversationArchivedEvent extends MessageEvent {
  const SetConversationArchivedEvent(this.conversationId, this.archived);
  final int conversationId;
  final bool archived;

  @override
  List<Object?> get props => [conversationId, archived];
}

final class SetConversationMutedEvent extends MessageEvent {
  const SetConversationMutedEvent(this.conversationId, this.muted);
  final int conversationId;
  final bool muted;

  @override
  List<Object?> get props => [conversationId, muted];
}

final class SetParticipantBlockedEvent extends MessageEvent {
  const SetParticipantBlockedEvent({
    required this.conversationId,
    required this.userId,
    required this.blocked,
    this.reason,
  });

  final int conversationId;
  final int userId;
  final bool blocked;
  final String? reason;

  @override
  List<Object?> get props => [conversationId, userId, blocked, reason];
}

final class DeleteMessageEvent extends MessageEvent {
  const DeleteMessageEvent(this.messageId);
  final int messageId;

  @override
  List<Object?> get props => [messageId];
}

final class ClearMessageActionEvent extends MessageEvent {
  const ClearMessageActionEvent();
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
  const PeerTypingChangedEvent(this.conversationId, this.isTyping);
  final int conversationId;
  final bool isTyping;

  @override
  List<Object?> get props => [conversationId, isTyping];
}

/// The other participant read one or more messages (socket).
final class MessagesReadEvent extends MessageEvent {
  const MessagesReadEvent(this.receipt);
  final ChatReadReceipt receipt;

  @override
  List<Object?> get props => [
    receipt.conversationId,
    receipt.readerId,
    receipt.messageIds,
  ];
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
