import 'package:hamro_futsal/core/utils/bloc_safe_add.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_delete_dialog.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_sheets.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_team_card.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class OpponentTeamsView extends StatelessWidget {
  const OpponentTeamsView({super.key});

  void _openCreateTeam(BuildContext context) {
    final bloc = context.read<OpponentMatchBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CreateTeamSheet(
          onCreate: (name) {
            bloc.add(CreateTeamEvent(name));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _openAddPlayer(BuildContext context, TeamModel team) {
    final bloc = context.read<OpponentMatchBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddPlayerSheet(
          teamName: team.name,
          positions: bloc.state.positions.isEmpty
              ? PlayerPositionModel.defaults
              : bloc.state.positions,
          onAdd: (player) {
            bloc.add(AddPlayerEvent(team.id, player));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _openEditPlayer(
    BuildContext context,
    TeamModel team,
    PlayerModel player,
  ) {
    final bloc = context.read<OpponentMatchBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddPlayerSheet(
          teamName: team.name,
          positions: bloc.state.positions.isEmpty
              ? PlayerPositionModel.defaults
              : bloc.state.positions,
          initialPlayer: player,
          onAdd: (updated) {
            bloc.add(UpdateMemberEvent(team.id, updated));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _openEditTeam(BuildContext context, TeamModel team) {
    final bloc = context.read<OpponentMatchBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CreateTeamSheet(
          title: StringConstants.renameTeam,
          actionLabel: 'Save',
          actionIcon: Icons.check_rounded,
          initialName: team.name,
          onCreate: (name) {
            bloc.add(UpdateTeamEvent(team.id, name));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTeam(BuildContext context, TeamModel team) async {
    final bloc = context.read<OpponentMatchBloc>();
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: StringConstants.deleteTeam,
      message:
          'This removes "${team.name}" and its players. This can\'t be undone.',
    );
    if (confirmed) bloc.addIfOpen(DeleteTeamEvent(team.id));
  }

  Future<void> _confirmRemoveMember(
    BuildContext context,
    TeamModel team,
    String memberId,
  ) async {
    final bloc = context.read<OpponentMatchBloc>();
    String playerName = 'this player';
    for (final PlayerModel player in team.players) {
      if (player.id == memberId) {
        playerName = player.name;
        break;
      }
    }
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: StringConstants.removePlayer,
      message:
          'This removes "$playerName" from "${team.name}". This can\'t be undone.',
      confirmText: StringConstants.remove,
      icon: Icons.person_remove_outlined,
    );
    if (confirmed) bloc.addIfOpen(RemoveMemberEvent(team.id, memberId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
      builder: (context, state) {
        if (state.teams.isEmpty) {
          return _EmptyTeams(onCreateTeam: () => _openCreateTeam(context));
        }
        // With more than one team every roster starts closed, so the list
        // opens as one line per team and the captain picks which to work on.
        // A lone team has nothing to scroll past, so it stays open.
        final bool single = state.teams.length == 1;
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX20,
            top: AppDimens.paddingX6,
            bottom: AppDimens.paddingX20,
          ),
          itemCount: state.teams.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimens.paddingX12),
          itemBuilder: (context, i) {
            final team = state.teams[i];
            return OpponentTeamCard(
              key: ValueKey(team.id),
              team: team,
              initiallyExpanded: single,
              onAddPlayer: () => _openAddPlayer(context, team),
              onDelPlayer: (memberId) =>
                  _confirmRemoveMember(context, team, memberId),
              onEditPlayer: (player) => _openEditPlayer(context, team, player),
              onEditTeam: () => _openEditTeam(context, team),
              onDeleteTeam: () => _confirmDeleteTeam(context, team),
            );
          },
        );
      },
    );
  }
}

class _EmptyTeams extends StatelessWidget {
  const _EmptyTeams({required this.onCreateTeam});

  final VoidCallback onCreateTeam;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
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
                Icons.groups_2_outlined,
                size: 32,
                color: LightColor.secondaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              StringConstants.noTeamsYet,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              'Create a team and add players — you\'ll pick it when sending a match request.',
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),
            CustomButton(
              text: StringConstants.createTeam,
              icon: Icons.add_rounded,
              onPressed: onCreateTeam,
            ),
          ],
        ),
      ),
    );
  }
}
