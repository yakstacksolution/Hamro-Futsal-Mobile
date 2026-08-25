import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/message/data/data_source/message_remote_data_source.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_page_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_page_model.dart';
import 'package:hamro_footsall/features/message/data/model/message_profile_model.dart';
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
    errorMessage:
        '${StringConstants.couldNotParsePrefix}$what'
        '${StringConstants.fromServerSuffix}',
    statusCode: 0,
  );

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
  Future<Either<AppException, ConversationPageModel>> getConversations({
    bool archived = false,
    required int page,
    required int perPage,
  }) async {
    final response = await _remoteDataSource.getConversations(
      archived: archived,
      page: page,
      perPage: perPage,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final parsed = ConversationPageModel.fromResponse(response.getValue());
      final conversations = List<ConversationModel>.of(parsed.items);
      conversations.sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        final at = a.lastMessageAt ?? a.createdAt ?? DateTime(0);
        final bt = b.lastMessageAt ?? b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return right(
        ConversationPageModel(
          items: List.unmodifiable(conversations),
          currentPage: parsed.currentPage,
          lastPage: parsed.lastPage,
          perPage: parsed.perPage,
          total: parsed.total,
          from: parsed.from,
          to: parsed.to,
          hasMorePages: parsed.hasMorePages,
        ),
      );
    } catch (_) {
      return left(_parseError('conversations'));
    }
  }

  @override
  Future<Either<AppException, ConversationModel>> startDirectConversation({
    int? vendorId,
    int? venueId,
    int? userId,
  }) async {
    final response = await _remoteDataSource.startDirectConversation(
      vendorId: vendorId,
      venueId: venueId,
      userId: userId,
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
  Future<Either<AppException, MessageProfileModel>> getMessageProfile(
    int userId,
  ) async {
    final response = await _remoteDataSource.getMessageProfile(userId);
    if (response.isError()) return left(ResponseHelper.error(response));
    try {
      // The profile may be returned bare or wrapped in a `data` envelope, and
      // without an `id` when the resource only exposes the display fields.
      dynamic node = response.getValue();
      Map<String, dynamic>? profile = _findObject(node);
      for (
        var depth = 0;
        profile == null && depth < 3 && node is Map;
        depth++
      ) {
        final map = Map<String, dynamic>.from(node);
        if (map.containsKey('name')) {
          profile = map;
          break;
        }
        node = map['data'] ?? map['user'] ?? map['profile'];
      }
      return right(MessageProfileModel.fromJson(profile!));
    } catch (_) {
      return left(_parseError('the profile'));
    }
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
  Future<Either<AppException, ChatMessagePageModel>> getMessages(
    int conversationId, {
    required int page,
    required int perPage,
  }) async {
    final response = await _remoteDataSource.getMessages(
      conversationId,
      page: page,
      perPage: perPage,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(
        ChatMessagePageModel.fromResponse(
          response.getValue(),
          requestedPage: page,
          requestedPerPage: perPage,
        ),
      );
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
  Future<Either<AppException, ConversationModel?>> updateConversationTitle(
    int conversationId,
    String title,
  ) async {
    final response = await _remoteDataSource.updateConversationTitle(
      conversationId,
      title,
    );
    if (response.isError()) return left(ResponseHelper.error(response));
    // The rename has already happened by here, so a body this method cannot
    // read is not a failure: the caller patches the title it just sent.
    final Map<String, dynamic>? row = _findObject(response.getValue());
    if (row == null) return right(null);
    try {
      return right(ConversationModel.fromJson(row));
    } catch (_) {
      return right(null);
    }
  }

  @override
  Future<Either<AppException, bool>> leaveConversation(int conversationId) =>
      _action(_remoteDataSource.leaveConversation(conversationId));

  @override
  Future<Either<AppException, bool>> respondToConversationInvitation(
    int conversationId,
    bool accept,
  ) => _action(
    _remoteDataSource.respondToConversationInvitation(conversationId, accept),
  );

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
