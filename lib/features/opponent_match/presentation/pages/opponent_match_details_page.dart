import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/message/presentation/pages/chat_launcher.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_details_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_common.dart';

/// The confirmed-match view both teams land on once an opponent is selected:
/// the fixture, the linked venue booking, the agreed cost split, and the chat
/// room that was created with the match.
class OpponentMatchDetailsPage extends StatefulWidget {
  const OpponentMatchDetailsPage({super.key, required this.requestId});

  final String requestId;

  @override
  State<OpponentMatchDetailsPage> createState() =>
      _OpponentMatchDetailsPageState();
}

class _OpponentMatchDetailsPageState extends State<OpponentMatchDetailsPage> {
  @override
  void initState() {
    super.initState();
    // The settled request's own endpoint is the authority here — the list row
    // is only a summary built for a card.
    context.read<OpponentMatchBloc>().add(
      LoadMatchDetailsEvent(widget.requestId),
    );
  }

  void _reload() => context.read<OpponentMatchBloc>().add(
    LoadMatchDetailsEvent(widget.requestId, force: true),
  );

  /// Opens the room the server created with the match. Falls back to a direct
  /// thread with the other captain only while the room's id is unknown — the
  /// shared room is where both teams already are.
  Future<void> _openChat(OpponentMatchDetailsModel match) {
    final int id = match.chat.conversationId ?? 0;
    if (id > 0) {
      return ChatLauncher.openConversation(context, conversationId: id);
    }
    final int peer = _fallbackPeerId();
    if (peer <= 0) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'The match chat is not open yet.',
      );
      return Future<void>.value();
    }
    return ChatLauncher.startDirectUser(context, userId: peer);
  }

  /// Who this side would chat with without a room: the requester talks to the
  /// accepting captain, the accepter talks to the requester. Read off the list
  /// row, which is the only place those user ids exist.
  int _fallbackPeerId() {
    final OpponentRequestModel? r = context
        .read<OpponentMatchBloc>()
        .state
        .requestById(widget.requestId);
    if (r == null) return 0;
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
            final OpponentMatchDetailsModel? match = state.matchDetailsFor(
              widget.requestId,
            );
            if (match == null) {
              if (state.isLoadingMatchDetails(widget.requestId)) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: LightColor.secondaryColor,
                  ),
                );
              }
              return _MatchDetailsError(
                message:
                    state.matchDetailErrorFor(widget.requestId) ??
                    'This match is no longer available.',
                onRetry: _reload,
              );
            }
            return _MatchDetailsBody(
              match: match,
              onRefresh: _reload,
              onOpenChat: () => _openChat(match),
            );
          },
        ),
      ),
    );
  }
}

/// The screen once `/match-details` has landed. Every section renders from its
/// own block of the response, and the server's copy is used as sent so both
/// teams read the same wording.
class _MatchDetailsBody extends StatelessWidget {
  const _MatchDetailsBody({
    required this.match,
    required this.onRefresh,
    required this.onOpenChat,
  });

  final OpponentMatchDetailsModel match;
  final VoidCallback onRefresh;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final MatchKickoff kickoff = match.kickoff;
    final MatchVenue venue = match.venue;
    final MatchCostSplit cost = match.cost;
    final MatchChat chat = match.chat;

