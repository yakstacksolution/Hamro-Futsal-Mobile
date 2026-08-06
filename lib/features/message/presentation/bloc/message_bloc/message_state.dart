part of 'message_bloc.dart';

enum MessageStatus { initial, loading, success, failure }

final class MessageState extends Equatable {
  const MessageState({
    this.currentUserId = 0,
    this.conversationsStatus = MessageStatus.initial,
    this.conversations = const [],
    this.chatStatus = MessageStatus.initial,
    this.activeConversationId,
    this.activeConversation,
    this.messages = const [],
    this.sending = false,
    this.peerTyping = false,
    this.showingArchived = false,
    this.groupCreating = false,
    this.createdGroup,
    this.actionBusy = false,
    this.actionMessage,
    this.profileStatus = MessageStatus.initial,
    this.profile,
    this.profileErrorMessage,
    this.errorMessage,
  });

  /// Signed-in user's id — own messages render right-aligned.
  final int currentUserId;
  final MessageStatus conversationsStatus;
  final List<ConversationModel> conversations;

  /// Thread of the conversation currently open in [activeConversationId].
  final MessageStatus chatStatus;
  final int? activeConversationId;
  final ConversationModel? activeConversation;
  final List<ChatMessageModel> messages;
  final bool sending;

  /// True while the other side is typing (realtime).
  final bool peerTyping;
  final bool showingArchived;
  final bool groupCreating;
  final ConversationModel? createdGroup;
  final bool actionBusy;
  final String? actionMessage;

  /// Other user's view-only profile, shown in the profile bottom sheet.
  final MessageStatus profileStatus;
  final MessageProfileModel? profile;
  final String? profileErrorMessage;
  final String? errorMessage;

  int get unreadTotal => conversations.fold(0, (sum, c) => sum + c.unreadCount);

  MessageState copyWith({
    int? currentUserId,
    MessageStatus? conversationsStatus,
    List<ConversationModel>? conversations,
    MessageStatus? chatStatus,
    int? activeConversationId,
    ConversationModel? activeConversation,
    bool clearActiveConversation = false,
    List<ChatMessageModel>? messages,
    bool? sending,
    bool? peerTyping,
    bool? showingArchived,
    bool? groupCreating,
    ConversationModel? createdGroup,
    bool clearCreatedGroup = false,
    bool? actionBusy,
    String? actionMessage,
    bool clearActionMessage = false,
    MessageStatus? profileStatus,
    MessageProfileModel? profile,
    String? profileErrorMessage,
    bool clearProfile = false,
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
      activeConversation: clearActiveConversation
          ? null
          : activeConversation ?? this.activeConversation,
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      peerTyping: peerTyping ?? this.peerTyping,
      showingArchived: showingArchived ?? this.showingArchived,
      groupCreating: groupCreating ?? this.groupCreating,
      createdGroup: clearCreatedGroup
          ? null
          : createdGroup ?? this.createdGroup,
      actionBusy: actionBusy ?? this.actionBusy,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      // An explicit status wins, so a reload can clear the previous profile
      // and move to `loading` in the same emit.
      profileStatus:
          profileStatus ??
          (clearProfile ? MessageStatus.initial : this.profileStatus),
      profile: clearProfile ? null : profile ?? this.profile,
      profileErrorMessage: clearProfile
          ? null
          : profileErrorMessage ?? this.profileErrorMessage,
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
    activeConversation,
    messages,
    sending,
    peerTyping,
    showingArchived,
    groupCreating,
    createdGroup,
    actionBusy,
    actionMessage,
    profileStatus,
    profile,
    profileErrorMessage,
    errorMessage,
  ];
}
