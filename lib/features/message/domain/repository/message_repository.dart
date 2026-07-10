import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';

abstract class MessageRepository {
  /// Id of the signed-in user (from the access token) — used to tell own
  /// messages apart from the other side's.
  int get currentUserId;

  Future<Either<AppException, List<ConversationModel>>> getConversations({
    bool archived = false,
  });
  Future<Either<AppException, ConversationModel>> startDirectConversation({
    int? vendorId,
    int? venueId,
    int? userId,
  });
  Future<Either<AppException, ConversationModel>> createGroupConversation({
    required String title,
    required List<int> participantIds,
    int? venueId,
  });
  Future<Either<AppException, ConversationModel>> addConversationParticipants(
    int conversationId,
    List<int> participantIds,
  );
  Future<Either<AppException, ConversationModel>> getConversationDetails(
    int conversationId,
  );
  Future<Either<AppException, bool>> getUserPresence(int userId);
  Future<Either<AppException, bool>> setPresence(bool online);
  Future<Either<AppException, bool>> sendPresenceHeartbeat(String socketId);
  Future<Either<AppException, List<ChatMessageModel>>> getMessages(
    int conversationId,
  );
  Future<Either<AppException, ChatMessageModel>> sendMessage(
    int conversationId, {
    required ChatSendRequest request,
  });
  Future<Either<AppException, bool>> markRead(int conversationId);
  Future<Either<AppException, bool>> setTyping(int conversationId, bool typing);
  Future<Either<AppException, bool>> setArchived(
    int conversationId,
    bool archived,
  );
  Future<Either<AppException, bool>> setMuted(int conversationId, bool muted);
  Future<Either<AppException, bool>> setParticipantBlocked(
    int conversationId,
    int userId,
    bool blocked, {
    String? reason,
  });
  Future<Either<AppException, bool>> deleteMessage(int messageId);
  Future<Either<AppException, Uint8List>> getMediaBytes(int mediaId);
}
