import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/features/message/data/data_source/message_remote_data_source.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/domain/repository/message_repository.dart';
import 'package:jwt_decode/jwt_decode.dart';

final class MessageRepositoryImpl extends MessageRepository {
  MessageRepositoryImpl({MessageRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MessageRemoteDataSourceImpl();

  final MessageRemoteDataSource _remoteDataSource;

  /// Laravel puts the user id in the token's `sub` claim.
  @override
  int get currentUserId {
    final token = AppSettings().tokenModel.accessToken;
    if (token == null || token.isEmpty) return 0;
    try {
      return int.tryParse(Jwt.parseJwt(token)['sub']?.toString() ?? '') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  AppException _parseError(String what) => DefaultException(
    errorMessage: 'Could not parse $what from server.',
    statusCode: 0,
  );

  /// Walks `{data: {items: [...]}}`-style envelopes to the first list.
  List<dynamic> _findList(dynamic node, {int depth = 0}) {
    if (node is List) return node;
    if (node is Map && depth < 3) {
      for (final key in const ['data', 'items', 'results']) {
        final dynamic child = node[key];
        if (child == null) continue;
        final found = _findList(child, depth: depth + 1);
        if (found.isNotEmpty) return found;
      }
    }
    return const [];
  }

  /// Unwraps `{success, message, data: {...}}` to the inner object.
  Map<String, dynamic>? _findObject(dynamic node, {int depth = 0}) {
    if (node is! Map) return null;
    if (node.containsKey('id')) return Map<String, dynamic>.from(node);
    if (depth < 3) {
      final found = _findObject(node['data'], depth: depth + 1);
      if (found != null) return found;
    }
    return null;
  }

  @override
  Future<Either<AppException, List<ConversationModel>>> getConversations({
    bool archived = false,
  }) async {
    final response = await _remoteDataSource.getConversations(
      archived: archived,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final conversations = _findList(response.getValue())
          .whereType<Map>()
          .map((c) => ConversationModel.fromJson(Map<String, dynamic>.from(c)))
          .toList();
      conversations.sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        final at = a.lastMessageAt ?? a.createdAt ?? DateTime(0);
        final bt = b.lastMessageAt ?? b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return right(List.unmodifiable(conversations));
    } catch (_) {
      return left(_parseError('conversations'));
    }
  }

  @override
  Future<Either<AppException, ConversationModel>> startDirectConversation({
    required int vendorId,
    int? venueId,
  }) async {
    final response = await _remoteDataSource.startDirectConversation(
      vendorId: vendorId,
      venueId: venueId,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(
        ConversationModel.fromJson(_findObject(response.getValue())!),
      );
    } catch (_) {
      return left(_parseError('the conversation'));
    }
  }

  @override
  Future<Either<AppException, List<ChatMessageModel>>> getMessages(
    int conversationId,
  ) async {
    final response = await _remoteDataSource.getMessages(conversationId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final messages = _findList(response.getValue())
          .whereType<Map>()
          .map((m) => ChatMessageModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      // Thread renders oldest → newest.
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return right(List.unmodifiable(messages));
    } catch (_) {
      return left(_parseError('messages'));
    }
  }

  @override
  Future<Either<AppException, ChatMessageModel>> sendMessage(
    int conversationId, {
    required String body,
    int? replyToMessageId,
  }) async {
    final response = await _remoteDataSource.sendMessage(
      conversationId,
      body: body,
      replyToMessageId: replyToMessageId,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(
        ChatMessageModel.fromJson(_findObject(response.getValue())!),
      );
    } catch (_) {
      return left(_parseError('the sent message'));
    }
  }

  Future<Either<AppException, bool>> _action(Future<Result> call) async {
    final response = await call;
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(true);
  }

  @override
  Future<Either<AppException, bool>> markRead(int conversationId) =>
      _action(_remoteDataSource.markRead(conversationId));

  @override
  Future<Either<AppException, bool>> setTyping(
    int conversationId,
    bool typing,
  ) => _action(_remoteDataSource.setTyping(conversationId, typing));

  @override
  Future<Either<AppException, bool>> setArchived(
    int conversationId,
    bool archived,
  ) => _action(_remoteDataSource.setArchived(conversationId, archived));

  @override
  Future<Either<AppException, bool>> setMuted(int conversationId, bool muted) =>
      _action(_remoteDataSource.setMuted(conversationId, muted));

  @override
  Future<Either<AppException, bool>> deleteMessage(int messageId) =>
      _action(_remoteDataSource.deleteMessage(messageId));
}
