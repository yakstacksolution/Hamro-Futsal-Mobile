import 'dart:async';

import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';

/// Realtime chat events for one conversation.
///
/// The backend broadcasts new messages and typing events over websockets.
/// [NoopChatSocketService] is wired by default so the feature works without
/// realtime; swap in a Pusher/Laravel-Echo implementation (same interface)
/// once the socket host/key and channel names are available — the bloc and
/// UI already consume these streams.
abstract class ChatSocketService {
  /// New incoming messages for [conversationId].
  Stream<ChatMessageModel> messages(int conversationId);

  /// New messages across *all* of the signed-in user's conversations — used to
  /// keep the inbox list's latest-message preview live even for threads that
  /// aren't currently open. Emits messages from both sides.
  Stream<ChatMessageModel> inbox();

  /// True while the other side is typing in [conversationId].
  Stream<bool> typing(int conversationId);

  void dispose();
}

/// Placeholder used until socket credentials exist — emits nothing.
final class NoopChatSocketService implements ChatSocketService {
  @override
  Stream<ChatMessageModel> messages(int conversationId) =>
      const Stream.empty();

  @override
  Stream<ChatMessageModel> inbox() => const Stream.empty();

  @override
  Stream<bool> typing(int conversationId) => const Stream.empty();

  @override
  void dispose() {}
}
