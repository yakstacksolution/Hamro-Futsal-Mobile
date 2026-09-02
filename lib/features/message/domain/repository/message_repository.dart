import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_page_model.dart';
import 'package:hamro_futsal/features/message/data/model/chat_send_request.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_page_model.dart';
import 'package:hamro_futsal/features/message/data/model/message_profile_model.dart';

abstract class MessageRepository {
  int get currentUserId;

  Future<Either<AppException, ConversationPageModel>> getConversations({
    bool archived = false,
    required int page,
    required int perPage,
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

  /// View-only profile of another user, opened from a conversation.
  Future<Either<AppException, MessageProfileModel>> getMessageProfile(
    int userId,
  );

  Future<Either<AppException, bool>> setPresence(bool online);
  Future<Either<AppException, bool>> sendPresenceHeartbeat(String socketId);
  Future<Either<AppException, ChatMessagePageModel>> getMessages(
    int conversationId, {
    required int page,
    required int perPage,
  });
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

  /// Renames a group. The updated conversation when the server echoes it back,
  /// null when it only acknowledges the change.
  Future<Either<AppException, ConversationModel?>> updateConversationTitle(
    int conversationId,
    String title,
  );

  /// Leaves a group; true once the server has dropped the caller from it.
  Future<Either<AppException, bool>> leaveConversation(int conversationId);

  /// Answers a group invitation: `accept: true` joins, `false` declines.
  Future<Either<AppException, bool>> respondToConversationInvitation(
    int conversationId,
    bool accept,
  );
  Future<Either<AppException, bool>> setParticipantBlocked(
    int conversationId,
    int userId,
    bool blocked, {
    String? reason,
  });
  Future<Either<AppException, bool>> deleteMessage(int messageId);
  Future<Either<AppException, Uint8List>> getMediaBytes(int mediaId);
}
