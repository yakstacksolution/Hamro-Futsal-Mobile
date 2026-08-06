import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/message/data/repositories/message_repository_impl.dart';
import 'package:hamro_footsall/features/message/data/service/reverb_chat_socket_service.dart';
import 'package:hamro_footsall/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_page.dart';

class ChatLauncher {
  const ChatLauncher._();

  static final Set<String> _opening = <String>{};

  static Future<void> startDirect(
    BuildContext context, {
    required int vendorId,
    int? venueId,
  }) {
    if (vendorId <= 0) return Future<void>.value();
    // Messaging your own venue would be a conversation with yourself, which the
    // API rejects with a 422 — say so instead of firing a doomed request.
    if (vendorId == _currentUserId()) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.cannotChatWithYourself,
      );
      return Future<void>.value();
    }
    return _start(
      context,
      key: '$vendorId:${venueId ?? 0}',
      vendorId: vendorId,
      venueId: venueId,
    );
  }

  /// Direct user↔user chat — e.g. messaging the requester of an opponent
  /// match request.
  static Future<void> startDirectUser(
    BuildContext context, {
    required int userId,
    int? vendorId,
    int? venueId,
  }) {
    if (userId <= 0) return Future<void>.value();
    final int me = _currentUserId();
    if (userId == me) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.cannotChatWithYourself,
      );
      return Future<void>.value();
    }
    // `vendor_id` is mandatory on this endpoint, so it is always forwarded —
    // it must carry the booking's vendor record id, not a participant user id.
    return _start(
      context,
      key: 'u:$userId:${vendorId ?? 0}:${venueId ?? 0}',
      userId: userId,
      vendorId: vendorId,
      venueId: venueId,
    );
  }

  /// The signed-in user's id, taken from the access token's `sub` claim.
  static int _currentUserId() => MessageRepositoryImpl().currentUserId;

  static Future<void> _start(
    BuildContext context, {
    required String key,
    int? vendorId,
    int? venueId,
    int? userId,
  }) async {
    if (!_opening.add(key)) return;
    final useCase = MessageUseCase(MessageRepositoryImpl());

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: LightColor.secondaryColor),
      ),
    );

    final result = await useCase.startDirectConversation(
      vendorId: vendorId,
      venueId: venueId,
      userId: userId,
    );
    _opening.remove(key);

    if (!context.mounted) return;
    Navigator.of(context).pop();

    result.fold(
      (failure) =>
          AppUtils().showSnackBar(context, MsgType.error, failure.errorMessage),
      (conversation) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => MessageBloc(
              useCase,
              socketService: ReverbChatSocketService.instance,
            ),
            child: ChatPage(conversation: conversation),
          ),
        ),
      ),
    );
  }
}
