import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
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
  }) async {
    final key = '$vendorId:${venueId ?? 0}';
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
