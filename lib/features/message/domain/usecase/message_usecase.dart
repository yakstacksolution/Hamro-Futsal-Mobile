import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/domain/repository/message_repository.dart';

final class MessageUseCase {
  const MessageUseCase(this.repository);

  final MessageRepository repository;

  int get currentUserId => repository.currentUserId;

  Future<Either<AppException, List<ConversationModel>>> getConversations({
    bool archived = false,
  }) async => await repository.getConversations(archived: archived);

  Future<Either<AppException, ConversationModel>> startDirectConversation({
    required int vendorId,
    int? venueId,
  }) async => await repository.startDirectConversation(
    vendorId: vendorId,
    venueId: venueId,
  );

  Future<Either<AppException, List<ChatMessageModel>>> getMessages(
    int conversationId,
  ) async => await repository.getMessages(conversationId);

  Future<Either<AppException, ChatMessageModel>> sendMessage(
    int conversationId, {
    required String body,
    int? replyToMessageId,
  }) async => await repository.sendMessage(
    conversationId,
    body: body,
    replyToMessageId: replyToMessageId,
  );

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

  Future<Either<AppException, bool>> deleteMessage(int messageId) async =>
      await repository.deleteMessage(messageId);
}
