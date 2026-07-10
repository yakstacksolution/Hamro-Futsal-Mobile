import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/data/service/chat_socket_service.dart';
import 'package:hamro_footsall/features/message/domain/repository/message_repository.dart';
import 'package:hamro_footsall/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';

void main() {
  group('MessageBloc realtime reconciliation', () {
    late _FakeMessageRepository repository;
    late _FakeChatSocketService socket;
    late MessageBloc bloc;

    setUp(() {
      repository = _FakeMessageRepository();
      socket = _FakeChatSocketService();
      bloc = MessageBloc(MessageUseCase(repository), socketService: socket);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('merges socket delivery with the in-flight send response', () async {
      await _loadConversationAndChat(bloc);
      final message = _message(id: 60, senderId: repository.currentUserId);
      final response = Completer<Either<AppException, ChatMessageModel>>();
      repository.sendResponse = response;

      bloc.add(const SendMessageEvent(4, ChatSendRequest(body: 'Hello')));
      await bloc.stream.firstWhere((state) => state.sending);

      socket.emitMessage(message, includeInbox: true);
      await bloc.stream.firstWhere((state) => state.messages.isNotEmpty);
      response.complete(right(message));
      await bloc.stream.firstWhere((state) => !state.sending);

      expect(bloc.state.messages.map((item) => item.id), [60]);
    });

    test('applies duplicate incoming delivery and unread count once', () async {
      await _loadConversations(bloc);
      final message = _message(id: 61, senderId: 9);

      socket.emitMessage(
        message,
        includeInbox: true,
        includeConversation: false,
      );
      socket.emitMessage(
        message,
        includeInbox: true,
        includeConversation: false,
      );
      await _flushEvents();

      expect(bloc.state.conversations.single.unreadCount, 3);
      expect(bloc.state.conversations.single.lastMessageDetail?.id, 61);
    });

    test('updates typing, read receipts, and active-chat read state', () async {
      await _loadConversationAndChat(bloc);
      final ownMessage = _message(id: 62, senderId: repository.currentUserId);
      socket.emitMessage(ownMessage);
      await bloc.stream.firstWhere((state) => state.messages.isNotEmpty);

      socket.emitTyping(4, true);
      await bloc.stream.firstWhere((state) => state.peerTyping);
      socket.emitTyping(4, false);
      await bloc.stream.firstWhere((state) => !state.peerTyping);

      socket.emitRead(
        const ChatReadReceipt(conversationId: 4, readerId: 9, messageIds: [62]),
      );
      await bloc.stream.firstWhere((state) => state.messages.single.isRead);

      expect(repository.markReadCalls, isNotEmpty);
      expect(bloc.state.conversations.single.unreadCount, 0);
    });

    test('creates and inserts a group conversation', () async {
      await _loadConversations(bloc);

      bloc.add(
        const CreateGroupConversationEvent(
          title: 'Team Coordination',
          participantIds: [9, 12],
          venueId: 3,
        ),
      );
      final state = await bloc.stream.firstWhere(
        (state) => state.createdGroup != null,
      );

      expect(state.createdGroup?.isGroup, isTrue);
      expect(state.createdGroup?.title, 'Team Coordination');
      expect(state.conversations.first.id, 11);
    });

    test('applies mute, block, delete, and archive actions', () async {
      await _loadConversationAndChat(bloc);

      bloc.add(const SetConversationMutedEvent(4, true));
      await bloc.stream.firstWhere(
        (state) => state.activeConversation?.isMuted ?? false,
      );

      bloc.add(
        const SetParticipantBlockedEvent(
          conversationId: 4,
          userId: 9,
          blocked: true,
        ),
      );
      await bloc.stream.firstWhere(
        (state) =>
            state.activeConversation?.participants.single.isBlocked ?? false,
      );

      final message = _message(id: 65, senderId: repository.currentUserId);
      socket.emitMessage(message);
      await bloc.stream.firstWhere((state) => state.messages.isNotEmpty);
      bloc.add(const DeleteMessageEvent(65));
      await bloc.stream.firstWhere(
        (state) => state.messages.isEmpty && !state.actionBusy,
      );

      bloc.add(const SetConversationArchivedEvent(4, true));
      final state = await bloc.stream.firstWhere(
        (state) => state.activeConversation?.isArchived ?? false,
      );
      expect(state.conversations, isEmpty);
    });
  });
}

Future<void> _loadConversations(MessageBloc bloc) async {
  final loaded = bloc.stream.firstWhere(
    (state) => state.conversationsStatus == MessageStatus.success,
  );
  bloc.add(const LoadConversationsEvent());
  await loaded;
}

Future<void> _loadConversationAndChat(MessageBloc bloc) async {
  await _loadConversations(bloc);
  final loaded = bloc.stream.firstWhere(
    (state) => state.chatStatus == MessageStatus.success,
  );
  bloc.add(const LoadChatEvent(4));
  await loaded;
  await _flushEvents();
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

ChatMessageModel _message({required int id, required int senderId}) =>
    ChatMessageModel(
      id: id,
      conversationId: 4,
      senderId: senderId,
      body: 'Hello',
      createdAt: DateTime.utc(2026, 6, 22, 10, id),
    );

final class _FakeMessageRepository implements MessageRepository {
  Completer<Either<AppException, ChatMessageModel>>? sendResponse;
  final List<int> markReadCalls = <int>[];

  @override
  int get currentUserId => 4;

  @override
  Future<Either<AppException, List<ConversationModel>>> getConversations({
    bool archived = false,
  }) async =>
      right([const ConversationModel(id: 4, type: 'direct', unreadCount: 2)]);

  @override
  Future<Either<AppException, List<ChatMessageModel>>> getMessages(
    int conversationId,
  ) async => right(const []);

  @override
  Future<Either<AppException, ChatMessageModel>> sendMessage(
    int conversationId, {
    required ChatSendRequest request,
  }) => sendResponse!.future;

  @override
  Future<Either<AppException, ConversationModel>> createGroupConversation({
    required String title,
    required List<int> participantIds,
    int? venueId,
  }) async => right(
    ConversationModel(
      id: 11,
      type: 'group',
      title: title,
      venueId: venueId,
      participants: participantIds
          .map((id) => ParticipantModel(id: id, userId: id, name: 'User $id'))
          .toList(growable: false),
    ),
  );

  @override
  Future<Either<AppException, ConversationModel>> addConversationParticipants(
    int conversationId,
    List<int> participantIds,
  ) async => right(
    ConversationModel(
      id: conversationId,
      type: 'group',
      participants: participantIds
          .map((id) => ParticipantModel(id: id, userId: id, name: 'User $id'))
          .toList(growable: false),
    ),
  );

  @override
  Future<Either<AppException, ConversationModel>> getConversationDetails(
    int conversationId,
  ) async => right(
    const ConversationModel(
      id: 4,
      type: 'direct',
      unreadCount: 2,
      participants: [ParticipantModel(id: 9, userId: 9, name: 'Peer')],
    ),
  );

  @override
  Future<Either<AppException, bool>> getUserPresence(int userId) async =>
      right(false);

  @override
  Future<Either<AppException, bool>> setPresence(bool online) async =>
      right(true);

  @override
  Future<Either<AppException, bool>> sendPresenceHeartbeat(
    String socketId,
  ) async => right(true);

  @override
  Future<Either<AppException, Uint8List>> getMediaBytes(int mediaId) async =>
      right(Uint8List.fromList(<int>[1, 2, 3]));

  @override
  Future<Either<AppException, bool>> setParticipantBlocked(
    int conversationId,
    int userId,
    bool blocked, {
    String? reason,
  }) async => right(true);

  @override
  Future<Either<AppException, bool>> markRead(int conversationId) async {
    markReadCalls.add(conversationId);
    return right(true);
  }

  @override
  Future<Either<AppException, bool>> setTyping(
    int conversationId,
    bool typing,
  ) async => right(true);

  @override
  Future<Either<AppException, ConversationModel>> startDirectConversation({
    int? vendorId,
    int? venueId,
    int? userId,
  }) => throw UnimplementedError();

  @override
  Future<Either<AppException, bool>> deleteMessage(int messageId) =>
      Future.value(right(true));

  @override
  Future<Either<AppException, bool>> setArchived(
    int conversationId,
    bool archived,
  ) => Future.value(right(true));

  @override
  Future<Either<AppException, bool>> setMuted(int conversationId, bool muted) =>
      Future.value(right(true));
}

final class _FakeChatSocketService implements ChatSocketService {
  final _inbox = StreamController<ChatMessageModel>.broadcast();
  final _messages = <int, StreamController<ChatMessageModel>>{};
  final _typing = <int, StreamController<bool>>{};
  final _receipts = <int, StreamController<ChatReadReceipt>>{};

  @override
  Stream<ChatMessageModel> inbox() => _inbox.stream;

  @override
  Stream<ChatMessageModel> messages(int conversationId) => _messages
      .putIfAbsent(
        conversationId,
        () => StreamController<ChatMessageModel>.broadcast(),
      )
      .stream;

  @override
  Stream<bool> typing(int conversationId) => _typing
      .putIfAbsent(conversationId, () => StreamController<bool>.broadcast())
      .stream;

  @override
  Stream<ChatReadReceipt> readReceipts(int conversationId) => _receipts
      .putIfAbsent(
        conversationId,
        () => StreamController<ChatReadReceipt>.broadcast(),
      )
      .stream;

  void emitMessage(
    ChatMessageModel message, {
    bool includeInbox = false,
    bool includeConversation = true,
  }) {
    if (includeInbox) _inbox.add(message);
    if (includeConversation) _messages[message.conversationId]?.add(message);
  }

  void emitTyping(int conversationId, bool typing) {
    _typing[conversationId]?.add(typing);
  }

  void emitRead(ChatReadReceipt receipt) {
    _receipts[receipt.conversationId]?.add(receipt);
  }

  @override
  void dispose() {
    _inbox.close();
    for (final controller in _messages.values) {
      controller.close();
    }
    for (final controller in _typing.values) {
      controller.close();
    }
    for (final controller in _receipts.values) {
      controller.close();
    }
  }
}