    return Column(
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            color: LightColor.secondaryColor,
            onRefresh: () async => onRefresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX20,
                top: AppDimens.paddingX14,
                bottom: AppDimens.paddingX24,
              ),
              children: <Widget>[
                _Fixture(
                  home: match.summary.requestingTeam,
                  away: match.summary.opponentTeam,
                  confirmed: match.isConfirmed,
                  statusLine: match.summary.statusLine,
                ),
                const SizedBox(height: AppDimens.paddingX18),
                const OpponentSectionLabel('Kickoff'),
                OpponentCard(
                  child: Column(
                    children: <Widget>[
                      if (kickoff.whenLabel.isNotEmpty)
                        _DetailRow(
                          icon: Icons.event_outlined,
                          label: 'Date',
                          value: kickoff.whenLabel,
                        ),
                      if (kickoff.slotLabel.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.paddingX12),
                        _DetailRow(
                          icon: Icons.schedule_outlined,
                          label: 'Slot',
                          value: kickoff.slotLabel,
                        ),
                      ],
                      if (kickoff.formatLabel.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.paddingX12),
                        _DetailRow(
                          icon: Icons.sports_soccer_rounded,
                          label: 'Format',
                          value: kickoff.formatLabel,
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
                        value: venue.isEmpty ? 'Not set' : venue.displayName,
                      ),
                      if (venue.venueAddress.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.paddingX12),
                        _DetailRow(
                          icon: Icons.map_outlined,
                          label: 'Address',
                          value: venue.venueAddress,
                        ),
                      ],
                      const SizedBox(height: AppDimens.paddingX12),
                      // The server explains the link state in its own words —
                      // an external court has no booking to point at.
                      _DetailRow(
                        icon: venue.isLinked
                            ? Icons.link_rounded
                            : Icons.link_off_rounded,
                        label: 'Status',
                        value: venue.label.isEmpty
                            ? (venue.isLinked
                                  ? 'Venue linked to this match'
                                  : 'Arranged outside the app')
                            : venue.label,
                        accent: venue.isLinked,
                      ),
                      if (venue.bookingId.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.paddingX12),
                        _DetailRow(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Booking reference',
                          value: venue.bookingId,
                        ),
                      ],
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
                        value: OpponentFmt.npr(cost.totalCourtFee),
                      ),
                      // Both sides are named, so each captain can see what the
                      // other owes rather than only their own half.
                      if (!cost.requestingTeamShare.isEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.paddingX8),
                        _ShareRow(share: cost.requestingTeamShare, own: true),
                      ],
                      if (!cost.opponentTeamShare.isEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.paddingX8),
                        _ShareRow(share: cost.opponentTeamShare, own: false),
                      ],
                      if (cost.settlementNote.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.paddingX8),
                        _MoneyRow(
                          label: 'Settlement',
                          value: cost.settlementNote,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX18),
                const OpponentSectionLabel('Match chat'),
                _ChatCard(
                  title: chat.title,
                  description: chat.description,
                  enabled: chat.canOpen,
                  onOpen: onOpenChat,
                ),
              ],
            ),
          ),
        ),
        if (chat.canOpen)
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
                  text: chat.ctaLabel.isEmpty
                      ? 'Open Match Chat'
                      : chat.ctaLabel,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: onOpenChat,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MatchDetailsError extends StatelessWidget {
  const _MatchDetailsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppDimens.paddingX32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.paddingX16),
          SizedBox(
            height: AppDimens.sizeX54,
            child: CustomButton(
              text: StringConstants.tryAgain,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    ),
  );
}

/// One side's share of the court fee, using the server's own label.
class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.share, required this.own});

  final MatchShare share;

  /// The signed-in side's row carries the emphasis.
  final bool own;

  @override
  Widget build(BuildContext context) {
    final String label = share.label.isNotEmpty
        ? share.label
        : <String>[
            own ? 'Your share' : 'Opponent share',
            if (share.percent != null) '(${share.percent}%)',
          ].join(' ');
    return _MoneyRow(
      label: label,
      // A result-keyed split has no amount until the match is played.
      value: share.amount == null
          ? 'Decided by result'
          : OpponentFmt.npr(share.amount!),
      emphasised: own,
    );
  }
}

/// Team-vs-team header with the confirmation state.
class _Fixture extends StatelessWidget {
  const _Fixture({
    required this.home,
    required this.away,
    required this.confirmed,
    required this.statusLine,
  });

  final MatchTeamRef home;
  final MatchTeamRef away;
  final bool confirmed;

  /// "Match created · chat room opened", built by the server.
  final String statusLine;

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
              Expanded(child: _TeamBadge(team: home)),
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
              Expanded(child: _TeamBadge(team: away)),
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
                statusLine.isNotEmpty
                    ? statusLine
                    : (confirmed
                          ? 'Match created · chat room opened'
                          : 'Waiting on final confirmation'),
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
  const _TeamBadge({required this.team});

  final MatchTeamRef team;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    // The server sends the initials with the team; [MatchTeamRef] derives them
    // only when it did not.
    final String initials = team.initials;
    final String name = team.name;
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
    required this.title,
    required this.description,
    required this.enabled,
    required this.onOpen,
  });

  /// Both lines come from `match_chat`; the fallbacks only cover a bare
  /// section.
  final String title;
  final String description;
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
                  title.isNotEmpty
                      ? title
                      : (enabled
                            ? 'Chat room created automatically'
                            : 'Chat opens once the opponent is confirmed'),
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  description.isNotEmpty
                      ? description
                      : (enabled
                            ? 'Coordinate kit, arrival time and the court fee '
                                  'with the other captain.'
                            : 'Both captains get access as soon as the match '
                                  'is created.'),
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
