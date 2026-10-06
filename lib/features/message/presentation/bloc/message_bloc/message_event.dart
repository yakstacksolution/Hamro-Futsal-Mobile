part of 'message_bloc.dart';

sealed class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

final class LoadConversationsEvent extends MessageEvent {
  const LoadConversationsEvent({
    this.silent = false,
    this.archived = false,
    this.loadMore = false,
    this.force = false,
  });
  final bool silent;
  final bool archived;
  final bool loadMore;

  final bool force;

  @override
  List<Object?> get props => [silent, archived, loadMore, force];
}

final class LoadChatEvent extends MessageEvent {
  const LoadChatEvent(this.conversationId, {this.conversation});
  final int conversationId;
  final ConversationModel? conversation;

  @override
  List<Object?> get props => [conversationId, conversation];
}

final class LoadOlderMessagesEvent extends MessageEvent {
  const LoadOlderMessagesEvent(this.conversationId);
  final int conversationId;

  @override
  List<Object?> get props => [conversationId];
}

final class CloseChatEvent extends MessageEvent {
  const CloseChatEvent({this.conversationId});

  final int? conversationId;

  @override
  List<Object?> get props => [conversationId];
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

final class UpdateGroupConversationEvent extends MessageEvent {
  const UpdateGroupConversationEvent(
    this.conversationId, {
    this.title,
    this.mediaId,
    this.imageUrl,
  });

  final int conversationId;

  final String? title;

  final int? mediaId;

  final String? imageUrl;

  @override
  List<Object?> get props => [conversationId, title, mediaId, imageUrl];
}

final class RespondToConversationInvitationEvent extends MessageEvent {
  const RespondToConversationInvitationEvent(
    this.conversationId, {
    required this.accept,
  });

  final int conversationId;
  final bool accept;

  @override
  List<Object?> get props => [conversationId, accept];
}

final class LeaveGroupConversationEvent extends MessageEvent {
  const LeaveGroupConversationEvent(this.conversationId);

  final int conversationId;

  @override
  List<Object?> get props => [conversationId];
}

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

final class LoadMessageProfileEvent extends MessageEvent {
  const LoadMessageProfileEvent(this.userId);
  final int userId;

  @override
  List<Object?> get props => [userId];
}

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

final class ChatMessageReceivedEvent extends MessageEvent {
  const ChatMessageReceivedEvent(this.message);
  final ChatMessageModel message;

  @override
  List<Object?> get props => [message];
}

final class PeerTypingChangedEvent extends MessageEvent {
  const PeerTypingChangedEvent(this.conversationId, this.isTyping);
  final int conversationId;
  final bool isTyping;

  @override
  List<Object?> get props => [conversationId, isTyping];
}

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
