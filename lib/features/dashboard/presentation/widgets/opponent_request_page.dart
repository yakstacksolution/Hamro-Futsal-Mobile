import 'package:flutter/material.dart';

class OpponentRequestScreen extends StatefulWidget {
  const OpponentRequestScreen({super.key});

  @override
  State<OpponentRequestScreen> createState() => _OpponentRequestScreenState();
}

class _OpponentRequestScreenState extends State<OpponentRequestScreen> {
  static const Color secondaryColor = Color(0xff2c7969);

  int selectedTab = 0;
  String matchType = '5v5';
  String level = 'Intermediate';

  final teamController = TextEditingController(text: 'Kathmandu Strikers');
  final messageController = TextEditingController(
    text: 'Looking for a friendly competitive futsal match.',
  );

  // New: dynamic list of players
  final List<Map<String, String>> players = [];

  final List<Map<String, String>> requests = [
    {
      'team': 'Royal Futsal Club',
      'time': 'Today, 6:30 PM',
      'level': 'Intermediate',
      'status': 'New',
    },
    {
      'team': 'Bhaktapur Warriors',
      'time': 'Tomorrow, 5:00 PM',
      'level': 'Advanced',
      'status': 'Pending',
    },
  ];

  @override
  void dispose() {
    teamController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void sendRequest() {
    setState(() {
      requests.insert(0, {
        'team': teamController.text.trim().isEmpty
            ? 'Your Team'
            : teamController.text.trim(),
        'time': 'May 03, 2026 · 6:00 PM',
        'level': level,
        'status': 'Sent',
      });
      selectedTab = 1;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request created successfully')),
      );
    }
  }

  void updateStatus(int index, String status) {
    setState(() {
      requests[index]['status'] = status;
    });
  }

  // ------------------ Player Management ------------------
  void _showAddPlayerSheet() {
    final nameController = TextEditingController();
    String selectedRole = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return GestureDetector(
            onTap: () => FocusScope.of(ctx).unfocus(),
            child: Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Add Player',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff101817),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Player Name',
                      prefixIcon: const Icon(
                        Icons.person_rounded,
                        color: secondaryColor,
                      ),
                      filled: true,
                      fillColor: const Color(0xffF6F8F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 18),
                  // Role selection
                  const Text(
                    'Position',
                    style: TextStyle(
                      color: Color(0xff6D7C78),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'].map(
                          (role) {
                            final active = selectedRole == role;
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() => selectedRole = role);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? secondaryColor
                                      : const Color(0xffF2F5F4),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : const Color(0xff4E5F5B),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Add Player button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed:
                          (nameController.text.trim().isNotEmpty &&
                              selectedRole.isNotEmpty)
                          ? () {
                              setState(() {
                                players.add({
                                  'name': nameController.text.trim(),
                                  'role': selectedRole,
                                });
                              });
                              Navigator.pop(ctx);
                            }
                          : null,
                      icon: const Icon(Icons.person_add_rounded),
                      label: const Text(
                        'Add Player',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: secondaryColor.withOpacity(
                          0.5,
                        ),
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deletePlayer(int index) {
    setState(() {
      players.removeAt(index);
    });
  }

  // ------------------ UI Build ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            _HeaderCard(),
            _SegmentTabs(
              selectedIndex: selectedTab,
              onChanged: (index) {
                setState(() => selectedTab = index);
              },
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: selectedTab == 0
                    ? _CreateRequestView(
                        key: const ValueKey('create'),
                        teamController: teamController,
                        messageController: messageController,
                        matchType: matchType,
                        level: level,
                        players: players,
                        onAddPlayer: _showAddPlayerSheet,
                        onDeletePlayer: _deletePlayer,
                        onMatchTypeChanged: (value) {
                          setState(() => matchType = value);
                        },
                        onLevelChanged: (value) {
                          setState(() => level = value);
                        },
                        onSend: sendRequest,
                      )
                    : _RequestListView(
                        key: const ValueKey('requests'),
                        requests: requests,
                        onAccept: (index) => updateStatus(index, 'Accepted'),
                        onReject: (index) => updateStatus(index, 'Rejected'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- Top Bar ----------------------
class _TopBar extends StatelessWidget {
  static const Color secondaryColor = Color(0xff2c7969);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: [
          _IconCircle(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const Spacer(),
          const Text(
            'Opponent Match',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xff101817),
            ),
          ),
          const Spacer(),
          const _IconCircle(icon: Icons.more_horiz_rounded),
        ],
      ),
    );
  }
}

// ---------------------- Header Card ----------------------
class _HeaderCard extends StatelessWidget {
  static const Color secondaryColor = Color(0xff2c7969);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withOpacity(.25),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(
              Icons.sports_soccer_rounded,
              size: 130,
              color: Colors.white.withOpacity(.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Find opponent instantly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ready for your\nnext futsal battle?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  _HeaderStat(title: 'Teams', value: '24'),
                  SizedBox(width: 12),
                  _HeaderStat(title: 'Open', value: '08'),
                  SizedBox(width: 12),
                  _HeaderStat(title: 'Today', value: '12'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------- Segment Tabs ----------------------
class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const Color secondaryColor = Color(0xff2c7969);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xffEAF0EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _TabButton(
            title: 'Create Request',
            active: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabButton(
            title: 'View Requests',
            active: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

// ---------------------- Create Request View (with player management) ----------------------
class _CreateRequestView extends StatelessWidget {
  const _CreateRequestView({
    super.key,
    required this.teamController,
    required this.messageController,
    required this.matchType,
    required this.level,
    required this.players,
    required this.onAddPlayer,
    required this.onDeletePlayer,
    required this.onMatchTypeChanged,
    required this.onLevelChanged,
    required this.onSend,
  });

  final TextEditingController teamController;
  final TextEditingController messageController;
  final String matchType;
  final String level;
  final List<Map<String, String>> players;
  final VoidCallback onAddPlayer;
  final ValueChanged<int> onDeletePlayer;
  final ValueChanged<String> onMatchTypeChanged;
  final ValueChanged<String> onLevelChanged;
  final VoidCallback onSend;

  // Helper to get abbreviation from full role name
  String _roleAbbreviation(String role) {
    switch (role) {
      case 'Goalkeeper':
        return 'GK';
      case 'Defender':
        return 'DF';
      case 'Midfielder':
        return 'MF';
      case 'Forward':
        return 'FW';
      default:
        return role.substring(0, 2).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        const _SectionTitle('Your Team'),
        _SmoothCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InputField(
                controller: teamController,
                label: 'Team Name',
                icon: Icons.groups_rounded,
              ),
              const SizedBox(height: 18),
              // Player avatars row (scrollable)
              SizedBox(
                height: 46,
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Existing player avatars with delete option
                            ...List.generate(players.length, (index) {
                              final player = players[index];
                              final roleText = _roleAbbreviation(
                                player['role'] ?? '',
                              );
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _PlayerAvatar(
                                  text: roleText,
                                  name: player['name'],
                                  onDelete: () => onDeletePlayer(index),
                                ),
                              );
                            }),
                            // Add button
                            GestureDetector(
                              onTap: onAddPlayer,
                              child: Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xff2c7969,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xff2c7969,
                                    ).withOpacity(0.4),
                                    width: 1.5,
                                    strokeAlign: BorderSide.strokeAlignInside,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Color(0xff2c7969),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${players.length} Player${players.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Color(0xff6D7C78),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Match Details'),
        _SmoothCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SmallLabel('Match Type'),
              Row(
                children: ['5v5', '6v6', '7v7'].map((item) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ChoicePill(
                        title: item,
                        active: matchType == item,
                        onTap: () => onMatchTypeChanged(item),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const _SmallLabel('Opponent Level'),
              Row(
                children: ['Beginner', 'Intermediate', 'Advanced'].map((item) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ChoicePill(
                        title: item,
                        active: level == item,
                        compact: true,
                        onTap: () => onLevelChanged(item),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Date',
                      value: 'May 03',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.access_time_rounded,
                      title: 'Time',
                      value: '6:00 PM',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _InfoTile(
                icon: Icons.location_on_rounded,
                title: 'Venue',
                value: 'Green Turf Arena, Kathmandu',
              ),
              const SizedBox(height: 16),
              _InputField(
                controller: messageController,
                label: 'Message',
                icon: Icons.chat_rounded,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _MainButton(
          title: 'Send Opponent Request',
          icon: Icons.send_rounded,
          onTap: onSend,
        ),
      ],
    );
  }
}

// ---------------------- Request List View ----------------------
class _RequestListView extends StatelessWidget {
  const _RequestListView({
    super.key,
    required this.requests,
    required this.onAccept,
    required this.onReject,
  });

  final List<Map<String, String>> requests;
  final ValueChanged<int> onAccept;
  final ValueChanged<int> onReject;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = requests[index];
        final status = item['status'] ?? '';

        return _SmoothCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xff2c7969).withOpacity(.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Color(0xff2c7969),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['team'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff101817),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['time']} · ${item['level']}',
                          style: const TextStyle(
                            color: Color(0xff6D7C78),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              if (status != 'Accepted' && status != 'Rejected') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineActionButton(
                        title: 'Reject',
                        color: const Color(0xffEF4444),
                        onTap: () => onReject(index),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FilledActionButton(
                        title: 'Accept',
                        onTap: () => onAccept(index),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ---------------------- Shared Widgets ----------------------

class _SmoothCard extends StatelessWidget {
  const _SmoothCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xffE6ECEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff2c7969)),
        filled: true,
        fillColor: const Color(0xffF6F8F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.title,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  final String title;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff2c7969);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: compact ? 42 : 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : const Color(0xffF2F5F4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xff4E5F5B),
            fontWeight: FontWeight.w900,
            fontSize: compact ? 12 : 14,
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF6F8F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff2c7969), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff8A9794),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff101817),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  const _MainButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff2c7969);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.28),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.title,
    required this.active,
    required this.onTap,
  });

  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            style: TextStyle(
              color: active ? const Color(0xff2c7969) : const Color(0xff6D7C78),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(.78),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Accepted':
        color = const Color(0xff2c7969);
        break;
      case 'Rejected':
        color = const Color(0xffEF4444);
        break;
      case 'Pending':
        color = const Color(0xffF59E0B);
        break;
      default:
        color = const Color(0xff2c7969);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff2c7969),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.title,
    required this.color,
    required this.onTap,
  });

  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

// New: PlayerAvatar with optional delete button
class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.text, this.name, this.onDelete});

  final String text;
  final String? name;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasDelete = onDelete != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xff2c7969).withOpacity(.12),
            shape: BoxShape.circle,
          ),
          child: Tooltip(
            message: name ?? '',
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xff2c7969),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (hasDelete)
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: Color(0xffEF4444),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Color(0xff101817), size: 20),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xff101817),
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xff6D7C78),
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}
