import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';

class OpponentRequestScreen extends StatefulWidget {
  const OpponentRequestScreen({super.key});

  @override
  State<OpponentRequestScreen> createState() => _OpponentRequestScreenState();
}

class _OpponentRequestScreenState extends State<OpponentRequestScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  int _selectedTeamIndex = 0;
  String _matchType = '5v5';
  String _level = 'Intermediate';

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

  late AnimationController _heroAnim;
  late Animation<double> _heroPulse;

  @override
  void initState() {
    super.initState();
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _heroPulse = Tween<double>(
      begin: .45,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _heroAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _heroAnim.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  _Team get _selectedTeam => _teams[_selectedTeamIndex];

  void _sendRequest() {
    setState(() {
      _requests.insert(
        0,
        _Request(
          team: _selectedTeam.name,
          time: 'May 03, 2026 · 6:00 PM',
          level:
              '$_level · $_matchType · ${_selectedTeam.players.length} players',
          status: 'Sent',
        ),
      );
      _tab = 1;
    });
    _showToast('Request sent successfully!');
  }

  void _updateStatus(int i, String s) =>
      setState(() => _requests[i].status = s);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            HeroCard(
              pulseAnim: _heroPulse,
              teamCount: _teams.length,
              playerCount: _teams.fold<int>(
                0,
                (total, team) => total + team.players.length,
              ),
              selectedTeamName: _selectedTeam.name,
            ),
            _SegmentControl(
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                child: _tab == 0
                    ? _CreateView(
                        key: const ValueKey('c'),
                        messageCtrl: _messageCtrl,
                        teams: _teams,
                        selectedTeamIndex: _selectedTeamIndex,
                        matchType: _matchType,
                        level: _level,
                        onTeamChanged: (i) =>
                            setState(() => _selectedTeamIndex = i),
                        onCreateTeam: _openCreateTeam,
                        onMatchType: (v) => setState(() => _matchType = v),
                        onLevel: (v) => setState(() => _level = v),
                        onAddPlayer: _openAddPlayer,
                        onDelPlayer: _deletePlayer,
                        onSend: _sendRequest,
                      )
                    : _RequestsView(
                        key: const ValueKey('r'),
                        requests: _requests,
                        onAccept: (i) => _updateStatus(i, 'Accepted'),
                        onReject: (i) => _updateStatus(i, 'Rejected'),
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
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX16,
        top: AppDimens.paddingX12,
        right: AppDimens.paddingX16,
        bottom: AppDimens.paddingX8,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: AppDimens.sizeX20,
              color: LightColor.primaryTextColor,
            ),
          ),
          SizedBox(width: AppDimens.sizeX20),
          Text(
            'Opponent Match',
            style: textTheme.bodyTextLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColor.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.pulseAnim,
    required this.teamCount,
    required this.playerCount,
    required this.selectedTeamName,
  });

  final Animation<double> pulseAnim;
  final int teamCount;
  final int playerCount;
  final String selectedTeamName;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      margin: AppUtils().getMargin(
        left: AppDimens.marginX16,
        right: AppDimens.marginX16,
        top: AppDimens.marginX4,
        bottom: AppDimens.marginX10,
      ),
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: .10),
            blurRadius: AppDimens.radiusX18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimens.sizeX42,
                height: AppDimens.sizeX42,
                decoration: BoxDecoration(
                  color: LightColor.secondarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX22,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FadeTransition(
                          opacity: pulseAnim,
                          child: Container(
                            width: AppDimens.sizeX6,
                            height: AppDimens.sizeX6,
                            decoration: const BoxDecoration(
                              color: LightColor.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sizeX6),
                        Text(
                          'Matchmaking Ready',
                          style: textTheme.bodySubTitle?.copyWith(
                            color: LightColor.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.sizeX4),
                    Text(
                      selectedTeamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: AppUtils().getPadding(
                  horizontal: AppDimens.paddingX12,
                  vertical: AppDimens.paddingX4,
                ),
                decoration: BoxDecoration(
                  color: LightColor.background,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX50),
                  border: Border.all(color: LightColor.greyBorderColor),
                ),
                child: Text(
                  'Open',
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.successColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Container(
            padding: AppUtils().getPadding(
              horizontal: AppDimens.paddingX12,
              vertical: AppDimens.paddingX10,
            ),
            decoration: BoxDecoration(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              border: Border.all(color: LightColor.greyBorderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    icon: Icons.groups_2_outlined,
                    value: '$teamCount',
                    label: 'Teams',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _HeroStat(
                    icon: Icons.person_outline_rounded,
                    value: '$playerCount',
                    label: 'Players',
                  ),
                ),
                const _StatDivider(),
                const Expanded(
                  child: _HeroStat(
                    icon: Icons.sports_soccer_rounded,
                    value: '08',
                    label: 'Open',
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    final Color iconBgColor = LightColor.secondaryColor.withValues(alpha: 0.18);
    final Color iconColor = LightColor.secondaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimens.sizeX34,
          height: AppDimens.sizeX34,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX4),
          ),
          child: Icon(icon, color: iconColor, size: AppDimens.sizeX16),
        ),
        const SizedBox(width: AppDimens.sizeX8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySubTitle?.copyWith(
                  color: LightColor.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.sizeX1,
      height: AppDimens.sizeX30,
      margin: AppUtils().getMargin(horizontal: AppDimens.marginX8),
      color: LightColor.greyBorderColor,
    );
  }
}

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppUtils().getMargin(
        left: AppDimens.marginX16,
        right: AppDimens.marginX16,
        bottom: AppDimens.marginX12,
      ),
      padding: AppUtils().getPadding(all: AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        children: [
          _SegTab(
            title: 'Create Request',
            active: selected == 0,
            onTap: () => onChanged(0),
          ),
          _SegTab(
            title: 'View Requests',
            active: selected == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _SegTab extends StatelessWidget {
  const _SegTab({
    required this.title,
    required this.active,
    required this.onTap,
  });
  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: AppDimens.sizeX40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? LightColor.secondaryColor
                : LightColor.transparentColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          child: Text(
            title,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: active
                  ? LightColor.inverseTextColor
                  : LightColor.secondaryTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateView extends StatelessWidget {
  const _CreateView({
    super.key,
    required this.messageCtrl,
    required this.teams,
    required this.selectedTeamIndex,
    required this.matchType,
    required this.level,
    required this.onTeamChanged,
    required this.onCreateTeam,
    required this.onMatchType,
    required this.onLevel,
    required this.onAddPlayer,
    required this.onDelPlayer,
    required this.onSend,
  });

  final TextEditingController messageCtrl;
  final List<_Team> teams;
  final int selectedTeamIndex;
  final String matchType, level;
  final ValueChanged<int> onTeamChanged;
  final ValueChanged<String> onMatchType, onLevel;
  final VoidCallback onCreateTeam, onAddPlayer, onSend;
  final ValueChanged<int> onDelPlayer;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final team = teams[selectedTeamIndex];
    return ListView(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX16,
        top: AppDimens.paddingX2,
        right: AppDimens.paddingX16,
        bottom: AppDimens.paddingX32,
      ),
      children: [
        const _SectionLabel('Select Team'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: AppDimens.sizeX44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: teams.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppDimens.sizeX8),
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                  ),
                  _MiniButton(
                    label: 'Add Player',
                    icon: Icons.person_add_alt_1_rounded,
                    onTap: onAddPlayer,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX12),
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
              const SizedBox(height: AppDimens.sizeX12),
              Container(
                padding: AppUtils().getPadding(
                  horizontal: AppDimens.paddingX12,
                  vertical: AppDimens.paddingX10,
                ),
                decoration: BoxDecoration(
                  color: LightColor.background,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                  border: Border.all(color: LightColor.greyBorderColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: LightColor.secondaryColor,
                      size: AppDimens.sizeX16,
                    ),
                    const SizedBox(width: AppDimens.sizeX8),
                    Expanded(
                      child: Text(
                        '${team.players.length} selected player${team.players.length == 1 ? '' : 's'} for this request',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const _SectionLabel('Match Details'),
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
              const SizedBox(height: 16),
              const _FieldLabel('Opponent Level'),
              Row(
                children: ['Beginner', 'Intermediate', 'Advanced']
                    .map(
                      (l) => Expanded(
                        child: Padding(
                          padding: AppUtils().getPadding(
                            right: AppDimens.paddingX4,
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
              const SizedBox(height: AppDimens.sizeX16),
              Row(
                children: const [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.calendar_month_outlined,
                      label: 'Date',
                      value: 'May 03',
                    ),
                  ),
                  SizedBox(width: AppDimens.sizeX8),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.schedule_outlined,
                      label: 'Time',
                      value: '6:00 PM',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX8),
              const _InfoTile(
                icon: Icons.location_on_outlined,
                label: 'Venue',
                value: 'Green Turf Arena, Kathmandu',
                fullWidth: true,
              ),
              const SizedBox(height: AppDimens.sizeX14),

              _FieldRow(
                controller: messageCtrl,
                hint: 'Message',
                icon: Icons.chat_bubble_outline_rounded,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.sizeX20),

        _PrimaryButton(
          label: 'Send Opponent Request',
          icon: Icons.send_rounded,
          onTap: onSend,
        ),
      ],
    );
  }
}

class _RequestsView extends StatelessWidget {
  const _RequestsView({
    super.key,
    required this.requests,
    required this.onAccept,
    required this.onReject,
  });

  final List<_Request> requests;
  final ValueChanged<int> onAccept, onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No requests yet',
          style: FutsalTheme.getTextTheme(
            context,
          ).bodyTextMedium?.copyWith(color: LightColor.secondaryTextColor),
        ),
      );
    }
    return ListView.separated(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX16,
        top: AppDimens.paddingX2,
        right: AppDimens.paddingX16,
        bottom: AppDimens.paddingX32,
      ),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.sizeX10),
      itemBuilder: (_, i) {
        final r = requests[i];
        final settled =
            r.status == 'Accepted' ||
            r.status == 'Rejected' ||
            r.status == 'Sent';
        return _Card(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: AppDimens.sizeX46,
                    height: AppDimens.sizeX46,
                    decoration: BoxDecoration(
                      color: LightColor.secondarySoft,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: LightColor.secondaryColor,
                      size: AppDimens.sizeX22,
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.team,
                          style: FutsalTheme.getTextTheme(context)
                              .bodyTextMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: LightColor.primaryTextColor,
                              ),
                        ),
                        const SizedBox(height: AppDimens.sizeX4),
                        Text(
                          '${r.time} · ${r.level}',
                          style: FutsalTheme.getTextTheme(context).bodyTextSmall
                              ?.copyWith(color: LightColor.secondaryTextColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX8),
                  _StatusBadge(status: r.status),
                ],
              ),
              if (!settled) ...[
                const SizedBox(height: AppDimens.sizeX14),
                const Divider(
                  color: LightColor.greyBorderColor,
                  height: AppDimens.sizeX1,
                ),
                const SizedBox(height: AppDimens.sizeX12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Reject',
                        color: LightColor.redColor,
                        bg: LightColor.redLightColor,
                        onTap: () => onReject(i),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX14),
                    Expanded(
                      child: _ActionButton(
                        label: 'Accept',
                        color: LightColor.inverseTextColor,
                        bg: LightColor.secondaryColor,
                        onTap: () => onAccept(i),
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

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────

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
                          : LightColor.greyBorderColor,
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
                      color: LightColor.greyBorderColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: FutsalTheme.getTextTheme(
                    context,
                  ).headingSubTitle?.copyWith(fontWeight: FontWeight.w700),
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

/// Rounded white card with subtle border
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minWidth: 112),
        padding: AppUtils().getPadding(
          horizontal: AppDimens.paddingX10,
          vertical: AppDimens.paddingX6,
        ),
        decoration: BoxDecoration(
          color: active ? LightColor.secondaryColor : LightColor.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
          border: Border.all(
            color: active
                ? LightColor.secondaryColor
                : LightColor.greyBorderColor,
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
                  color: active
                      ? LightColor.inverseTextColor
                      : LightColor.primaryTextColor,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX6),
            Text(
              '${team.players.length}',
              style: textTheme.bodySubTitle?.copyWith(
                color: active
                    ? LightColor.inverseTextColor
                    : LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimens.sizeX40,
        padding: AppUtils().getPadding(horizontal: AppDimens.paddingX10),
        decoration: BoxDecoration(
          color: LightColor.secondarySoft,
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
          border: Border.all(
            color: LightColor.secondaryColor.withValues(alpha: .35),
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
                color: LightColor.secondaryColor,
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimens.sizeX36,
            height: AppDimens.sizeX36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: LightColor.secondarySoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              player.abbr,
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.secondaryColor,
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
              color: LightColor.secondaryColor,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimens.sizeX32,
        padding: AppUtils().getPadding(horizontal: AppDimens.paddingX10),
        decoration: BoxDecoration(
          color: LightColor.secondaryColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: LightColor.inverseTextColor, size: 16),
            const SizedBox(width: AppDimens.sizeX6),
            Text(
              label,
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.inverseTextColor,
              ),
            ),
          ],
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
    return GestureDetector(
      onTap: onAddPlayer,
      child: Container(
        width: double.infinity,
        padding: AppUtils().getPadding(
          horizontal: AppDimens.paddingX14,
          vertical: AppDimens.paddingX18,
        ),
        decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          border: Border.all(color: LightColor.greyBorderColor),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX24,
            ),
            const SizedBox(height: AppDimens.sizeX8),
            Text(
              'Add players with position',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX3),
            Text(
              'Goalkeeper, defender, midfielder, or forward',
              textAlign: TextAlign.center,
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header label
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
        style: FutsalTheme.getTextTheme(
          context,
        ).bodyTextMedium?.copyWith(color: LightColor.secondaryTextColor),
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

/// Sheet-style input (used inside modal)
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

/// Selectable pill chip (match type / level)
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: compact ? AppDimens.sizeX40 : AppDimens.sizeX44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? LightColor.secondaryColor : LightColor.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          border: Border.all(
            color: active
                ? LightColor.secondaryColor
                : LightColor.greyBorderColor,
          ),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: (compact ? textTheme.bodySubTitle : textTheme.bodyTextSmall)
              ?.copyWith(
                fontWeight: FontWeight.w600,
                color: active
                    ? LightColor.inverseTextColor
                    : LightColor.secondaryTextColor,
              ),
        ),
      ),
    );
  }
}

/// Small info display tile (date, time, venue)
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label, value;
  final bool fullWidth;

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
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: LightColor.secondaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColor.primaryTextColor,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color fg, bg;
    switch (status) {
      case 'Accepted':
        fg = LightColor.successColor;
        bg = LightColor.secondarySoft;
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
        bg = LightColor.secondarySoft;
        break;
      default:
        fg = LightColor.secondaryColor;
        bg = LightColor.secondarySoft;
    }
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX50),
      ),
      child: Text(
        status,
        style: FutsalTheme.getTextTheme(
          context,
        ).bodyMiniSubTitle?.copyWith(color: fg),
      ),
    );
  }
}

/// Full-width primary action button
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : .45,
        child: Container(
          height: AppDimens.sizeX54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: LightColor.inverseTextColor,
                size: AppDimens.sizeX18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.inverseTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimens.sizeX40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
        ),
        child: Text(
          label,
          style: textTheme.bodyTextSmall?.copyWith(color: color),
        ),
      ),
    );
  }
}
