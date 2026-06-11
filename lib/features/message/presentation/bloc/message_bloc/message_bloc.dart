import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
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
    on<ChatMessageReceivedEvent>(_onMessageReceived);
    on<PeerTypingChangedEvent>(_onPeerTypingChanged);
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

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<MessageState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(
          conversationsStatus: MessageStatus.loading,
          clearErrorMessage: true,
        ),
      );
    }
    final result = await useCase.getConversations();
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
        messages: const [],
        peerTyping: false,
        clearErrorMessage: true,
      ),
    );
    final result = await useCase.getMessages(event.conversationId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          chatStatus: MessageStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (messages) => emit(
        state.copyWith(
          chatStatus: MessageStatus.success,
          messages: messages,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  void _onCloseChat(CloseChatEvent event, Emitter<MessageState> emit) {
    _unsubscribe();
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
    if (!isClosed) add(const LoadConversationsEvent(silent: true));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(sending: true));
    final result = await useCase.sendMessage(
      event.conversationId,
      body: event.body,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(sending: false, errorMessage: failure.errorMessage),
      ),
      (message) => emit(
        state.copyWith(
          sending: false,
          messages: [...state.messages, message],
          // Reflect the just-sent message in the inbox list (shows as "You: …")
          // and float the thread to the top.
          conversations: _bumpToTop(message),
          clearErrorMessage: true,
        ),
      ),
    );
  }

  void _onMessageReceived(
    ChatMessageReceivedEvent event,
    Emitter<MessageState> emit,
  ) {
    final message = event.message;
    final int index = state.conversations.indexWhere(
      (c) => c.id == message.conversationId,
    );

    // A message for a thread we don't have yet (e.g. a brand-new conversation)
    // — pull the list quietly so it appears.
    if (index < 0) {
      if (!isClosed) add(const LoadConversationsEvent(silent: true));
      return;
    }

    final existing = state.conversations[index];
    // The same message can arrive on both the inbox and per-conversation
    // streams; apply it (and its unread bump) exactly once.
    final bool alreadyApplied = existing.lastMessageDetail?.id == message.id;
    final bool mine = message.senderId == state.currentUserId;
    final bool isActive = message.conversationId == state.activeConversationId;

    // Inbox list: refresh the latest-message preview/timestamp, bump unread for
    // unseen messages from the other side, and move the thread to the top.
    final conversations = alreadyApplied
        ? state.conversations
        : (List<ConversationModel>.of(state.conversations)
            ..removeAt(index)
            ..insert(
              0,
              existing.withLatestMessage(
                message,
                incrementUnread: !mine && !isActive,
              ),
            ));

    // Open thread: append once.
    final messages = isActive && !state.messages.any((m) => m.id == message.id)
        ? [...state.messages, message]
        : state.messages;

    emit(
      state.copyWith(
        conversations: conversations,
        messages: messages,
        peerTyping: isActive ? false : state.peerTyping,
      ),
    );
  }

  /// Moves [message]'s conversation to the top of the list with the message as
  /// its latest. Returns the list unchanged when the conversation isn't loaded.
  List<ConversationModel> _bumpToTop(ChatMessageModel message) {
    final int index = state.conversations.indexWhere(
      (c) => c.id == message.conversationId,
    );
    if (index < 0) return state.conversations;
    return List<ConversationModel>.of(state.conversations)
      ..removeAt(index)
      ..insert(0, state.conversations[index].withLatestMessage(message));
  }

  void _onPeerTypingChanged(
    PeerTypingChangedEvent event,
    Emitter<MessageState> emit,
  ) {
    emit(state.copyWith(peerTyping: event.isTyping));
  }

  Future<void> _onSendTyping(
    SendTypingEvent event,
    Emitter<MessageState> emit,
  ) async {
    // Fire-and-forget broadcast; failures are irrelevant to the UI.
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
    await useCase.markRead(event.conversationId);
  }

  void _subscribe(int conversationId) {
    _unsubscribe();
    // Socket callbacks can fire while the bloc is tearing down — never add
    // events after close.
    _messageSub = _socket.messages(conversationId).listen((m) {
      if (!isClosed) add(ChatMessageReceivedEvent(m));
    });
    _typingSub = _socket.typing(conversationId).listen((t) {
      if (!isClosed) add(PeerTypingChangedEvent(t));
    });
  }

  void _unsubscribe() {
    _messageSub?.cancel();
    _messageSub = null;
    _typingSub?.cancel();
    _typingSub = null;
  }

  @override
  Future<void> close() {
    _unsubscribe();
    _inboxSub?.cancel();
    _socket.dispose();
    return super.close();
  }
}
