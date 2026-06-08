import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/features/message/data/repositories/message_repository_impl.dart';
import 'package:hamro_footsall/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_page.dart';

/// Entry point for starting a chat from outside the inbox (e.g. the futsal
/// details "Hosted by" section).
class ChatLauncher {
  const ChatLauncher._();

  /// Starts (or reuses — the backend returns the existing conversation) a
  /// direct chat with [vendorId] via `POST /conversations/direct`, then opens
  /// the thread. Shows a blocking spinner while the conversation is created.
  static Future<void> startDirect(
    BuildContext context, {
    required int vendorId,
    int? venueId,
  }) async {
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

    if (!context.mounted) return;
    Navigator.of(context).pop(); // dismiss the spinner

    result.fold(
      (failure) =>
          AppUtils().showSnackBar(context, MsgType.error, failure.errorMessage),
      (conversation) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => MessageBloc(useCase),
            child: ChatPage(conversation: conversation),
          ),
        ),
      ),
    );
  }
}
