import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';

abstract class MessageRemoteDataSource {
  Future<Result> getConversations({bool archived = false});
  Future<Result> startDirectConversation({required int vendorId, int? venueId});
  Future<Result> createGroupConversation({
    required String title,
    required List<int> participantIds,
    int? venueId,
  });
  Future<Result> addConversationParticipants(
    int conversationId,
    List<int> participantIds,
  );
  Future<Result> getConversationDetails(int conversationId);
  Future<Result> getUserPresence(int userId);
  Future<Result> setPresence(bool online);
  Future<Result> sendPresenceHeartbeat(String socketId);
  Future<Result> getMessages(int conversationId);
  Future<Result> sendMessage(
    int conversationId, {
    required ChatSendRequest request,
  });
  Future<Result> markRead(int conversationId);
  Future<Result> setTyping(int conversationId, bool typing);
  Future<Result> setArchived(int conversationId, bool archived);
  Future<Result> setMuted(int conversationId, bool muted);
  Future<Result> setParticipantBlocked(
    int conversationId,
    int userId,
    bool blocked, {
    String? reason,
  });
  Future<Result> deleteMessage(int messageId);
  Future<Result<Uint8List, DataError>> getMediaBytes(int mediaId);
}

final class MessageRemoteDataSourceImpl extends MessageRemoteDataSource {
  @override
  Future<Result> getConversations({bool archived = false}) async =>
      await Client.instance().getAuthManager().getConversations(
        archived: archived,
      );

  @override
  Future<Result> startDirectConversation({
    required int vendorId,
    int? venueId,
  }) async => await Client.instance().getAuthManager().startDirectConversation({
    'vendor_id': vendorId,
    if (venueId != null) 'venue_id': venueId,
  });

  @override
  Future<Result> createGroupConversation({
    required String title,
    required List<int> participantIds,
    int? venueId,
  }) async => await Client.instance().getAuthManager().createGroupConversation({
    'title': title.trim(),
    'participant_ids': participantIds,
    if (venueId != null) 'venue_id': venueId,
  });

  @override
  Future<Result> addConversationParticipants(
    int conversationId,
    List<int> participantIds,
  ) async => await Client.instance()
      .getAuthManager()
      .addConversationParticipants(conversationId, participantIds);

  @override
  Future<Result> getConversationDetails(int conversationId) async =>
      await Client.instance().getAuthManager().getConversationDetails(
        conversationId,
      );

  @override
  Future<Result> getUserPresence(int userId) async =>
      await Client.instance().getAuthManager().getUserPresence(userId);

  @override
  Future<Result> setPresence(bool online) async =>
      await Client.instance().getAuthManager().setPresence(online);

  @override
  Future<Result> sendPresenceHeartbeat(String socketId) async =>
      await Client.instance().getAuthManager().sendPresenceHeartbeat(socketId);

  @override
  Future<Result> getMessages(int conversationId) async =>
      await Client.instance().getAuthManager().getConversationMessages(
        conversationId,
      );

  @override
  Future<Result> sendMessage(
    int conversationId, {
    required ChatSendRequest request,
  }) async {
    final form = FormData();
    form.fields.add(MapEntry('type', request.resolvedType));
    if (request.body.trim().isNotEmpty) {
      form.fields.add(MapEntry('body', request.body.trim()));
    }
    if (request.replyToMessageId != null) {
      form.fields.add(
        MapEntry('reply_to_message_id', request.replyToMessageId.toString()),
      );
    }
    final metadata = request.metadata;
    if (metadata is Map) {
      for (final entry in metadata.entries) {
        final value = entry.value;
        if (value is Iterable) {
          for (final item in value) {
            form.fields.add(MapEntry('metadata[${entry.key}][]', '$item'));
          }
        } else {
          form.fields.add(MapEntry('metadata[${entry.key}]', '$value'));
        }
      }
    } else if (metadata is Iterable) {
      for (final item in metadata) {
        form.fields.add(MapEntry('metadata[]', '$item'));
      }
    }
    for (final path in request.filePaths.take(ChatSendRequest.maxFiles)) {
      form.files.add(
        MapEntry(
          'files[]',
          await MultipartFile.fromFile(path, filename: path.split('/').last),
        ),
      );
    }
    return await Client.instance().getAuthManager().sendConversationMessage(
      conversationId,
      form,
    );
  }

  @override
  Future<Result> markRead(int conversationId) async => await Client.instance()
      .getAuthManager()
      .markConversationRead(conversationId);

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
  Future<Result> setParticipantBlocked(
    int conversationId,
    int userId,
    bool blocked, {
    String? reason,
  }) async => blocked
      ? await Client.instance().getAuthManager().blockConversationParticipant(
          conversationId,
          userId,
          reason: reason,
        )
      : await Client.instance().getAuthManager().unblockConversationParticipant(
          conversationId,
          userId,
        );

  @override
  Future<Result> deleteMessage(int messageId) async =>
      await Client.instance().getAuthManager().deleteChatMessage(messageId);

  @override
  Future<Result<Uint8List, DataError>> getMediaBytes(int mediaId) async {
    try {
      final response = await Dio().get<List<int>>(
        '${APIEndpoint.baseUrl}/chat/media/$mediaId',
        options: Options(
          responseType: ResponseType.bytes,
          headers: <String, dynamic>{
            'Accept': '*/*',
            'X-API-TOKEN': dotenv.env['SECURE_API_TOKEN'] ?? 'hello',
            if (AppSettings().tokenModel.accessToken case final token?)
              'Authorization': 'Bearer $token',
            'User-Agent': ' okhttp',
          },
        ),
      );
      return Result.success(Uint8List.fromList(response.data ?? const <int>[]));
    } on DioException catch (error) {
      return Result.error(
        DataError(
          error.message ?? 'Could not download chat media.',
          error.response?.statusCode ?? 0,
          error.response?.data,
        ),
      );
    } catch (error) {
      return Result.error(DataError(error.toString(), 0, null));
    }
  }
}
