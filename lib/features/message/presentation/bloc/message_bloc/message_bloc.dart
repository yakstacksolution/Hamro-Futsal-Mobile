import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/data/service/chat_socket_service.dart';
import 'package:hamro_footsall/features/message/domain/usecase/message_usecase.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc(this.useCase, {ChatSocketService? socketService})
    : _socket = socketService ?? NoopChatSocketService(),
      // currentUserId is resolved once from the access token.
      super(MessageState(currentUserId: useCase.currentUserId)) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadChatEvent>(_onLoadChat);
    on<CloseChatEvent>(_onCloseChat);
    on<SendMessageEvent>(_onSendMessage);
    on<CreateGroupConversationEvent>(_onCreateGroup);
    on<AddGroupMembersEvent>(_onAddGroupMembers);
    on<ClearCreatedGroupEvent>(_onClearCreatedGroup);
    on<SetConversationArchivedEvent>(_onSetArchived);
    on<SetConversationMutedEvent>(_onSetMuted);
    on<SetParticipantBlockedEvent>(_onSetParticipantBlocked);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<ClearMessageActionEvent>(_onClearAction);
    on<ChatMessageReceivedEvent>(_onMessageReceived);
    on<PeerTypingChangedEvent>(_onPeerTypingChanged);
    on<MessagesReadEvent>(_onMessagesRead);
    on<SendTypingEvent>(_onSendTyping);
    on<MarkConversationReadEvent>(_onMarkRead);

    // Inbox-wide stream keeps the conversations list's latest-message preview
    // live for every thread (not just the open one). Noop until a real socket
    // is wired; the idempotency guards below tolerate the same message also
    // arriving on the per-conversation stream.
    _inboxSub = _socket.inbox().listen((m) {
      if (!isClosed) add(ChatMessageReceivedEvent(m));
    });
  }

  final MessageUseCase useCase;
  final ChatSocketService _socket;
  StreamSubscription<ChatMessageModel>? _messageSub;
  StreamSubscription<ChatMessageModel>? _inboxSub;
  StreamSubscription<bool>? _typingSub;
  StreamSubscription<ChatReadReceipt>? _readSub;
  Timer? _peerTypingTimer;
  Timer? _markReadTimer;
  bool _loadingConversations = false;

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<MessageState> emit,
  ) async {
    if (_loadingConversations) return;
    _loadingConversations = true;
    if (!event.silent) {
      emit(
        state.copyWith(
          conversationsStatus: MessageStatus.loading,
          clearErrorMessage: true,
        ),
      );
    }
    final result = await useCase.getConversations(archived: event.archived);
    _loadingConversations = false;
    result.fold(
      (failure) => emit(
        event.silent
            ? state.copyWith(errorMessage: failure.errorMessage)
            : state.copyWith(
                conversationsStatus: MessageStatus.failure,
                errorMessage: failure.errorMessage,
              ),
      ),
      (conversations) => emit(
        state.copyWith(
          conversationsStatus: MessageStatus.success,
          conversations: conversations,
          showingArchived: event.archived,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onLoadChat(
    LoadChatEvent event,
    Emitter<MessageState> emit,
  ) async {
    // Re-point the realtime streams at the opened conversation.
    _subscribe(event.conversationId);
    emit(
      state.copyWith(
        chatStatus: MessageStatus.loading,
        activeConversationId: event.conversationId,
        activeConversation:
            event.conversation ?? _conversationById(event.conversationId),
        messages: const [],
        peerTyping: false,
        clearErrorMessage: true,
      ),
    );
    final details = await useCase.getConversationDetails(event.conversationId);
    if (state.activeConversationId != event.conversationId) return;
    details.fold(
      (_) {},
      (conversation) => emit(
        state.copyWith(
          activeConversation: conversation,
          conversations: _upsertConversation(conversation),
        ),
      ),
    );
    final result = await useCase.getMessages(event.conversationId);
    if (state.activeConversationId != event.conversationId) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          chatStatus: MessageStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (messages) {
        emit(
          state.copyWith(
            chatStatus: MessageStatus.success,
            // Preserve socket messages that arrived during the history fetch.
            messages: _mergeMessages(state.messages, messages),
            clearErrorMessage: true,
          ),
        );
        if (!isClosed) add(MarkConversationReadEvent(event.conversationId));
      },
    );
  }

  void _onCloseChat(CloseChatEvent event, Emitter<MessageState> emit) {
    _unsubscribe();
    _markReadTimer?.cancel();
    emit(
      state.copyWith(
        chatStatus: MessageStatus.initial,
        clearActiveConversation: true,
        messages: const [],
        peerTyping: false,
      ),
    );
    // Unread counts likely changed while reading — refresh quietly. The
    // bloc may already be closing when the chat was opened with its own
    // page-scoped provider (e.g. via ChatLauncher), so guard the self-add.
    if (!isClosed) {
      add(
        LoadConversationsEvent(silent: true, archived: state.showingArchived),
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(sending: true));
    final result = await useCase.sendMessage(
      event.conversationId,
      request: event.request,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(sending: false, errorMessage: failure.errorMessage),
      ),
      (message) => emit(
        state.copyWith(
          sending: false,
          // The socket can win the race with this REST response. Merge by the
          // server id so the sender still gets exactly one bubble.
          messages: state.activeConversationId == event.conversationId
              ? _mergeMessages(state.messages, [message])
              : state.messages,
          // Reflect the just-sent message in the inbox list (shows as "You: …")
          // and float the thread to the top.
          conversations: _bumpToTop(message),
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onCreateGroup(
    CreateGroupConversationEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(
      state.copyWith(
        groupCreating: true,
        clearCreatedGroup: true,
        clearErrorMessage: true,
      ),
    );
    final result = await useCase.createGroupConversation(
      title: event.title,
      participantIds: event.participantIds,
      venueId: event.venueId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          groupCreating: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (conversation) => emit(
        state.copyWith(
          groupCreating: false,
          createdGroup: conversation,
          conversations: state.showingArchived
              ? state.conversations
              : _upsertConversation(conversation, moveToTop: true),
          clearErrorMessage: true,
        ),
      ),
    );
  }

  void _onClearCreatedGroup(
    ClearCreatedGroupEvent event,
    Emitter<MessageState> emit,
  ) => emit(state.copyWith(clearCreatedGroup: true));

  Future<void> _onAddGroupMembers(
    AddGroupMembersEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(actionBusy: true, clearActionMessage: true));
    final result = await useCase.addConversationParticipants(
      event.conversationId,
      event.participantIds,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(actionBusy: false, errorMessage: failure.errorMessage),
      ),
      (conversation) => emit(
        state.copyWith(
          actionBusy: false,
          activeConversation: conversation,
          conversations: _upsertConversation(conversation),
          actionMessage: event.participantIds.length == 1
              ? 'Member added.'
              : '${event.participantIds.length} members added.',
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onSetArchived(
    SetConversationArchivedEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(actionBusy: true, clearActionMessage: true));
    final result = await useCase.setArchived(
      event.conversationId,
      event.archived,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(actionBusy: false, errorMessage: failure.errorMessage),
      ),
      (_) {
        final current =
            state.activeConversation ?? _conversationById(event.conversationId);
        final updated = current?.copyWith(isArchived: event.archived);
        final conversations = event.archived == state.showingArchived
            ? updated == null
                  ? state.conversations
                  : _upsertConversation(updated)
            : state.conversations
                  .where((item) => item.id != event.conversationId)
                  .toList(growable: false);
        emit(
          state.copyWith(
            actionBusy: false,
            activeConversation: updated,
            conversations: conversations,
            actionMessage: event.archived
                ? 'Conversation archived.'
                : 'Conversation unarchived.',
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onSetMuted(
    SetConversationMutedEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(actionBusy: true, clearActionMessage: true));
    final result = await useCase.setMuted(event.conversationId, event.muted);
    result.fold(
      (failure) => emit(
        state.copyWith(actionBusy: false, errorMessage: failure.errorMessage),
      ),
      (_) {
        final current =
            state.activeConversation ?? _conversationById(event.conversationId);
        final updated = current?.copyWith(isMuted: event.muted);
        emit(
          state.copyWith(
            actionBusy: false,
            activeConversation: updated,
            conversations: updated == null
                ? state.conversations
                : _upsertConversation(updated),
            actionMessage: event.muted
                ? 'Conversation muted.'
                : 'Conversation unmuted.',
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onSetParticipantBlocked(
    SetParticipantBlockedEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(actionBusy: true, clearActionMessage: true));
    final result = await useCase.setParticipantBlocked(
      event.conversationId,
      event.userId,
      event.blocked,
      reason: event.reason,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(actionBusy: false, errorMessage: failure.errorMessage),
      ),
      (_) {
        final current =
            state.activeConversation ?? _conversationById(event.conversationId);
        final updated = current?.copyWith(
          participants: current.participants
              .map(
                (participant) => participant.userId == event.userId
                    ? participant.copyWith(isBlocked: event.blocked)
                    : participant,
              )
              .toList(growable: false),
        );
        emit(
          state.copyWith(
            actionBusy: false,
            activeConversation: updated,
            conversations: updated == null
                ? state.conversations
                : _upsertConversation(updated),
            actionMessage: event.blocked
                ? 'Participant blocked.'
                : 'Participant unblocked.',
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(actionBusy: true, clearActionMessage: true));
    final result = await useCase.deleteMessage(event.messageId);
    result.fold(
      (failure) => emit(
        state.copyWith(actionBusy: false, errorMessage: failure.errorMessage),
      ),
      (_) {
        emit(
          state.copyWith(
            actionBusy: false,
            messages: state.messages
                .where((message) => message.id != event.messageId)
                .toList(growable: false),
            actionMessage: 'Message deleted.',
            clearErrorMessage: true,
          ),
        );
        if (!isClosed) {
          add(
            LoadConversationsEvent(
              silent: true,
              archived: state.showingArchived,
            ),
          );
        }
      },
    );
  }

  void _onClearAction(
    ClearMessageActionEvent event,
    Emitter<MessageState> emit,
  ) => emit(state.copyWith(clearActionMessage: true, clearErrorMessage: true));

  void _onMessageReceived(
    ChatMessageReceivedEvent event,
    Emitter<MessageState> emit,
  ) {
    final message = event.message;
    final bool mine = message.senderId == state.currentUserId;
    final bool isActive = message.conversationId == state.activeConversationId;
    final int index = state.conversations.indexWhere(
      (c) => c.id == message.conversationId,
    );

    // A message for a thread we don't have yet (e.g. a brand-new conversation)
    // — pull the list quietly so it appears. Do not drop it from an active
    // page-scoped chat whose inbox has not been loaded.
    if (index < 0) {
      if (!isClosed) {
        add(
          LoadConversationsEvent(silent: true, archived: state.showingArchived),
        );
      }
    }

    final existing = index < 0 ? null : state.conversations[index];
    // The same message can arrive on both the inbox and per-conversation
    // streams; apply it (and its unread bump) exactly once.
    final bool alreadyApplied = existing?.lastMessageDetail?.id == message.id;
    final bool olderThanPreview =
        existing?.lastMessageAt != null &&
        message.createdAt.isBefore(existing!.lastMessageAt!);

    // Inbox list: refresh the latest-message preview/timestamp, bump unread for
    // unseen messages from the other side, and move the thread to the top.
    final conversations = index < 0 || alreadyApplied || olderThanPreview
        ? state.conversations
        : (List<ConversationModel>.of(state.conversations)
            ..removeAt(index)
            ..insert(
              0,
              existing!.withLatestMessage(
                message,
                incrementUnread: !mine && !isActive,
              ),
            ));

    // Open thread: append once.
    final messages = isActive
        ? _mergeMessages(state.messages, [message])
        : state.messages;

    emit(
      state.copyWith(
        conversations: conversations,
        messages: messages,
        peerTyping: isActive ? false : state.peerTyping,
      ),
    );

    if (isActive && !mine) _scheduleMarkRead(message.conversationId);
  }

  /// Moves [message]'s conversation to the top of the list with the message as
  /// its latest. Returns the list unchanged when the conversation isn't loaded.
  List<ConversationModel> _bumpToTop(ChatMessageModel message) {
    final int index = state.conversations.indexWhere(
      (c) => c.id == message.conversationId,
    );
    if (index < 0) return state.conversations;
    final existing = state.conversations[index];
    if (existing.lastMessageAt != null &&
        message.createdAt.isBefore(existing.lastMessageAt!)) {
      return state.conversations;
    }
    return List<ConversationModel>.of(state.conversations)
      ..removeAt(index)
      ..insert(0, existing.withLatestMessage(message));
  }

  ConversationModel? _conversationById(int conversationId) {
    for (final conversation in state.conversations) {
      if (conversation.id == conversationId) return conversation;
    }
    return null;
  }

  List<ConversationModel> _upsertConversation(
    ConversationModel conversation, {
    bool moveToTop = false,
  }) {
    final conversations = List<ConversationModel>.of(state.conversations);
    final index = conversations.indexWhere(
      (item) => item.id == conversation.id,
    );
    if (index < 0) {
      conversations.insert(0, conversation);
    } else if (moveToTop) {
      conversations
        ..removeAt(index)
        ..insert(0, conversation);
    } else {
      conversations[index] = conversation;
    }
    return conversations;
  }

  List<ChatMessageModel> _mergeMessages(
    Iterable<ChatMessageModel> current,
    Iterable<ChatMessageModel> incoming,
  ) {
    final byId = <int, ChatMessageModel>{};
    for (final message in [...current, ...incoming]) {
      final previous = byId[message.id];
      if (previous == null ||
          _statusRank(message.status) >= _statusRank(previous.status)) {
        byId[message.id] = message;
      }
    }
    final result = byId.values.toList(growable: false);
    result.sort((a, b) {
      final byTime = a.createdAt.compareTo(b.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return result;
  }

  int _statusRank(String status) => switch (status.toLowerCase()) {
    'read' => 3,
    'delivered' => 2,
    _ => 1,
  };

  void _onPeerTypingChanged(
    PeerTypingChangedEvent event,
    Emitter<MessageState> emit,
  ) {
    if (event.conversationId != state.activeConversationId) return;
    _peerTypingTimer?.cancel();
    emit(state.copyWith(peerTyping: event.isTyping));
    if (event.isTyping) {
      // A disconnect can lose stop-typing; never leave the indicator stuck.
      _peerTypingTimer = Timer(const Duration(seconds: 5), () {
        if (!isClosed) {
          add(PeerTypingChangedEvent(event.conversationId, false));
        }
      });
    }
  }

  void _onMessagesRead(MessagesReadEvent event, Emitter<MessageState> emit) {
    final receipt = event.receipt;
    if (receipt.readerId != 0 && receipt.readerId == state.currentUserId) {
      return;
    }
    final ids = receipt.messageIds.toSet();
    bool applies(ChatMessageModel message) =>
        message.conversationId == receipt.conversationId &&
        message.senderId == state.currentUserId &&
        (ids.isEmpty || ids.contains(message.id));

    final messages = state.messages
        .map(
          (message) =>
              applies(message) ? message.copyWith(status: 'read') : message,
        )
        .toList(growable: false);
    final conversations = state.conversations
        .map((conversation) {
          final last = conversation.lastMessageDetail;
          return last != null && applies(last)
              ? conversation.withLatestMessage(last.copyWith(status: 'read'))
              : conversation;
        })
        .toList(growable: false);
    emit(state.copyWith(messages: messages, conversations: conversations));
  }

  Future<void> _onSendTyping(
    SendTypingEvent event,
    Emitter<MessageState> emit,
  ) async {
    // Fire-and-forget broadcast; failures are irrelevant to the UI.
    if (event.typing && event.conversationId != state.activeConversationId) {
      return;
    }
    await useCase.setTyping(event.conversationId, event.typing);
  }

  Future<void> _onMarkRead(
    MarkConversationReadEvent event,
    Emitter<MessageState> emit,
  ) async {
    // Optimistically clear the badge, then tell the server.
    emit(
      state.copyWith(
        conversations: state.conversations
            .map(
              (c) =>
                  c.id == event.conversationId ? c.copyWith(unreadCount: 0) : c,
            )
            .toList(growable: false),
      ),
    );
    final result = await useCase.markRead(event.conversationId);
    result.fold((_) {
      // Reconcile the optimistic badge with the server on the next fetch.
      if (!isClosed) {
        add(
          LoadConversationsEvent(silent: true, archived: state.showingArchived),
        );
      }
    }, (_) {});
  }

  void _scheduleMarkRead(int conversationId) {
    _markReadTimer?.cancel();
    _markReadTimer = Timer(const Duration(milliseconds: 250), () {
      if (!isClosed && state.activeConversationId == conversationId) {
        add(MarkConversationReadEvent(conversationId));
      }
    });
  }

  void _subscribe(int conversationId) {
    _unsubscribe();
    // Socket callbacks can fire while the bloc is tearing down — never add
    // events after close.
    _messageSub = _socket.messages(conversationId).listen((m) {
      if (!isClosed) add(ChatMessageReceivedEvent(m));
    });
    _typingSub = _socket.typing(conversationId).listen((t) {
      if (!isClosed) add(PeerTypingChangedEvent(conversationId, t));
    });
    _readSub = _socket.readReceipts(conversationId).listen((receipt) {
      if (!isClosed) add(MessagesReadEvent(receipt));
    });
  }

  void _unsubscribe() {
    _messageSub?.cancel();
    _messageSub = null;
    _typingSub?.cancel();
    _typingSub = null;
    _readSub?.cancel();
    _readSub = null;
    _peerTypingTimer?.cancel();
    _peerTypingTimer = null;
  }

  @override
  Future<void> close() {
    _unsubscribe();
    _markReadTimer?.cancel();
    _inboxSub?.cancel();
    _socket.dispose();
    return super.close();
  }
}
