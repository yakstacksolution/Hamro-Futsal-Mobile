import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

enum MessageFilter { all, unread, active, bookings }

extension on MessageFilter {
  String get label => switch (this) {
    MessageFilter.all => 'All',
    MessageFilter.unread => 'Unread',
    MessageFilter.active => 'Active',
    MessageFilter.bookings => 'Bookings',
  };
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  MessageFilter _selectedFilter = MessageFilter.all;
  String _query = '';
  late final TextEditingController _searchCtrl;
  late List<_MessageItem> _messages;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _messages = List<_MessageItem>.from(_seed);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static const List<_MessageItem> _seed = <_MessageItem>[
    _MessageItem(
      id: 'm1',
      name: 'Andy Robertson',
      message: 'Oh yes, please send your booking details.',
      time: '5m',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      unreadCount: 2,
      isActive: true,
      isBooking: true,
    ),
    _MessageItem(
      id: 'm2',
      name: 'Giorgio Chiellini',
      message: 'Hello sir, good morning.',
      time: '30m',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      isActive: true,
    ),
    _MessageItem(
      id: 'm3',
      name: 'Alex Morgan',
      message: 'I saw the futsal slot you posted yesterday.',
      time: '09:30',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      isBooking: true,
    ),
    _MessageItem(
      id: 'm4',
      name: 'Ilkay Gundogan',
      message: 'Can we reschedule tonight’s booking?',
      time: 'Yesterday',
      avatarUrl: 'https://i.pravatar.cc/150?img=51',
      isBooking: true,
    ),
    _MessageItem(
      id: 'm5',
      name: 'Megan Rapinoe',
      message: 'Thanks, I will confirm the team shortly.',
      time: '13:00',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    _MessageItem(
      id: 'm6',
      name: 'Alessandro Bastoni',
      message: 'Please share the location pin once again.',
      time: '18:00',
      avatarUrl: 'https://i.pravatar.cc/150?img=58',
      unreadCount: 1,
    ),
  ];

  List<_MessageItem> get _visibleMessages {
    Iterable<_MessageItem> filtered = _messages;

    filtered = switch (_selectedFilter) {
      MessageFilter.all => filtered,
      MessageFilter.unread => filtered.where((m) => m.unreadCount > 0),
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
    MessageFilter.unread => _messages.where((m) => m.unreadCount > 0).length,
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
        _pageHeader(context, unreadTotal: unreadTotal),
        const SizedBox(height: AppDimens.paddingX16),
        _searchField(context),
        const SizedBox(height: AppDimens.paddingX14),
        _filterRow(),
        const SizedBox(height: AppDimens.paddingX10),
        Expanded(
          child: items.isEmpty
              ? _emptyView(context)
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
                  itemBuilder: (_, i) => _MessageCard(
                    item: items[i],
                    onTap: () {},
                    onReply: () {},
                    onMarkRead: () => _markRead(items[i].id),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _pageHeader(BuildContext context, {required int unreadTotal}) {
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
          if (_messages.isNotEmpty) ...[
            const SizedBox(height: AppDimens.paddingX4),
            Text(
              '${_messages.length} conversations'
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

  Widget _searchField(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX20),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchCtrl,
          onChanged: (value) => setState(() => _query = value),
          cursorColor: LightColor.secondaryColor,
          textAlignVertical: TextAlignVertical.center,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: LightColor.whiteColor,
            hintText: 'Search conversations',
            hintStyle: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: LightColor.iconGrey,
              size: AppDimens.sizeX18,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            suffixIcon: _query.isEmpty
                ? null
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: LightColor.iconGrey,
                      size: AppDimens.sizeX16,
                    ),
                  ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              borderSide: const BorderSide(color: LightColor.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              borderSide: const BorderSide(color: LightColor.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              borderSide: const BorderSide(
                color: LightColor.secondaryColor,
                width: 1,
              ),
            ),
          ),
        ),
      ),
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
          return _FilterChipItem(
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

  Widget _emptyView(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isFiltered =
        _selectedFilter != MessageFilter.all || _query.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.search_off_rounded : Icons.forum_outlined,
                size: 32,
                color: LightColor.secondaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              isFiltered ? 'No matching conversations' : 'No messages yet',
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              isFiltered
                  ? 'Try a different filter or search term.'
                  : 'Your conversations will appear here.',
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isSelected
                      ? LightColor.whiteColor
                      : LightColor.secondaryTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: AppDimens.paddingX6),
                Text(
                  count.toString(),
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: isSelected
                        ? LightColor.whiteColor.withValues(alpha: 0.7)
                        : LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.item,
    required this.onTap,
    required this.onReply,
    required this.onMarkRead,
  });

  final _MessageItem item;
  final VoidCallback onTap;
  final VoidCallback onReply;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isUnread = item.unreadCount > 0;

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            border: Border.all(
              color: isUnread
                  ? LightColor.secondaryColor.withValues(alpha: 0.18)
                  : LightColor.dividerColor,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX14,
            AppDimens.paddingX14,
            AppDimens.paddingX14,
            AppDimens.paddingX8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: AppDimens.paddingX10),
              Text(
                item.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isUnread
                      ? LightColor.primaryTextColor
                      : LightColor.secondaryTextColor,
                  fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX12),
              const Divider(
                height: 1,
                thickness: 1,
                color: LightColor.dividerColor,
              ),
              _actionRow(context, isUnread: isUnread),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isUnread = item.unreadCount > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(url: item.avatarUrl, isActive: item.isActive),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: isUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                  ),
                  if (item.isBooking) ...[
                    const SizedBox(width: AppDimens.paddingX6),
                    const _BookingTag(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    item.isActive ? Icons.circle : Icons.access_time_rounded,
                    size: 9,
                    color: item.isActive
                        ? LightColor.secondaryColor
                        : LightColor.hintTextColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX4),
                  Text(
                    item.isActive ? 'Active now · ${item.time}' : item.time,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: AppDimens.fontBodySubTitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        if (isUnread) _UnreadBadge(count: item.unreadCount),
      ],
    );
  }

  Widget _actionRow(BuildContext context, {required bool isUnread}) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.reply_rounded,
            label: 'Reply',
            onTap: onReply,
          ),
        ),
        Container(width: 1, height: 18, color: LightColor.dividerColor),
        Expanded(
          child: _QuickAction(
            icon: isUnread
                ? Icons.mark_email_read_outlined
                : Icons.check_circle_outline_rounded,
            label: isUnread ? 'Mark read' : 'Read',
            onTap: isUnread ? onMarkRead : null,
            emphasised: isUnread,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool enabled = onTap != null;
    final Color color = !enabled
        ? LightColor.disabledTextColor
        : (emphasised
              ? LightColor.secondaryColor
              : LightColor.secondaryTextColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimens.sizeX16, color: color),
            const SizedBox(width: AppDimens.paddingX6),
            Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: color,
                fontWeight: emphasised ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTag extends StatelessWidget {
  const _BookingTag();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sports_soccer_rounded,
            size: 10,
            color: LightColor.secondaryColor,
          ),
          const SizedBox(width: 3),
          Text(
            'Booking',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.isActive});

  final String url;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: CustomImageView(
            url: url,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
        if (isActive)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: LightColor.cardColor, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: LightColor.whiteColor,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

class _MessageItem {
  const _MessageItem({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    this.unreadCount = 0,
    this.isActive = false,
    this.isBooking = false,
  });

  final String id;
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final bool isActive;
  final bool isBooking;

  _MessageItem copyWith({int? unreadCount}) => _MessageItem(
    id: id,
    name: name,
    message: message,
    time: time,
    avatarUrl: avatarUrl,
    unreadCount: unreadCount ?? this.unreadCount,
    isActive: isActive,
    isBooking: isBooking,
  );
}
