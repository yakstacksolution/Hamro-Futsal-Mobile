import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

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
      backgroundColor: const Color(0xFFF4FBF7),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xFFEAF8F0),
                Color(0xFFF4FBF7),
                Color(0xFFFFFFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
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
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
              borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
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
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isUnread
              ? LightColor.secondary.withValues(alpha: 0.18)
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
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: NetworkImage(item.avatarUrl),
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
                          fontSize: 16.8,
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
                        fontSize: 12.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  item.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isUnread
                        ? const Color(0xFF4C5C72)
                        : LightColor.subtitleText.withValues(alpha: 0.70),
                    fontSize: 14.7,
                    height: 1.35,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    if (item.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF22C55E,
                          ).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Online',
                          style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Recent',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (item.canArchive)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFE11D48),
                          size: 22,
                        ),
                      )
                    else if (isUnread)
                      Container(
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: const BoxDecoration(
                          color: LightColor.secondary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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

// import 'package:flutter/material.dart';
// import 'package:hamro_footsall/core/theme/light_color.dart';

// class MessagesPage extends StatelessWidget {
//   const MessagesPage({super.key});

//   static const List<_MessageItem> _messages = <_MessageItem>[
//     _MessageItem(
//       name: 'Andy Robertson',
//       message: 'Oh yes, please send your booking details.',
//       time: '5m ago',
//       avatarUrl: 'https://i.pravatar.cc/150?img=12',
//       unreadCount: 2,
//       isActive: true,
//     ),
//     _MessageItem(
//       name: 'Giorgio Chiellini',
//       message: 'Hello sir, good morning.',
//       time: '30m ago',
//       avatarUrl: 'https://i.pravatar.cc/150?img=15',
//     ),
//     _MessageItem(
//       name: 'Alex Morgan',
//       message: 'I saw the futsal slot you posted yesterday.',
//       time: '09:30 am',
//       avatarUrl: 'https://i.pravatar.cc/150?img=32',
//     ),
//     _MessageItem(
//       name: 'Ilkay Gundogan',
//       message: 'Can we reschedule tonight’s booking?',
//       time: 'Yesterday',
//       avatarUrl: 'https://i.pravatar.cc/150?img=51',
//       canArchive: true,
//     ),
//     _MessageItem(
//       name: 'Megan Rapinoe',
//       message: 'Thanks, I will confirm the team shortly.',
//       time: '01:00 pm',
//       avatarUrl: 'https://i.pravatar.cc/150?img=47',
//     ),
//     _MessageItem(
//       name: 'Alessandro Bastoni',
//       message: 'Please share the location pin once again.',
//       time: '06:00 pm',
//       avatarUrl: 'https://i.pravatar.cc/150?img=58',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: <Color>[Color(0xFFF7FBF9), Color(0xFFF1F8F5)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Column(
//         children: <Widget>[
//           _MessagesHeader(),
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.only(top: 8),
//               decoration: const BoxDecoration(
//                 color: LightColor.surface,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
//               ),
//               child: Column(
//                 children: <Widget>[
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
//                     child: _SearchMessageField(),
//                   ),
//                   Expanded(
//                     child: ListView.separated(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.fromLTRB(20, 6, 20, 26),
//                       itemCount: _messages.length,
//                       separatorBuilder: (_, __) => Divider(
//                         height: 1,
//                         color: LightColor.divider.withValues(alpha: 0.85),
//                       ),
//                       itemBuilder: (BuildContext context, int index) {
//                         final _MessageItem item = _messages[index];
//                         return _MessageTile(item: item);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MessagesHeader extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
//       child: Row(
//         children: <Widget>[
//           _HeaderIconButton(icon: Icons.menu_rounded, onTap: () {}),
//           const Expanded(
//             child: Text(
//               'Messages',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: LightColor.titleTextColor,
//                 fontSize: 28,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: -0.6,
//               ),
//             ),
//           ),
//           _HeaderIconButton(icon: Icons.edit_outlined, onTap: () {}),
//           const SizedBox(width: 10),
//           Stack(
//             clipBehavior: Clip.none,
//             children: <Widget>[
//               _HeaderIconButton(
//                 icon: Icons.notifications_none_rounded,
//                 onTap: () {},
//               ),
//               Positioned(
//                 right: 10,
//                 top: 10,
//                 child: Container(
//                   width: 9,
//                   height: 9,
//                   decoration: const BoxDecoration(
//                     color: LightColor.red,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HeaderIconButton extends StatelessWidget {
//   const _HeaderIconButton({required this.icon, required this.onTap});

//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Ink(
//           width: 44,
//           height: 44,
//           decoration: BoxDecoration(
//             color: LightColor.surface,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: LightColor.successBorder.withValues(alpha: 0.9),
//             ),
//           ),
//           child: Icon(icon, color: LightColor.secondaryDark, size: 22),
//         ),
//       ),
//     );
//   }
// }

// class _SearchMessageField extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 58,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FBFA),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: LightColor.border.withValues(alpha: 0.65)),
//       ),
//       child: Row(
//         children: <Widget>[
//           Icon(
//             Icons.search_rounded,
//             color: LightColor.hintText.withValues(alpha: 0.95),
//             size: 26,
//           ),
//           const SizedBox(width: 12),
//           Text(
//             'Search message',
//             style: TextStyle(
//               color: LightColor.hintText.withValues(alpha: 0.95),
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MessageTile extends StatelessWidget {
//   const _MessageTile({required this.item});

//   final _MessageItem item;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Stack(
//             clipBehavior: Clip.none,
//             children: <Widget>[
//               CircleAvatar(
//                 radius: 28,
//                 backgroundImage: NetworkImage(item.avatarUrl),
//               ),
//               if (item.isActive)
//                 Positioned(
//                   right: 2,
//                   bottom: 2,
//                   child: Container(
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       color: LightColor.secondary,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     Expanded(
//                       child: Text(
//                         item.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: item.unreadCount > 0
//                               ? const Color(0xFF22314D)
//                               : LightColor.titleTextColor,
//                           fontSize: 17,
//                           fontWeight: item.unreadCount > 0
//                               ? FontWeight.w800
//                               : FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       item.time,
//                       style: TextStyle(
//                         color: LightColor.hintText.withValues(alpha: 0.95),
//                         fontSize: 13.5,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: <Widget>[
//                     Expanded(
//                       child: Text(
//                         item.message,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: item.unreadCount > 0
//                               ? const Color(0xFF4B5873)
//                               : LightColor.subtitleText.withValues(alpha: 0.68),
//                           fontSize: 15.5,
//                           fontWeight: item.unreadCount > 0
//                               ? FontWeight.w600
//                               : FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     if (item.canArchive)
//                       Container(
//                         width: 44,
//                         height: 44,
//                         decoration: BoxDecoration(
//                           color: LightColor.secondaryLight,
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: const Icon(
//                           Icons.delete_outline_rounded,
//                           color: LightColor.secondaryDark,
//                           size: 22,
//                         ),
//                       )
//                     else if (item.unreadCount > 0)
//                       Container(
//                         width: 26,
//                         height: 26,
//                         decoration: const BoxDecoration(
//                           color: LightColor.secondary,
//                           shape: BoxShape.circle,
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           item.unreadCount.toString(),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MessageItem {
//   const _MessageItem({
//     required this.name,
//     required this.message,
//     required this.time,
//     required this.avatarUrl,
//     this.unreadCount = 0,
//     this.isActive = false,
//     this.canArchive = false,
//   });

//   final String name;
//   final String message;
//   final String time;
//   final String avatarUrl;
//   final int unreadCount;
//   final bool isActive;
//   final bool canArchive;
// }
