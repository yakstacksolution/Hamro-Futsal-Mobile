import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';

enum _OpponentTab { create, requests }

enum _RequestFilter { all, open, settled }

extension on _OpponentTab {
  String get label => switch (this) {
    _OpponentTab.create => 'Create',
    _OpponentTab.requests => 'Requests',
  };
}

extension on _RequestFilter {
  String get label => switch (this) {
    _RequestFilter.all => 'All',
    _RequestFilter.open => 'Open',
    _RequestFilter.settled => 'Settled',
  };
}

class OpponentRequestScreen extends StatefulWidget {
  const OpponentRequestScreen({super.key});

  @override
  State<OpponentRequestScreen> createState() => _OpponentRequestScreenState();
}

class _OpponentRequestScreenState extends State<OpponentRequestScreen> {
  _OpponentTab _tab = _OpponentTab.create;
  _RequestFilter _requestFilter = _RequestFilter.all;
  int _selectedTeamIndex = 0;
  String _matchType = '5v5';
  String _level = 'Intermediate';
  DateTime _date = DateTime(2026, 5, 3);
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  String _venue = 'Green Turf Arena, Kathmandu';

  final List<String> _venues = const [
    'Green Turf Arena, Kathmandu',
    'Capital Futsal, Lalitpur',
    'Champions Court, Bhaktapur',
    'Soccer Pro Arena, Pulchowk',
  ];

  final _messageCtrl = TextEditingController(
    text: 'Looking for a friendly competitive futsal match.',
  );

  final List<_Team> _teams = [
    _Team(
      name: 'Kathmandu Strikers',
      players: [
        _Player(name: 'Aayush Karki', role: 'Forward'),
        _Player(name: 'Niraj Shrestha', role: 'Midfielder'),
        _Player(name: 'Samir Tamang', role: 'Defender'),
      ],
    ),
    _Team(
      name: 'Valley Five',
      players: [
        _Player(name: 'Rohit Rai', role: 'Goalkeeper'),
        _Player(name: 'Bishal Maharjan', role: 'Forward'),
      ],
    ),
  ];

