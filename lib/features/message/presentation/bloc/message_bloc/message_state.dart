part of 'message_bloc.dart';

enum MessageStatus { initial, loading, success, failure }

final class MessageState extends Equatable {
  const MessageState({
    this.currentUserId = 0,
    this.conversationsStatus = MessageStatus.initial,
    this.conversations = const [],
    this.conversationsCurrentPage = 0,
    this.conversationsLastPage = 1,
    this.conversationsTotal = 0,
    this.conversationsHasMorePages = false,
    this.conversationsLoadingMore = false,
    this.conversationsLoadMoreError,
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
    int? conversationsRefreshTick,
  }) : _conversationsRefreshTick = conversationsRefreshTick;

  /// Signed-in user's id — own messages render right-aligned.
  final int currentUserId;
  final MessageStatus conversationsStatus;
  final List<ConversationModel> conversations;
  final int conversationsCurrentPage;
  final int conversationsLastPage;
  final int conversationsTotal;
  final bool conversationsHasMorePages;
  final bool conversationsLoadingMore;
  final String? conversationsLoadMoreError;

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

  /// Increments whenever a conversation fetch finishes, including failures.
  /// This lets pull-to-refresh wait for the actual request to complete.
  final int? _conversationsRefreshTick;

  // A running app may still hold MessageState instances created before this
  // field was introduced by hot reload. Treat their injected null as zero.
  int get conversationsRefreshTick => _conversationsRefreshTick ?? 0;

  int get unreadTotal => conversations.fold(0, (sum, c) => sum + c.unreadCount);

  MessageState copyWith({
    int? currentUserId,
    MessageStatus? conversationsStatus,
    List<ConversationModel>? conversations,
    int? conversationsCurrentPage,
    int? conversationsLastPage,
    int? conversationsTotal,
    bool? conversationsHasMorePages,
    bool? conversationsLoadingMore,
    String? conversationsLoadMoreError,
    bool clearConversationsLoadMoreError = false,
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
    int? conversationsRefreshTick,
  }) {
    return MessageState(
      currentUserId: currentUserId ?? this.currentUserId,
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversations: conversations ?? this.conversations,
      conversationsCurrentPage:
          conversationsCurrentPage ?? this.conversationsCurrentPage,
      conversationsLastPage:
          conversationsLastPage ?? this.conversationsLastPage,
      conversationsTotal: conversationsTotal ?? this.conversationsTotal,
      conversationsHasMorePages:
          conversationsHasMorePages ?? this.conversationsHasMorePages,
      conversationsLoadingMore:
          conversationsLoadingMore ?? this.conversationsLoadingMore,
      conversationsLoadMoreError: clearConversationsLoadMoreError
          ? null
          : conversationsLoadMoreError ?? this.conversationsLoadMoreError,
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
      conversationsRefreshTick:
          conversationsRefreshTick ?? this.conversationsRefreshTick,
    );
  }

  @override
  List<Object?> get props => [
    currentUserId,
    conversationsStatus,
    conversations,
    conversationsCurrentPage,
    conversationsLastPage,
    conversationsTotal,
    conversationsHasMorePages,
    conversationsLoadingMore,
    conversationsLoadMoreError,
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
    conversationsRefreshTick,
  ];
}
