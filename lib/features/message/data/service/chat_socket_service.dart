import 'dart:async';

import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';

final class ChatReadReceipt {
  const ChatReadReceipt({
    required this.conversationId,
    this.readerId = 0,
    this.messageIds = const <int>[],
  });

  final int conversationId;
  final int readerId;
  final List<int> messageIds;
}

abstract class ChatSocketService {
  Stream<ChatMessageModel> messages(int conversationId);

  Stream<ChatMessageModel> inbox();

  Stream<bool> typing(int conversationId);

  Stream<ChatReadReceipt> readReceipts(int conversationId);

  void dispose();
}

final class NoopChatSocketService implements ChatSocketService {
  @override
  Stream<ChatMessageModel> messages(int conversationId) => const Stream.empty();

  @override
  Stream<ChatMessageModel> inbox() => const Stream.empty();

  @override
  Stream<bool> typing(int conversationId) => const Stream.empty();

  @override
  Stream<ChatReadReceipt> readReceipts(int conversationId) =>
      const Stream.empty();

  @override
  void dispose() {}
}
