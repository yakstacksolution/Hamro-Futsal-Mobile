import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

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
    required this.onEditPlayer,
    required this.onEditTeam,
    required this.onDeleteTeam,
  });

  final TeamModel team;
  final VoidCallback onAddPlayer;

  /// Receives the server member id of the player to remove.
  final ValueChanged<String> onDelPlayer;

  /// Receives the player whose name/position should be edited.
  final ValueChanged<PlayerModel> onEditPlayer;
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LightColor.secondaryColor.withValues(alpha: 0.18),
                        LightColor.secondaryColor.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                    border: Border.all(
                      color: LightColor.secondaryColor.withValues(alpha: 0.12),
                    ),
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
                _CardOptionsMenu(
                  tooltip: StringConstants.teamOptions,
                  onUpdate: onEditTeam,
                  onDelete: onDeleteTeam,
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
                    onEdit: () => onEditPlayer(team.players[i]),
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
            child: Ink(
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppDimens.radiusX14),
                ),
              ),
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
                    team.players.isEmpty
                        ? 'Add your first player'
                        : 'Add Player',
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

/// Compact three-dot options menu shared by the team header and each player
/// row — short "Update" / "Delete" entries on a small surface.
class _CardOptionsMenu extends StatelessWidget {
  const _CardOptionsMenu({
    required this.tooltip,
    required this.onUpdate,
    required this.onDelete,
  });

  final String tooltip;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  PopupMenuItem<_TeamAction> _item(
    BuildContext context, {
    required _TeamAction value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem(
      value: value,
      height: AppDimens.sizeX40,
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX14),
      child: Row(
        children: [
          Icon(icon, size: AppDimens.sizeX16, color: color),
          const SizedBox(width: AppDimens.paddingX10),
          Text(
            label,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: value == _TeamAction.delete
                  ? LightColor.redColor
                  : LightColor.primaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TeamAction>(
      tooltip: tooltip,
      icon: Icon(
        Icons.more_vert_rounded,
        color: LightColor.iconGrey,
        size: AppDimens.sizeX18,
      ),
      padding: EdgeInsets.zero,
      // Plain card surface — avoids Material 3's tinted default so the menu
      // matches the app's white cards.
      color: LightColor.cardColor,
      surfaceTintColor: LightColor.transparentColor,
      elevation: 10,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: AppDimens.sizeX120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        side: BorderSide(color: LightColor.dividerColor),
      ),
      onSelected: (action) => switch (action) {
        _TeamAction.edit => onUpdate(),
        _TeamAction.delete => onDelete(),
      },
      itemBuilder: (_) => [
        _item(
          context,
          value: _TeamAction.edit,
          icon: Icons.edit_outlined,
          label: StringConstants.update,
          color: LightColor.secondaryColor,
        ),
        _item(
          context,
          value: _TeamAction.delete,
          icon: Icons.delete_outline_rounded,
          label: StringConstants.delete,
          color: LightColor.redColor,
        ),
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.onEdit,
    required this.onDelete,
  });

  final PlayerModel player;
  final VoidCallback onEdit;
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
              style: textTheme.bodyTextSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX6,
              vertical: AppDimens.paddingX2,
            ),
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            ),
            child: Text(
              player.position.label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryColor,
                fontSize: AppDimens.fontBodyMiniSubTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX4),
          _CardOptionsMenu(
            tooltip: StringConstants.playerOptions,
            onUpdate: onEdit,
            onDelete: onDelete,
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
        StringConstants
            .addPlayersWithTheirPositionGoalkeeperDefenderMid3034fc58,
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
