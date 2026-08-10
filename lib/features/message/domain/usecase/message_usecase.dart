import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_page_model.dart';
import 'package:hamro_footsall/features/message/data/model/message_profile_model.dart';
import 'package:hamro_footsall/features/message/domain/repository/message_repository.dart';

final class MessageUseCase {
  const MessageUseCase(this.repository);

  final MessageRepository repository;

  int get currentUserId => repository.currentUserId;

  Future<Either<AppException, ConversationPageModel>> getConversations({
    bool archived = false,
    required int page,
    int perPage = 5,
  }) async => await repository.getConversations(
    archived: archived,
    page: page,
    perPage: perPage,
  );

  Future<Either<AppException, ConversationModel>> startDirectConversation({
    int? vendorId,
    int? venueId,
    int? userId,
  }) async => await repository.startDirectConversation(
    vendorId: vendorId,
    venueId: venueId,
    userId: userId,
  );

  Future<Either<AppException, ConversationModel>> createGroupConversation({
    required String title,
    required List<int> participantIds,
    int? venueId,
  }) async => await repository.createGroupConversation(
    title: title,
    participantIds: participantIds,
    venueId: venueId,
  );

  Future<Either<AppException, ConversationModel>> addConversationParticipants(
    int conversationId,
    List<int> participantIds,
  ) async => await repository.addConversationParticipants(
    conversationId,
    participantIds,
  );

  Future<Either<AppException, ConversationModel>> getConversationDetails(
    int conversationId,
  ) async => await repository.getConversationDetails(conversationId);

  Future<Either<AppException, bool>> getUserPresence(int userId) async =>
      await repository.getUserPresence(userId);

  Future<Either<AppException, MessageProfileModel>> getMessageProfile(
    int userId,
  ) async => await repository.getMessageProfile(userId);

  Future<Either<AppException, bool>> setPresence(bool online) async =>
      await repository.setPresence(online);

  Future<Either<AppException, bool>> sendPresenceHeartbeat(
    String socketId,
  ) async => await repository.sendPresenceHeartbeat(socketId);

  Future<Either<AppException, List<ChatMessageModel>>> getMessages(
    int conversationId,
  ) async => await repository.getMessages(conversationId);

  Future<Either<AppException, ChatMessageModel>> sendMessage(
    int conversationId, {
    required ChatSendRequest request,
  }) async => await repository.sendMessage(conversationId, request: request);

  Future<Either<AppException, bool>> markRead(int conversationId) async =>
      await repository.markRead(conversationId);

  Future<Either<AppException, bool>> setTyping(
    int conversationId,
    bool typing,
  ) async => await repository.setTyping(conversationId, typing);

  Future<Either<AppException, bool>> setArchived(
    int conversationId,
    bool archived,
  ) async => await repository.setArchived(conversationId, archived);

  Future<Either<AppException, bool>> setMuted(
    int conversationId,
    bool muted,
  ) async => await repository.setMuted(conversationId, muted);

  Future<Either<AppException, bool>> setParticipantBlocked(
    int conversationId,
    int userId,
    bool blocked, {
    String? reason,
  }) async => await repository.setParticipantBlocked(
    conversationId,
    userId,
    blocked,
    reason: reason,
  );

  Future<Either<AppException, bool>> deleteMessage(int messageId) async =>
      await repository.deleteMessage(messageId);

  Future<Either<AppException, Uint8List>> getMediaBytes(int mediaId) async =>
      await repository.getMediaBytes(mediaId);
}
