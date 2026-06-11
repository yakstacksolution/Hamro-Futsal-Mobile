import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';

enum _TeamAction { edit, delete }

/// One team with its roster.
///
/// Header (initials avatar, name, roster mix, options menu) · flat
/// divider-separated player rows · full-width "Add Player" footer action.
class OpponentTeamCard extends StatelessWidget {
  const OpponentTeamCard({
    super.key,
    required this.team,
    required this.onAddPlayer,
    required this.onDelPlayer,
    required this.onEditTeam,
    required this.onDeleteTeam,
  });

  final TeamModel team;
  final VoidCallback onAddPlayer;

  /// Receives the server member id of the player to remove.
  final ValueChanged<String> onDelPlayer;
  final VoidCallback onEditTeam;
  final VoidCallback onDeleteTeam;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final count = team.players.length;
    final mix = team.positionSummary;

    return OpponentCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            child: Row(
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
                    team.initials,
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
                        count == 0
                            ? 'No players yet'
                            : '$count ${count == 1 ? 'player' : 'players'}'
                                  '${mix.isEmpty ? '' : ' · $mix'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_TeamAction>(
                  tooltip: 'Team options',
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: LightColor.iconGrey,
                    size: AppDimens.sizeX20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  ),
                  onSelected: (action) => switch (action) {
                    _TeamAction.edit => onEditTeam(),
                    _TeamAction.delete => onDeleteTeam(),
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _TeamAction.edit,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            size: AppDimens.sizeX18,
                            color: LightColor.secondaryTextColor,
                          ),
                          const SizedBox(width: AppDimens.paddingX12),
                          Text('Rename team', style: textTheme.bodyTextMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _TeamAction.delete,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: AppDimens.sizeX18,
                            color: LightColor.redColor,
                          ),
                          const SizedBox(width: AppDimens.paddingX12),
                          Text(
                            'Delete team',
                            style: textTheme.bodyTextMedium?.copyWith(
                              color: LightColor.redColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Roster ──
          if (team.players.isEmpty)
            const _EmptyRosterHint()
          else ...[
            const _InsetDivider(),
            ...List.generate(team.players.length, (i) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (i > 0) const _InsetDivider(indent: 58),
                  _PlayerRow(
                    player: team.players[i],
                    onDelete: () => onDelPlayer(team.players[i].id),
                  ),
                ],
              );
            }),
          ],

          // ── Footer action ──
          const _InsetDivider(),
          InkWell(
            onTap: onAddPlayer,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppDimens.radiusX14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.paddingX12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: AppDimens.sizeX16,
                    color: LightColor.secondaryColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX6),
                  Text(
                    team.players.isEmpty ? 'Add your first player' : 'Add Player',
                    style: textTheme.bodyTextSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: LightColor.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player, required this.onDelete});

  final PlayerModel player;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX14,
        symmetricVertical: AppDimens.paddingX6,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimens.sizeX32,
            height: AppDimens.sizeX32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.background,
              shape: BoxShape.circle,
              border: Border.all(color: LightColor.dividerColor),
            ),
            child: Text(
              player.position.abbr,
              style: textTheme.bodyTextSmall?.copyWith(
                fontSize: AppDimens.fontBodySubTitle,
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sizeX12),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
          ),
          Text(
            player.position.label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX4),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Remove player',
            onPressed: onDelete,
            icon: const Icon(
              Icons.close_rounded,
              color: LightColor.iconGrey,
              size: AppDimens.sizeX18,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRosterHint extends StatelessWidget {
  const _EmptyRosterHint();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX14,
        0,
        AppDimens.paddingX14,
        AppDimens.paddingX12,
      ),
      child: Text(
        'Add players with their position — goalkeeper, defender, midfielder or forward.',
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          height: 1.4,
        ),
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider({this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      color: LightColor.dividerColor.withValues(alpha: 0.7),
    );
  }
}