  final List<_Request> _requests = [
    _Request(
      team: 'Royal Futsal Club',
      time: 'Today, 6:30 PM',
      level: 'Intermediate',
      status: 'New',
    ),
    _Request(
      team: 'Bhaktapur Warriors',
      time: 'Tomorrow, 5:00 PM',
      level: 'Advanced',
      status: 'Pending',
    ),
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  _Team get _selectedTeam => _teams[_selectedTeamIndex];

  bool _isOpen(_Request r) => r.status == 'New' || r.status == 'Pending';
  bool _isSettled(_Request r) =>
      r.status == 'Accepted' || r.status == 'Rejected' || r.status == 'Sent';

  int get _openCount => _requests.where(_isOpen).length;

  int _filterCount(_RequestFilter f) => switch (f) {
    _RequestFilter.all => _requests.length,
    _RequestFilter.open => _requests.where(_isOpen).length,
    _RequestFilter.settled => _requests.where(_isSettled).length,
  };

  List<_Request> get _filteredRequests {
    return switch (_requestFilter) {
      _RequestFilter.all => _requests,
      _RequestFilter.open => _requests.where(_isOpen).toList(),
      _RequestFilter.settled => _requests.where(_isSettled).toList(),
    };
  }

  int _tabCount(_OpponentTab tab) => switch (tab) {
    _OpponentTab.create => _teams.length,
    _OpponentTab.requests => _requests.length,
  };

  String get _formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[_date.month - 1]} ${_date.day.toString().padLeft(2, '0')}';
  }

  String get _formattedTime {
    final h = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final m = _time.minute.toString().padLeft(2, '0');
    final p = _time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: LightColor.secondaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: LightColor.secondaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _pickVenue() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => _VenuePickerSheet(
        venues: _venues,
        selected: _venue,
        onSelect: (v) {
          setState(() => _venue = v);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _sendRequest() {
    setState(() {
      _requests.insert(
        0,
        _Request(
          team: _selectedTeam.name,
          time: '$_formattedDate · $_formattedTime',
          level:
              '$_level · $_matchType · ${_selectedTeam.players.length} players',
          status: 'Sent',
        ),
      );
      _tab = _OpponentTab.requests;
      _requestFilter = _RequestFilter.settled;
    });
    _showToast('Request sent successfully');
  }

  void _updateStatus(int absIndex, String s) =>
      setState(() => _requests[absIndex].status = s);

  void _deleteRequest(int absIndex) =>
      setState(() => _requests.removeAt(absIndex));

  void _openCreateTeam() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _CreateTeamSheet(
          onCreate: (name) {
            setState(() {
              _teams.add(_Team(name: name));
              _selectedTeamIndex = _teams.length - 1;
            });
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _openAddPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddPlayerSheet(
          teamName: _selectedTeam.name,
          onAdd: (player) {
            setState(() => _selectedTeam.players.add(player));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _deletePlayer(int i) =>
      setState(() => _selectedTeam.players.removeAt(i));

  void _showToast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.inverseTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: LightColor.secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          margin: AppUtils().getMargin(
            horizontal: AppDimens.paddingX16,
            vertical: AppDimens.paddingX12,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  String _subtitleForTab() {
    if (_tab == _OpponentTab.create) {
      final players = _selectedTeam.players.length;
      return '$players ${players == 1 ? 'player' : 'players'} · $_matchType · $_level';
    }
    final total = _requests.length;
    return '$total ${total == 1 ? 'request' : 'requests'}'
        '${_openCount > 0 ? ' · $_openCount open' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Opponent Match'),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSubtitle(text: _subtitleForTab()),
            const SizedBox(height: AppDimens.paddingX12),
            _SegmentRow(
              selected: _tab,
              countFor: _tabCount,
              onChanged: (t) {
                if (_tab == t) return;
                setState(() => _tab = t);
              },
            ),
            const SizedBox(height: AppDimens.paddingX10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                child: _tab == _OpponentTab.create
                    ? _CreateView(
                        key: const ValueKey('c'),
                        messageCtrl: _messageCtrl,
                        teams: _teams,
                        selectedTeamIndex: _selectedTeamIndex,
                        matchType: _matchType,
                        level: _level,
                        dateLabel: _formattedDate,
                        timeLabel: _formattedTime,
                        venueLabel: _venue,
                        onTeamChanged: (i) =>
                            setState(() => _selectedTeamIndex = i),
                        onCreateTeam: _openCreateTeam,
                        onMatchType: (v) => setState(() => _matchType = v),
                        onLevel: (v) => setState(() => _level = v),
                        onAddPlayer: _openAddPlayer,
                        onDelPlayer: _deletePlayer,
                        onPickDate: _pickDate,
                        onPickTime: _pickTime,
                        onPickVenue: _pickVenue,
                        onSend: _sendRequest,
                      )
                    : _RequestsView(
                        key: const ValueKey('r'),
                        filter: _requestFilter,
                        filterCount: _filterCount,
                        requests: _filteredRequests,
                        onFilter: (f) => setState(() => _requestFilter = f),
                        onAccept: (r) {
                          final i = _requests.indexOf(r);
                          if (i >= 0) _updateStatus(i, 'Accepted');
                        },
                        onReject: (r) {
                          final i = _requests.indexOf(r);
                          if (i >= 0) _updateStatus(i, 'Rejected');
                        },
                        onDelete: (r) {
                          final i = _requests.indexOf(r);
                          if (i >= 0) _deleteRequest(i);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
class _Player {
  final String name;
  final String role;
  _Player({required this.name, required this.role});

  String get abbr {
    const map = {
      'Goalkeeper': 'GK',
      'Defender': 'DF',
      'Midfielder': 'MF',
      'Forward': 'FW',
    };
    return map[role] ?? role.substring(0, 2).toUpperCase();
  }
}

class _Team {
  final String name;
  final List<_Player> players;

  _Team({required this.name, List<_Player>? players}) : players = players ?? [];
}

class _Request {
  String team, time, level, status;
  _Request({
    required this.team,
    required this.time,
    required this.level,
    required this.status,
  });

  String get initials {
    final parts = team
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

// ─────────────────────────────────────────────
//  HEADER + SEGMENT
// ─────────────────────────────────────────────

class _HeaderSubtitle extends StatelessWidget {
  const _HeaderSubtitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Text(
          text,
          key: ValueKey(text),
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
          ),
        ),
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.selected,
    required this.countFor,
    required this.onChanged,
  });

  final _OpponentTab selected;
  final int Function(_OpponentTab) countFor;
  final ValueChanged<_OpponentTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
        ),
        itemCount: _OpponentTab.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (context, index) {
          final tab = _OpponentTab.values[index];
          return _ChipPill(
            label: tab.label,
            count: countFor(tab),
            isSelected: tab == selected,
            onTap: () => onChanged(tab),
          );
        },
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({
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

// ─────────────────────────────────────────────
//  CREATE VIEW
// ─────────────────────────────────────────────

class _CreateView extends StatelessWidget {
  const _CreateView({
    super.key,
    required this.messageCtrl,
    required this.teams,
    required this.selectedTeamIndex,
    required this.matchType,
    required this.level,
    required this.dateLabel,
    required this.timeLabel,
    required this.venueLabel,
    required this.onTeamChanged,
    required this.onCreateTeam,
    required this.onMatchType,
    required this.onLevel,
    required this.onAddPlayer,
    required this.onDelPlayer,
    required this.onPickDate,
    required this.onPickTime,
    required this.onPickVenue,
    required this.onSend,
  });

  final TextEditingController messageCtrl;
  final List<_Team> teams;
  final int selectedTeamIndex;
  final String matchType, level;
  final String dateLabel, timeLabel, venueLabel;
  final ValueChanged<int> onTeamChanged;
  final ValueChanged<String> onMatchType, onLevel;
  final VoidCallback onCreateTeam, onAddPlayer, onSend;
  final VoidCallback onPickDate, onPickTime, onPickVenue;
  final ValueChanged<int> onDelPlayer;

  @override
  Widget build(BuildContext context) {
    final team = teams[selectedTeamIndex];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        top: AppDimens.paddingX6,
        bottom: AppDimens.paddingX32,
      ),
      children: [
        const _SectionLabel('Your team'),
        _TeamCard(
          teams: teams,
          team: team,
          selectedTeamIndex: selectedTeamIndex,
          onTeamChanged: onTeamChanged,
          onCreateTeam: onCreateTeam,
          onAddPlayer: onAddPlayer,
          onDelPlayer: onDelPlayer,
        ),
        const SizedBox(height: AppDimens.paddingX18),

        const _SectionLabel('Match format'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Match Type'),
              Row(
                children: ['5v5', '6v6', '7v7']
                    .map(
                      (t) => Expanded(
                        child: Padding(
                          padding: AppUtils().getPadding(
                            right: AppDimens.paddingX6,
                          ),
                          child: _PillChip(
                            label: t,
                            active: matchType == t,
                            onTap: () => onMatchType(t),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppDimens.paddingX14),
              const _FieldLabel('Opponent Level'),
              Row(
                children: ['Beginner', 'Intermediate', 'Advanced']
                    .map(
                      (l) => Expanded(
                        child: Padding(
                          padding: AppUtils().getPadding(
                            right: AppDimens.paddingX6,
                          ),
                          child: _PillChip(
                            label: l,
                            active: level == l,
                            compact: true,
                            onTap: () => onLevel(l),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingX18),

        const _SectionLabel('Schedule & venue'),
        _Card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _PickerRow(
                icon: Icons.calendar_month_outlined,
                label: 'Date',
                value: dateLabel,
                onTap: onPickDate,
              ),
              const _RowDivider(),
              _PickerRow(
                icon: Icons.schedule_outlined,
                label: 'Time',
                value: timeLabel,
                onTap: onPickTime,
              ),
              const _RowDivider(),
              _PickerRow(
                icon: Icons.location_on_outlined,
                label: 'Venue',
                value: venueLabel,
                onTap: onPickVenue,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingX18),

        const _SectionLabel('Message'),
        _Card(
          child: _FieldRow(
            controller: messageCtrl,
            hint: 'Message',
            icon: Icons.chat_bubble_outline_rounded,
            maxLines: 3,
          ),
        ),
        const SizedBox(height: AppDimens.paddingX24),

        _PrimaryButton(
          label: 'Send Opponent Request',
          icon: Icons.send_rounded,
          onTap: onSend,
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.teams,
    required this.team,
    required this.selectedTeamIndex,
    required this.onTeamChanged,
    required this.onCreateTeam,
    required this.onAddPlayer,
    required this.onDelPlayer,
  });

  final List<_Team> teams;
  final _Team team;
  final int selectedTeamIndex;
  final ValueChanged<int> onTeamChanged;
  final VoidCallback onCreateTeam, onAddPlayer;
  final ValueChanged<int> onDelPlayer;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppDimens.sizeX40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: teams.length + 1,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimens.paddingX8),
              itemBuilder: (context, index) {
                if (index == teams.length) {
                  return _AddTeamChip(onTap: onCreateTeam);
                }
                return _TeamChip(
                  team: teams[index],
                  active: index == selectedTeamIndex,
                  onTap: () => onTeamChanged(index),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${team.players.length} ${team.players.length == 1 ? 'player' : 'players'}',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniButton(
                label: 'Add Player',
                icon: Icons.person_add_alt_1_rounded,
                onTap: onAddPlayer,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          if (team.players.isEmpty)
            _EmptyRoster(onAddPlayer: onAddPlayer)
          else
            Column(
              children: team.players.asMap().entries.map((entry) {
                final player = entry.value;
                final isLast = entry.key == team.players.length - 1;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppDimens.paddingX8,
                  ),
                  child: _RosterRow(
                    player: player,
                    onDelete: () => onDelPlayer(entry.key),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX14,
          symmetricVertical: AppDimens.paddingX14,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: LightColor.secondaryTextColor),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingX8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: LightColor.hintTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
      child: Divider(height: 1, color: LightColor.dividerColor),
    );
  }
}

// ─────────────────────────────────────────────
//  REQUESTS VIEW
// ─────────────────────────────────────────────

class _RequestsView extends StatelessWidget {
  const _RequestsView({
    super.key,
    required this.filter,
    required this.filterCount,
    required this.requests,
    required this.onFilter,
    required this.onAccept,
    required this.onReject,
    required this.onDelete,
  });

  final _RequestFilter filter;
  final int Function(_RequestFilter) filterCount;
  final List<_Request> requests;
  final ValueChanged<_RequestFilter> onFilter;
  final ValueChanged<_Request> onAccept, onReject, onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppDimens.sizeX32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX20,
            ),
            itemCount: _RequestFilter.values.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimens.paddingX8),
            itemBuilder: (_, i) {
              final f = _RequestFilter.values[i];
              return _ChipPillFilter(
                label: f.label,
                count: filterCount(f),
                isSelected: f == filter,
                onTap: () => onFilter(f),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimens.paddingX10),
        Expanded(
          child: requests.isEmpty
              ? _EmptyRequests(filter: filter)
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: AppUtils().getPadding(
                    symmetricHorizontal: AppDimens.paddingX20,
                    top: AppDimens.paddingX2,
                    bottom: AppDimens.paddingX50,
                  ),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.paddingX12),
                  itemBuilder: (_, i) => _RequestCard(
                    request: requests[i],
                    onAccept: () => onAccept(requests[i]),
                    onReject: () => onReject(requests[i]),
                    onDelete: () => onDelete(requests[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ChipPillFilter extends StatelessWidget {
  const _ChipPillFilter({
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? LightColor.secondaryColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor.withValues(alpha: 0.35)
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
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: AppDimens.paddingX6),
                Text(
                  count.toString(),
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: isSelected
                        ? LightColor.secondaryColor.withValues(alpha: 0.7)
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onDelete,
  });

  final _Request request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  bool get _isOpen => request.status == 'New' || request.status == 'Pending';

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final emphasised = request.status == 'New';

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        onTap: () {},
        onLongPress: () => _confirmDelete(context),
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            border: Border.all(
              color: emphasised
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
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                    ),
                    child: Text(
                      request.initials,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.secondaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.team,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: emphasised
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 9,
                              color: LightColor.hintTextColor,
                            ),
                            const SizedBox(width: AppDimens.paddingX4),
                            Flexible(
                              child: Text(
                                request.time,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyTextSmall?.copyWith(
                                  color: LightColor.hintTextColor,
                                  fontSize: AppDimens.fontBodySubTitle,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX8),
                  _StatusBadge(status: request.status),
                ],
              ),
              const SizedBox(height: AppDimens.paddingX10),
              Text(
                request.level,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX12),
              const Divider(
                height: 1,
                thickness: 1,
                color: LightColor.dividerColor,
              ),
              if (_isOpen)
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.close_rounded,
                        label: 'Reject',
                        onTap: onReject,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 18,
                      color: LightColor.dividerColor,
                    ),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Accept',
                        emphasised: true,
                        onTap: onAccept,
                      ),
                    ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        request.status == 'Accepted'
                            ? Icons.check_circle_rounded
                            : request.status == 'Rejected'
                            ? Icons.cancel_outlined
                            : Icons.outgoing_mail,
                        size: AppDimens.sizeX16,
                        color: LightColor.hintTextColor,
                      ),
                      const SizedBox(width: AppDimens.paddingX6),
                      Text(
                        request.status == 'Sent'
                            ? 'Awaiting reply'
                            : request.status,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => _ConfirmDeleteSheet(
        title: 'Remove request?',
        message:
            'This will remove the request from ${request.team}. You can\'t undo this.',
        onConfirm: () {
          Navigator.pop(ctx);
          onDelete();
        },
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests({required this.filter});

  final _RequestFilter filter;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final (title, body) = switch (filter) {
      _RequestFilter.all => (
        'No requests yet',
        'Create a request to challenge an opponent.',
      ),
      _RequestFilter.open => (
        'Nothing to act on',
        'Open requests will appear here.',
      ),
      _RequestFilter.settled => (
        'No settled requests',
        'Accepted, rejected and sent requests will show here.',
      ),
    };

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
                Icons.shield_outlined,
                size: 32,
                color: LightColor.secondaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              title,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              body,
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

// ─────────────────────────────────────────────
//  SHEETS
// ─────────────────────────────────────────────

class _VenuePickerSheet extends StatelessWidget {
  const _VenuePickerSheet({
    required this.venues,
    required this.selected,
    required this.onSelect,
  });

  final List<String> venues;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _SheetShell(
      title: 'Choose venue',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: venues.map((v) {
          final active = v == selected;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.paddingX8),
            child: Material(
              color: active
                  ? LightColor.secondaryColor.withValues(alpha: 0.08)
                  : LightColor.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                onTap: () => onSelect(v),
                child: Container(
                  padding: AppUtils().getPadding(
                    symmetricHorizontal: AppDimens.paddingX14,
                    symmetricVertical: AppDimens.paddingX14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                    border: Border.all(
                      color: active
                          ? LightColor.secondaryColor.withValues(alpha: 0.35)
                          : LightColor.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: active
                            ? LightColor.secondaryColor
                            : LightColor.secondaryTextColor,
                      ),
                      const SizedBox(width: AppDimens.paddingX12),
                      Expanded(
                        child: Text(
                          v,
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                      ),
                      if (active)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: LightColor.secondaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ConfirmDeleteSheet extends StatelessWidget {
  const _ConfirmDeleteSheet({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _SheetShell(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX20),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: _DangerButton(label: 'Remove', onTap: onConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateTeamSheet extends StatefulWidget {
  const _CreateTeamSheet({required this.onCreate});

  final ValueChanged<String> onCreate;

  @override
  State<_CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<_CreateTeamSheet> {
  final _teamCtrl = TextEditingController();

  @override
  void dispose() {
    _teamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Create Team',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetInput(
            controller: _teamCtrl,
            hint: 'Team name',
            icon: Icons.groups_2_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.sizeX20),
          _PrimaryButton(
            label: 'Create Team',
            icon: Icons.add_rounded,
            enabled: _teamCtrl.text.trim().isNotEmpty,
            onTap: () {
              final name = _teamCtrl.text.trim();
              if (name.isEmpty) return;
              widget.onCreate(name);
            },
          ),
        ],
      ),
    );
  }
}

class _AddPlayerSheet extends StatefulWidget {
  const _AddPlayerSheet({required this.teamName, required this.onAdd});

  final String teamName;
  final ValueChanged<_Player> onAdd;

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _nameCtrl = TextEditingController();
  String _pos = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Add Player',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetInput(
            controller: _nameCtrl,
            hint: 'Player name',
            icon: Icons.person_outline_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.sizeX14),
          Text(
            'Position in ${widget.teamName}',
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimens.sizeX8,
            crossAxisSpacing: AppDimens.sizeX8,
            childAspectRatio: 3.2,
            children: ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'].map((
              p,
            ) {
              final active = _pos == p;
              final textTheme = FutsalTheme.getTextTheme(context);
              return GestureDetector(
                onTap: () => setState(() => _pos = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? LightColor.secondaryColor
                        : LightColor.background,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    border: Border.all(
                      color: active
                          ? LightColor.secondaryColor
                          : LightColor.dividerColor,
                    ),
                  ),
                  child: Text(
                    p,
                    style: textTheme.bodyTextSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: active
                          ? LightColor.inverseTextColor
                          : LightColor.secondaryTextColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.sizeX20),
          _PrimaryButton(
            label: 'Add Player',
            icon: Icons.person_add_outlined,
            enabled: _nameCtrl.text.trim().isNotEmpty && _pos.isNotEmpty,
            onTap: () {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty || _pos.isEmpty) return;
              widget.onAdd(_Player(name: name, role: _pos));
            },
          ),
        ],
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * .86;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusX24),
            ),
          ),
          padding: AppUtils().getPadding(
            left: AppDimens.paddingX20,
            top: AppDimens.paddingX14,
            right: AppDimens.paddingX20,
            bottom: AppDimens.paddingX36,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: AppDimens.sizeX36,
                    height: AppDimens.sizeX3,
                    margin: AppUtils().getMargin(bottom: AppDimens.paddingX20),
                    decoration: BoxDecoration(
                      color: LightColor.dividerColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: FutsalTheme.getTextTheme(context).bodyTextLarge
                      ?.copyWith(
                        fontSize: AppDimens.fontHeadingSmall,
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED UI WIDGETS
// ─────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.paddingX14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TeamChip extends StatelessWidget {
  const _TeamChip({
    required this.team,
    required this.active,
    required this.onTap,
  });

  final _Team team;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 112),
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX8,
          ),
          decoration: BoxDecoration(
            color: active ? LightColor.secondaryColor : LightColor.background,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: active
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: active
                        ? LightColor.whiteColor
                        : LightColor.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? LightColor.whiteColor.withValues(alpha: 0.2)
                      : LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                ),
                child: Text(
                  '${team.players.length}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: AppDimens.fontBodySubTitle,
                    color: active
                        ? LightColor.whiteColor
                        : LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTeamChip extends StatelessWidget {
  const _AddTeamChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: Container(
          height: AppDimens.sizeX40,
          padding: AppUtils().getPadding(horizontal: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: LightColor.background,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: LightColor.dividerColor,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX18,
              ),
              const SizedBox(width: AppDimens.sizeX6),
              Text(
                'Team',
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColor.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.player, required this.onDelete});

  final _Player player;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX12,
        vertical: AppDimens.paddingX10,
      ),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimens.sizeX36,
            height: AppDimens.sizeX36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.cardColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX20),
              border: Border.all(color: LightColor.dividerColor),
            ),
            child: Text(
              player.abbr,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  player.role,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: LightColor.iconGrey,
              size: AppDimens.sizeX20,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.secondaryColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        onTap: onTap,
        child: Padding(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: LightColor.whiteColor, size: 16),
              const SizedBox(width: AppDimens.sizeX6),
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColor.whiteColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster({required this.onAddPlayer});

  final VoidCallback onAddPlayer;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onAddPlayer,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: Container(
        width: double.infinity,
        padding: AppUtils().getPadding(
          horizontal: AppDimens.paddingX14,
          vertical: AppDimens.paddingX18,
        ),
        decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          border: Border.all(color: LightColor.dividerColor),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LightColor.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: LightColor.dividerColor),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX20,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX8),
            Text(
              'Add players with position',
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX3),
            Text(
              'Goalkeeper, defender, midfielder, or forward',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX2,
        bottom: AppDimens.paddingX8,
      ),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(bottom: AppDimens.paddingX8),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: hint,
      hintText: hint,
      icon: icon,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : null,
      textInputAction: maxLines > 1 ? TextInputAction.newline : null,
      textCapitalization: TextCapitalization.sentences,
      isRequired: false,
    );
  }
}

class _SheetInput extends StatelessWidget {
  const _SheetInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: hint,
      hintText: hint,
      icon: icon,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      isRequired: false,
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool active, compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: compact ? AppDimens.sizeX36 : AppDimens.sizeX40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? LightColor.secondaryColor : LightColor.background,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: active
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: active
                  ? LightColor.whiteColor
                  : LightColor.secondaryTextColor,
            ),
          ),
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
    Color fg, bg;
    switch (status) {
      case 'Accepted':
        fg = LightColor.successColor;
        bg = LightColor.secondaryColor.withValues(alpha: 0.10);
        break;
      case 'Rejected':
        fg = LightColor.redColor;
        bg = LightColor.redLightColor;
        break;
      case 'Pending':
        fg = LightColor.warningColor;
        bg = LightColor.warningLightColor;
        break;
      case 'Sent':
        fg = LightColor.secondaryColor;
        bg = LightColor.secondaryColor.withValues(alpha: 0.10);
        break;
      case 'New':
        fg = LightColor.secondaryColor;
        bg = LightColor.secondaryColor.withValues(alpha: 0.10);
        break;
      default:
        fg = LightColor.secondaryTextColor;
        bg = LightColor.dividerColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        status,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1.0 : .45,
      child: Material(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          onTap: enabled ? onTap : null,
          child: Container(
            height: AppDimens.sizeX54,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: LightColor.whiteColor,
                  size: AppDimens.sizeX18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.background,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: onTap,
        child: Container(
          height: AppDimens.sizeX46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Text(
            label,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.redColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: onTap,
        child: Container(
          height: AppDimens.sizeX46,
          alignment: Alignment.center,
          child: Text(
            label,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.whiteColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
