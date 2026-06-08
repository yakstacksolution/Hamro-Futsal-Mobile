import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';

abstract class MessageRepository {
  /// Id of the signed-in user (from the access token) — used to tell own
  /// messages apart from the other side's.
  int get currentUserId;

  Future<Either<AppException, List<ConversationModel>>> getConversations({
    bool archived = false,
  });
  Future<Either<AppException, ConversationModel>> startDirectConversation({
    required int vendorId,
    int? venueId,
  });
  Future<Either<AppException, List<ChatMessageModel>>> getMessages(
    int conversationId,
  );
  Future<Either<AppException, ChatMessageModel>> sendMessage(
    int conversationId, {
    required String body,
    int? replyToMessageId,
  });
  Future<Either<AppException, bool>> markRead(int conversationId);
  Future<Either<AppException, bool>> setTyping(int conversationId, bool typing);
  Future<Either<AppException, bool>> setArchived(
    int conversationId,
    bool archived,
  );
  Future<Either<AppException, bool>> setMuted(int conversationId, bool muted);
  Future<Either<AppException, bool>> deleteMessage(int messageId);
}
