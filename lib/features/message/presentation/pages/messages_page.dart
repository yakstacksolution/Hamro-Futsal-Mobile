import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/data/repositories/message_repository_impl.dart';
import 'package:hamro_footsall/features/message/data/service/reverb_chat_socket_service.dart';
import 'package:hamro_footsall/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_page.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/message_card.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/message_empty_view.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/message_filter_chip.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/message_search_field.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MessageBloc(
              MessageUseCase(MessageRepositoryImpl()),
              socketService: ReverbChatSocketService.instance,
            )
            ..add(const LoadConversationsEvent()),
      child: const _MessagesView(),
    );
  }
}

class _MessagesView extends StatefulWidget {
  const _MessagesView();

  @override
  State<_MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<_MessagesView> {
  final _searchCtrl = TextEditingController();
  ConversationFilter _selectedFilter = ConversationFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ConversationModel> _visible(MessageState state) {
    Iterable<ConversationModel> filtered = state.conversations;

    filtered = switch (_selectedFilter) {
      ConversationFilter.all => filtered,
      ConversationFilter.unread => filtered.where((c) => c.isUnread),
      ConversationFilter.direct => filtered.where((c) => !c.isGroup),
      ConversationFilter.group => filtered.where((c) => c.isGroup),
    };

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      filtered = filtered.where(
        (c) =>
            c.displayTitle(state.currentUserId).toLowerCase().contains(q) ||
            (c.lastMessage ?? '').toLowerCase().contains(q),
      );
    }

    return filtered.toList(growable: false);
  }

  int _filterCount(MessageState state, ConversationFilter filter) =>
      switch (filter) {
        ConversationFilter.all => state.conversations.length,
        ConversationFilter.unread =>
          state.conversations.where((c) => c.isUnread).length,
        ConversationFilter.direct =>
          state.conversations.where((c) => !c.isGroup).length,
        ConversationFilter.group =>
          state.conversations.where((c) => c.isGroup).length,
      };

  /// Opens the thread; reading clears the unread badge (API + local).
  void _openChat(ConversationModel conversation) {
    final bloc = context.read<MessageBloc>();
    bloc.add(MarkConversationReadEvent(conversation.id));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ChatPage(conversation: conversation),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        final items = _visible(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              conversationCount: state.conversations.length,
              unreadTotal: state.unreadTotal,
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX20,
              ),
              child: MessageSearchField(
                controller: _searchCtrl,
                query: _query,
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            _filterRow(state),
            const SizedBox(height: AppDimens.paddingX10),
            Expanded(child: _body(state, items)),
          ],
        );
      },
    );
  }

  Widget _body(MessageState state, List<ConversationModel> items) {
    if (state.conversationsStatus == MessageStatus.initial ||
        state.conversationsStatus == MessageStatus.loading) {
      return const LoadingWidget();
    }
    if (state.conversationsStatus == MessageStatus.failure &&
        state.conversations.isEmpty) {
      return _LoadError(
        message: state.errorMessage ?? 'Could not load conversations.',
        onRetry: () =>
            context.read<MessageBloc>().add(const LoadConversationsEvent()),
      );
    }
    if (items.isEmpty) {
      return MessageEmptyView(
        isFiltered:
            _selectedFilter != ConversationFilter.all ||
            _query.trim().isNotEmpty,
      );
    }
    return RefreshIndicator(
      color: LightColor.secondaryColor,
      onRefresh: () async => context.read<MessageBloc>().add(
        const LoadConversationsEvent(silent: true),
      ),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX16,
          top: AppDimens.paddingX6,
          bottom: AppDimens.paddingX50,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimens.paddingX12),
        itemBuilder: (_, i) => MessageCard(
          conversation: items[i],
          currentUserId: context.read<MessageBloc>().state.currentUserId,
          onTap: () => _openChat(items[i]),
        ),
      ),
    );
  }

  Widget _filterRow(MessageState state) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
        ),
        itemCount: ConversationFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (context, index) {
          final filter = ConversationFilter.values[index];
          return MessageFilterChip(
            label: filter.label,
            count: _filterCount(state, filter),
            isSelected: _selectedFilter == filter,
            onTap: () {
              if (_selectedFilter == filter) return;
              setState(() => _selectedFilter = filter);
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.conversationCount, required this.unreadTotal});

  final int conversationCount;
  final int unreadTotal;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
        top: AppDimens.paddingX24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Messages',
            style: textTheme.bodyTextLarge?.copyWith(
              fontSize: AppDimens.fontHeadingSmall,
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          if (conversationCount > 0) ...[
            const SizedBox(height: AppDimens.paddingX4),
            Text(
              '$conversationCount conversations'
              '${unreadTotal > 0 ? ' · $unreadTotal unread' : ''}',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: LightColor.hintTextColor,
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),
            CustomButton(
              text: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
