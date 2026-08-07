import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_launcher.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';

/// The confirmed-match view both teams land on once an opponent is selected:
/// the fixture, the linked venue booking, the agreed cost split, and the chat
/// room that was created with the match.
class OpponentMatchDetailsPage extends StatelessWidget {
  const OpponentMatchDetailsPage({super.key, required this.requestId});

  final String requestId;

  OpponentRequestModel? _request(OpponentMatchState state) {
    for (final r in state.requests) {
      if (r.id == requestId) return r;
    }
    return null;
  }

  /// Who this side chats with: the requester talks to the accepting captain,
  /// the accepter talks to the requester.
  int _peerId(OpponentRequestModel r) {
    if (r.isMine) {
      final int captain = r.selectedInvitation?.captainUserId ?? 0;
      return captain > 0 ? captain : r.acceptedByUserId;
    }
    return r.requesterUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Match details'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
          builder: (context, state) {
            final OpponentRequestModel? request = _request(state);
            if (request == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.paddingX32),
                  child: Text('This match is no longer available.'),
                ),
              );
            }
            final String opponentName = _opponentName(request);
            final int peer = _peerId(request);

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: AppUtils().getPadding(
                      symmetricHorizontal: AppDimens.paddingX20,
                      top: AppDimens.paddingX14,
                      bottom: AppDimens.paddingX24,
                    ),
                    children: <Widget>[
                      _Fixture(
                        home: request.isMine ? request.team : opponentName,
                        away: request.isMine ? opponentName : request.team,
                        confirmed: request.isMatchConfirmed,
                      ),
                      const SizedBox(height: AppDimens.paddingX18),
                      const OpponentSectionLabel('Kickoff'),
                      OpponentCard(
                        child: Column(
                          children: <Widget>[
                            _DetailRow(
                              icon: Icons.event_outlined,
                              label: 'Date & time',
                              value: OpponentFmt.friendlyDateTime(
                                request.dateTime,
                              ),
                            ),
                            if (request.slot.isNotEmpty) ...<Widget>[
                              const SizedBox(height: AppDimens.paddingX12),
                              _DetailRow(
                                icon: Icons.schedule_outlined,
                                label: 'Slot',
                                value: request.slot,
                              ),
                            ],
                            if (request.summary.isNotEmpty) ...<Widget>[
                              const SizedBox(height: AppDimens.paddingX12),
                              _DetailRow(
                                icon: Icons.sports_soccer_rounded,
                                label: 'Format',
                                value: request.summary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingX18),
                      const OpponentSectionLabel('Linked venue booking'),
                      OpponentCard(
                        child: Column(
                          children: <Widget>[
                            _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Venue',
                              value: request.venue.isEmpty
                                  ? 'Not set'
                                  : request.venue,
                            ),
                            const SizedBox(height: AppDimens.paddingX12),
                            _DetailRow(
                              icon: Icons.link_rounded,
                              label: 'Status',
                              value: request.isMatchConfirmed
                                  ? 'Venue linked to this match'
                                  : 'Awaiting confirmation',
                              accent: request.isMatchConfirmed,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingX18),
                      const OpponentSectionLabel('Cost split'),
                      OpponentCard(
                        child: Column(
                          children: <Widget>[
                            _MoneyRow(
                              label: 'Total court fee',
                              value: OpponentFmt.npr(request.totalFee),
                            ),
                            const SizedBox(height: AppDimens.paddingX8),
                            _MoneyRow(
                              label: request.myPct == null
                                  ? 'Your share if you lose'
                                  : 'Your share (${request.myPct}%)',
                              value: OpponentFmt.npr(request.yourShare),
                              emphasised: true,
                            ),
                            const SizedBox(height: AppDimens.paddingX8),
                            _MoneyRow(
                              label: 'Settlement',
                              value: 'Paid at the venue',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingX18),
                      const OpponentSectionLabel('Match chat'),
                      _ChatCard(
                        opponentName: opponentName,
                        enabled: peer > 0,
                        onOpen: () =>
                            ChatLauncher.startDirectUser(context, userId: peer),
                      ),
                    ],
                  ),
                ),
                if (peer > 0)
                  Container(
                    padding: AppUtils().getPadding(all: AppDimens.paddingX16),
                    decoration: BoxDecoration(
                      color: LightColor.cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimens.radiusX20),
                        topRight: Radius.circular(AppDimens.radiusX20),
                      ),
                      border: Border.all(
                        color: LightColor.dividerColor.withValues(alpha: 0.7),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        height: AppDimens.sizeX54,
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Open Match Chat',
                          icon: Icons.chat_bubble_outline_rounded,
                          onPressed: () => ChatLauncher.startDirectUser(
                            context,
                            userId: peer,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _opponentName(OpponentRequestModel request) {
    if (!request.isMine) return request.team;
    final String selected = request.selectedInvitation?.teamName ?? '';
    if (selected.isNotEmpty) return selected;
    return request.acceptedByTeamName.isEmpty
        ? 'Opponent'
        : request.acceptedByTeamName;
  }
}

/// Team-vs-team header with the confirmation state.
class _Fixture extends StatelessWidget {
  const _Fixture({
    required this.home,
    required this.away,
    required this.confirmed,
  });

  final String home;
  final String away;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            LightColor.secondaryColor.withValues(alpha: 0.16),
            LightColor.secondaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _TeamBadge(name: home)),
              Padding(
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX8,
                ),
                child: Text(
                  'VS',
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(child: _TeamBadge(name: away)),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                confirmed
                    ? Icons.check_circle_rounded
                    : Icons.hourglass_top_rounded,
                size: AppDimens.sizeX16,
                color: confirmed
                    ? LightColor.successColor
                    : LightColor.warningColor,
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Text(
                confirmed
                    ? 'Match created · chat room opened'
                    : 'Waiting on final confirmation',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: confirmed
                      ? LightColor.successColor
                      : LightColor.warningColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String initials = () {
      final parts = name
          .trim()
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty)
          .toList();
      if (parts.isEmpty) return '?';
      if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
      return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
          .toUpperCase();
    }();
    return Column(
      children: <Widget>[
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: LightColor.secondaryColor.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            initials,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.secondaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingX8),
        Text(
          name.isEmpty ? 'Team' : name,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({
    required this.opponentName,
    required this.enabled,
    required this.onOpen,
  });

  final String opponentName;
  final bool enabled;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentCard(
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX40,
            height: AppDimens.sizeX40,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: AppDimens.sizeX20,
              color: LightColor.secondaryColor,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  enabled
                      ? 'Chat room created automatically'
                      : 'Chat opens once the opponent is confirmed',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  enabled
                      ? 'Coordinate kit, arrival time and the court fee '
                            'with $opponentName.'
                      : 'Both captains get access as soon as the match is '
                            'created.',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (enabled)
            IconButton(
              onPressed: onOpen,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.secondaryColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          size: AppDimens.sizeX18,
          color: accent ? LightColor.secondaryColor : LightColor.hintTextColor,
        ),
        const SizedBox(width: AppDimens.paddingX10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.hintTextColor,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                value,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: accent
                      ? LightColor.secondaryColor
                      : LightColor.primaryTextColor,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: emphasised ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style:
              (emphasised ? textTheme.bodyTextMedium : textTheme.bodyTextSmall)
                  ?.copyWith(
                    color: emphasised
                        ? LightColor.secondaryColor
                        : LightColor.primaryTextColor,
                    fontWeight: emphasised ? FontWeight.w800 : FontWeight.w600,
                  ),
        ),
      ],
    );
  }
}
