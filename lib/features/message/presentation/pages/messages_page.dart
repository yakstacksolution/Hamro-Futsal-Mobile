import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
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
import 'package:hamro_footsall/features/message/presentation/widgets/group_conversation_sheet.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MessageBloc(
        MessageUseCase(MessageRepositoryImpl()),
        socketService: ReverbChatSocketService.instance,
      )..add(const LoadConversationsEvent()),
      child: const _MessagesView(),
    );
  }
}

class _MessagesView extends StatefulWidget {
  const _MessagesView();

  @override
  State<_MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<_MessagesView>
    with WidgetsBindingObserver {
  final _searchCtrl = TextEditingController();
  late final MessageBloc _bloc;
  ConversationFilter _selectedFilter = ConversationFilter.all;
  String _query = '';
  Timer? _heartbeatTimer;
  Timer? _presenceRefreshTimer;
  bool _appActive = true;
  bool? _reportedOnline;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<MessageBloc>();
    WidgetsBinding.instance.addObserver(this);
    DashboardScreen.selectedNavIndex.addListener(_handleNavigationChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncOwnPresence();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DashboardScreen.selectedNavIndex.removeListener(_handleNavigationChanged);
    _stopHeartbeat();
    _stopPresenceRefresh();
    unawaited(_setOwnPresence(false));
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    _syncOwnPresence();
    if (!_appActive || !mounted) return;
    _bloc.add(
      LoadConversationsEvent(
        silent: _bloc.state.conversations.isNotEmpty,
        archived: _bloc.state.showingArchived,
      ),
    );
  }

  void _handleNavigationChanged() {
    _syncOwnPresence();
    _retryFailedFetchOnTabVisible();
  }

  void _syncOwnPresence() {
    final shouldBeOnline =
        mounted && _appActive && DashboardScreen.selectedNavIndex.value == 2;
    if (_reportedOnline == shouldBeOnline) return;
    _reportedOnline = shouldBeOnline;
    if (shouldBeOnline) {
      _startHeartbeat();
      _startPresenceRefresh();
    } else {
      _stopHeartbeat();
      _stopPresenceRefresh();
      unawaited(_setOwnPresence(false));
    }
  }

  void _startHeartbeat() {
    if (_heartbeatTimer?.isActive ?? false) return;
    unawaited(_sendHeartbeat());
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_sendHeartbeat()),
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _startPresenceRefresh() {
    if (_presenceRefreshTimer?.isActive ?? false) return;
    _presenceRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted ||
          !_appActive ||
          DashboardScreen.selectedNavIndex.value != 2) {
        return;
      }
      _bloc.add(
        LoadConversationsEvent(
          silent: true,
          archived: _bloc.state.showingArchived,
        ),
      );
    });
  }

  void _stopPresenceRefresh() {
    _presenceRefreshTimer?.cancel();
    _presenceRefreshTimer = null;
  }

  Future<void> _sendHeartbeat() async {
    if (!_appActive || DashboardScreen.selectedNavIndex.value != 2) return;
    final socketId = ReverbChatSocketService.instance.socketId?.trim();
    if (socketId == null || socketId.isEmpty) return;
    await _bloc.useCase.sendPresenceHeartbeat(socketId);
  }

  Future<void> _setOwnPresence(bool online) async {
    final result = await _bloc.useCase.setPresence(online);
    result.fold((_) {
      // Permit a later lifecycle/tab event to retry a failed presence update.
      if (_reportedOnline == online) _reportedOnline = null;
    }, (_) {});
  }

  void _retryFailedFetchOnTabVisible() {
    if (!mounted || DashboardScreen.selectedNavIndex.value != 2) return;
    if (_bloc.state.conversationsStatus == MessageStatus.failure) {
      _bloc.add(LoadConversationsEvent(archived: _bloc.state.showingArchived));
    }
  }

  List<ConversationModel> _visible(MessageState state) {
    Iterable<ConversationModel> filtered = state.conversations;

    filtered = switch (_selectedFilter) {
      ConversationFilter.all => filtered,
      ConversationFilter.unread => filtered.where((c) => c.isUnread),
      ConversationFilter.direct => filtered.where((c) => !c.isGroup),
      ConversationFilter.group => filtered.where((c) => c.isGroup),
      ConversationFilter.archived => filtered,
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
        ConversationFilter.archived =>
          state.showingArchived ? state.conversations.length : 0,
      };

  Future<void> _createGroup() async {
    final bloc = context.read<MessageBloc>();
    final draft = await showGroupConversationSheet(
      context: context,
      currentUserId: bloc.state.currentUserId,
      participants: bloc.state.conversations.expand(
        (conversation) => conversation.participants,
      ),
    );
    if (draft == null || !mounted) return;
    bloc.add(
      CreateGroupConversationEvent(
        title: draft.title,
        participantIds: draft.participantIds,
        venueId: draft.venueId,
      ),
    );
  }

  void _selectFilter(ConversationFilter filter) {
    if (_selectedFilter == filter) return;
    final wasArchived = _selectedFilter == ConversationFilter.archived;
    final showArchived = filter == ConversationFilter.archived;
    setState(() => _selectedFilter = filter);
    if (wasArchived != showArchived) {
      context.read<MessageBloc>().add(
        LoadConversationsEvent(archived: showArchived),
      );
    }
  }

  void _openChat(ConversationModel conversation) {
    final bloc = context.read<MessageBloc>();
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
    return BlocConsumer<MessageBloc, MessageState>(
      listenWhen: (previous, current) =>
          previous.createdGroup != current.createdGroup ||
          (previous.groupCreating &&
              current.errorMessage != previous.errorMessage),
      listener: (context, state) {
        final bloc = context.read<MessageBloc>();
        final created = state.createdGroup;
        if (created != null) {
          bloc.add(const ClearCreatedGroupEvent());
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: ChatPage(conversation: created),
              ),
            ),
          );
          return;
        }
        if (state.errorMessage != null) {
          AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
          bloc.add(const ClearMessageActionEvent());
        }
      },
      builder: (context, state) {
        final items = _visible(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              conversationCount: state.conversations.length,
              unreadTotal: state.unreadTotal,
              showCreateGroup: !state.showingArchived,
              isCreatingGroup: state.groupCreating,
              onCreateGroup: _createGroup,
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
        onRetry: () => context.read<MessageBloc>().add(
          LoadConversationsEvent(archived: state.showingArchived),
        ),
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
        LoadConversationsEvent(silent: true, archived: state.showingArchived),
      ),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX16,
          top: AppDimens.paddingX6,
          bottom: state.showingArchived ? AppDimens.paddingX50 : 110,
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
            onTap: () => _selectFilter(filter),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.conversationCount,
    required this.unreadTotal,
    required this.showCreateGroup,
    required this.isCreatingGroup,
    required this.onCreateGroup,
  });

  final int conversationCount;
  final int unreadTotal;
  final bool showCreateGroup;
  final bool isCreatingGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX10,
        top: AppDimens.paddingX24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringConstants.messages,
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
          ),
          if (showCreateGroup)
            TextButton.icon(
              onPressed: isCreatingGroup ? null : onCreateGroup,
              icon: isCreatingGroup
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.group_add_rounded, size: 14),
              label: Text(
                isCreatingGroup ? 'Creating...' : 'Create group',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: LightColor.secondaryColor,
              ),
            ),
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
              text: StringConstants.retry,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
