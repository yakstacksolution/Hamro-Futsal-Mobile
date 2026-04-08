import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static const List<_MessageItem> _messages = <_MessageItem>[
    _MessageItem(
      name: 'Andy Robertson',
      message: 'Oh yes, please send your booking details.',
      time: '5m ago',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      unreadCount: 2,
      isActive: true,
    ),
    _MessageItem(
      name: 'Giorgio Chiellini',
      message: 'Hello sir, good morning.',
      time: '30m ago',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      isActive: true,
    ),
    _MessageItem(
      name: 'Alex Morgan',
      message: 'I saw the futsal slot you posted yesterday.',
      time: '09:30 am',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
    ),
    _MessageItem(
      name: 'Ilkay Gundogan',
      message: 'Can we reschedule tonight’s booking?',
      time: 'Yesterday',
      avatarUrl: 'https://i.pravatar.cc/150?img=51',
      canArchive: true,
    ),
    _MessageItem(
      name: 'Megan Rapinoe',
      message: 'Thanks, I will confirm the team shortly.',
      time: '01:00 pm',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    _MessageItem(
      name: 'Alessandro Bastoni',
      message: 'Please share the location pin once again.',
      time: '06:00 pm',
      avatarUrl: 'https://i.pravatar.cc/150?img=58',
      unreadCount: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.surface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: LightColor.surface,
          // gradient: LinearGradient(
          //   colors: <Color>[
          //     Color(0xFFEAF8F0),
          //     Color(0xFFF4FBF7),
          //     Color(0xFFFFFFFF),
          //   ],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 6),
            const _MessagesHeader(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _SearchMessageField(),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _FilterTabs(),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (BuildContext context, int index) {
                  final _MessageItem item = _messages[index];
                  return _MessageTile(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: <Widget>[
          const Column(
            children: <Widget>[
              Text(
                'Messages',
                style: TextStyle(
                  color: LightColor.titleTextColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: LightColor.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: LightColor.successBorder.withValues(alpha: 0.65),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: LightColor.secondaryDark, size: 21),
        ),
      ),
    );
  }
}

class _SearchMessageField extends StatelessWidget {
  const _SearchMessageField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.border.withValues(alpha: 0.45)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            color: LightColor.hintText.withValues(alpha: 0.95),
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search messages.',
              style: TextStyle(
                color: LightColor.hintText.withValues(alpha: 0.95),
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LightColor.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: LightColor.secondaryDark,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _FilterChipItem(title: 'All Chats', isSelected: true),
          SizedBox(width: 10),
          _FilterChipItem(title: 'Unread'),
          SizedBox(width: 10),
          _FilterChipItem(title: 'Active'),
          SizedBox(width: 10),
          _FilterChipItem(title: 'Bookings'),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({required this.title, this.isSelected = false});

  final String title;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? LightColor.secondary : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? LightColor.secondary
              : LightColor.border.withValues(alpha: 0.45),
        ),
        boxShadow: isSelected
            ? <BoxShadow>[
                BoxShadow(
                  color: LightColor.secondary.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : LightColor.titleTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.item});

  final _MessageItem item;

  @override
  Widget build(BuildContext context) {
    final bool isUnread = item.unreadCount > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUnread
              ? LightColor.secondary.withValues(alpha: 0.12)
              : LightColor.border.withValues(alpha: 0.30),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: LightColor.secondary.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomImageView(
                    url: item.avatarUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (item.isActive)
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF1C2B3A),
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w800
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.time,
                      style: TextStyle(
                        color: LightColor.hintText.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isUnread
                              ? const Color(0xFF4C5C72)
                              : LightColor.subtitleText.withValues(alpha: 0.70),
                          fontSize: 12,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(width: 8),
                        if (item.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: LightColor.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageItem {
  const _MessageItem({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    this.unreadCount = 0,
    this.isActive = false,
    this.canArchive = false,
  });

  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final bool isActive;
  final bool canArchive;
}
