import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_sheets.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_team_card.dart';

/// "My Teams" tab — create teams and manage their rosters.
///
/// Kept deliberately separate from the request flow: build your squad here,
/// then just pick it when sending a request.
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
          onAdd: (player) {
            bloc.add(AddPlayerEvent(team.id, player));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
      builder: (context, state) {
        if (state.teams.isEmpty) {
          return _EmptyTeams(onCreateTeam: () => _openCreateTeam(context));
        }
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX20,
            top: AppDimens.paddingX6,
            bottom: AppDimens.paddingX50,
          ),
          // Last item is the "create another team" action.
          itemCount: state.teams.length + 1,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimens.paddingX12),
          itemBuilder: (context, i) {
            if (i == state.teams.length) {
              return _NewTeamButton(onTap: () => _openCreateTeam(context));
            }
            final team = state.teams[i];
            return OpponentTeamCard(
              key: ValueKey(team.id),
              team: team,
              onAddPlayer: () => _openAddPlayer(context, team),
              onDelPlayer: (playerIndex) => context
                  .read<OpponentMatchBloc>()
                  .add(RemovePlayerEvent(team.id, playerIndex)),
            );
          },
        );
      },
    );
  }
}

class _NewTeamButton extends StatelessWidget {
  const _NewTeamButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        child: Container(
          width: double.infinity,
          padding: AppUtils().getPadding(
            symmetricVertical: AppDimens.paddingX14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            border: Border.all(
              color: LightColor.secondaryColor.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX18,
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Text(
                'New Team',
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w700,
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
              'No teams yet',
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
              text: 'Create Team',
              icon: Icons.add_rounded,
              onPressed: onCreateTeam,
            ),
          ],
        ),
      ),
    );
  }
}
