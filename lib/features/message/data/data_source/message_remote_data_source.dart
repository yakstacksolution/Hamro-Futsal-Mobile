import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class MessageRemoteDataSource {
  Future<Result> getConversations({bool archived = false});
  Future<Result> startDirectConversation({required int vendorId, int? venueId});
  Future<Result> getMessages(int conversationId);
  Future<Result> sendMessage(
    int conversationId, {
    required String body,
    String type = 'text',
    int? replyToMessageId,
  });
  Future<Result> markRead(int conversationId);
  Future<Result> setTyping(int conversationId, bool typing);
  Future<Result> setArchived(int conversationId, bool archived);
  Future<Result> setMuted(int conversationId, bool muted);
  Future<Result> deleteMessage(int messageId);
}

final class MessageRemoteDataSourceImpl extends MessageRemoteDataSource {
  @override
  Future<Result> getConversations({bool archived = false}) async => await Client
      .instance()
      .getAuthManager()
      .getConversations(archived: archived);

  @override
  Future<Result> startDirectConversation({
    required int vendorId,
    int? venueId,
  }) async => await Client.instance().getAuthManager().startDirectConversation({
    'vendor_id': vendorId,
    if (venueId != null) 'venue_id': venueId,
  });

  @override
  Future<Result> getMessages(int conversationId) async => await Client
      .instance()
      .getAuthManager()
      .getConversationMessages(conversationId);

  @override
  Future<Result> sendMessage(
    int conversationId, {
    required String body,
    String type = 'text',
    int? replyToMessageId,
  }) async => await Client.instance().getAuthManager().sendConversationMessage(
    conversationId,
    <String, dynamic>{
      'type': type,
      'body': body,
      if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
    },
  );

  @override
  Future<Result> markRead(int conversationId) async =>
      await Client.instance().getAuthManager().markConversationRead(
        conversationId,
      );

  @override
  Future<Result> setTyping(int conversationId, bool typing) async =>
      await Client.instance().getAuthManager().sendConversationTyping(
        conversationId,
        typing,
      );

  @override
  Future<Result> setArchived(int conversationId, bool archived) async =>
      await Client.instance().getAuthManager().archiveConversation(
        conversationId,
        archived,
      );

  @override
  Future<Result> setMuted(int conversationId, bool muted) async =>
      await Client.instance().getAuthManager().muteConversation(
        conversationId,
        muted,
      );

  @override
  Future<Result> deleteMessage(int messageId) async =>
      await Client.instance().getAuthManager().deleteChatMessage(messageId);
}
