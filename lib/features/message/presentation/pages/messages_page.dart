import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/data_source/message_data_source.dart';
import 'package:hamro_footsall/features/message/data/model/message_model.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_page.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/message_card.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/message_empty_view.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/message_filter_chip.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/message_search_field.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key, this.dataSource});

  final MessageDataSource? dataSource;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late final MessageDataSource _dataSource =
      widget.dataSource ?? MessageLocalDataSourceImpl();
  final _searchCtrl = TextEditingController();

  MessageFilter _selectedFilter = MessageFilter.all;
  String _query = '';
  List<MessageModel> _messages = const [];

  @override
  void initState() {
    super.initState();
    _dataSource.fetchMessages().then((messages) {
      if (mounted) setState(() => _messages = messages);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MessageModel> get _visibleMessages {
    Iterable<MessageModel> filtered = _messages;

    filtered = switch (_selectedFilter) {
      MessageFilter.all => filtered,
      MessageFilter.unread => filtered.where((m) => m.isUnread),
      MessageFilter.active => filtered.where((m) => m.isActive),
      MessageFilter.bookings => filtered.where((m) => m.isBooking),
    };

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      filtered = filtered.where(
        (m) =>
            m.name.toLowerCase().contains(q) ||
            m.message.toLowerCase().contains(q),
      );
    }

    return filtered.toList(growable: false);
  }

  int _filterCount(MessageFilter filter) => switch (filter) {
    MessageFilter.all => _messages.length,
    MessageFilter.unread => _messages.where((m) => m.isUnread).length,
    MessageFilter.active => _messages.where((m) => m.isActive).length,
    MessageFilter.bookings => _messages.where((m) => m.isBooking).length,
  };

  void _markRead(String id) {
    setState(() {
      _messages = _messages
          .map((m) => m.id == id ? m.copyWith(unreadCount: 0) : m)
          .toList(growable: false);
    });
  }

  /// Opens the conversation thread; reading it clears the unread badge.
  void _openChat(MessageModel item, {bool autofocusComposer = false}) {
    _markRead(item.id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(
          conversation: item,
          dataSource: _dataSource,
          autofocusComposer: autofocusComposer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleMessages;
    final int unreadTotal = _messages.fold<int>(
      0,
      (sum, m) => sum + m.unreadCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(conversationCount: _messages.length, unreadTotal: unreadTotal),
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
        _filterRow(),
        const SizedBox(height: AppDimens.paddingX10),
        Expanded(
          child: items.isEmpty
              ? MessageEmptyView(
                  isFiltered:
                      _selectedFilter != MessageFilter.all ||
                      _query.trim().isNotEmpty,
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: AppUtils().getPadding(
                    symmetricHorizontal: AppDimens.paddingX16,
                    top: AppDimens.paddingX6,
                    bottom: AppDimens.paddingX50,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.paddingX12),
                  itemBuilder: (_, i) => MessageCard(
                    item: items[i],
                    onTap: () => _openChat(items[i]),
                    onReply: () => _openChat(items[i], autofocusComposer: true),
                    onMarkRead: () => _markRead(items[i].id),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _filterRow() {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
        ),
        itemCount: MessageFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (context, index) {
          final filter = MessageFilter.values[index];
          return MessageFilterChip(
            label: filter.label,
            count: _filterCount(filter),
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
