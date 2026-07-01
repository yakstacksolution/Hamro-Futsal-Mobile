import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/features/message/data/data_source/message_remote_data_source.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';
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
  Future<Either<AppException, ConversationModel>> createGroupConversation({
    required String title,
    required List<int> participantIds,
    int? venueId,
  }) async {
    final response = await _remoteDataSource.createGroupConversation(
      title: title,
      participantIds: participantIds,
      venueId: venueId,
    );
    if (response.isError()) return left(ResponseHelper.error(response));
    try {
      return right(
        ConversationModel.fromJson(_findObject(response.getValue())!),
      );
    } catch (_) {
      return left(_parseError('the group conversation'));
    }
  }

  @override
  Future<Either<AppException, ConversationModel>> addConversationParticipants(
    int conversationId,
    List<int> participantIds,
  ) async {
    final response = await _remoteDataSource.addConversationParticipants(
      conversationId,
      participantIds,
    );
    if (response.isError()) return left(ResponseHelper.error(response));
    try {
      return right(
        ConversationModel.fromJson(_findObject(response.getValue())!),
      );
    } catch (_) {
      // Some APIs return only a success message, so fetch the updated group.
      return getConversationDetails(conversationId);
    }
  }

  @override
  Future<Either<AppException, ConversationModel>> getConversationDetails(
    int conversationId,
  ) async {
    final response = await _remoteDataSource.getConversationDetails(
      conversationId,
    );
    if (response.isError()) return left(ResponseHelper.error(response));
    try {
      return right(
        ConversationModel.fromJson(_findObject(response.getValue())!),
      );
    } catch (_) {
      return left(_parseError('the conversation'));
    }
  }

  @override
  Future<Either<AppException, bool>> getUserPresence(int userId) async {
    final response = await _remoteDataSource.getUserPresence(userId);
    if (response.isError()) return left(ResponseHelper.error(response));

    dynamic value = response.getValue();
    for (var depth = 0; depth < 3 && value is Map; depth++) {
      final map = Map<String, dynamic>.from(value);
      for (final key in const ['is_online', 'online', 'isOnline']) {
        if (map.containsKey(key)) {
          final raw = map[key];
          return right(
            raw == true ||
                raw == 1 ||
                raw?.toString().toLowerCase() == 'true' ||
                raw?.toString() == '1' ||
                raw?.toString().toLowerCase() == 'online',
          );
        }
      }
      value = map['data'] ?? map['presence'] ?? map['status'];
    }
    if (value is String) {
      return right(value.toLowerCase() == 'online');
    }
    return left(_parseError('user presence'));
  }

  @override
  Future<Either<AppException, bool>> setPresence(bool online) async {
    final response = await _remoteDataSource.setPresence(online);
    if (response.isError()) return left(ResponseHelper.error(response));
    return right(true);
  }

  @override
  Future<Either<AppException, bool>> sendPresenceHeartbeat(
    String socketId,
  ) async {
    final response = await _remoteDataSource.sendPresenceHeartbeat(socketId);
    if (response.isError()) return left(ResponseHelper.error(response));
    return right(true);
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
    required ChatSendRequest request,
  }) async {
    final response = await _remoteDataSource.sendMessage(
      conversationId,
      request: request,
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
  Future<Either<AppException, bool>> setParticipantBlocked(
    int conversationId,
    int userId,
    bool blocked, {
    String? reason,
  }) => _action(
    _remoteDataSource.setParticipantBlocked(
      conversationId,
      userId,
      blocked,
      reason: reason,
    ),
  );

  @override
  Future<Either<AppException, bool>> deleteMessage(int messageId) =>
      _action(_remoteDataSource.deleteMessage(messageId));

  @override
  Future<Either<AppException, Uint8List>> getMediaBytes(int mediaId) async {
    final response = await _remoteDataSource.getMediaBytes(mediaId);
    if (response.isError()) return left(ResponseHelper.error(response));
    return right(response.getValue()!);
  }
}
