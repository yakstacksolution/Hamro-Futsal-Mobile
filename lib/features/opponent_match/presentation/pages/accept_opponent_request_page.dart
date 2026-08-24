import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_launcher.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/accept_request_bloc/accept_request_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/models/opponent_cost_split.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';

/// The opponent team's side of the flow: view the request, select your own
/// team, and send the acceptance. No money changes hands here — the requester
/// receives it as an invitation and picks one opponent.
///
/// Pops with the updated [OpponentRequestModel] on success; the caller feeds
/// it back to the list via [RequestAcceptedEvent].
class AcceptOpponentRequestPage extends StatefulWidget {
  const AcceptOpponentRequestPage({super.key, required this.request});

  final OpponentRequestModel request;

  @override
  State<AcceptOpponentRequestPage> createState() =>
      _AcceptOpponentRequestPageState();
}

class _AcceptOpponentRequestPageState extends State<AcceptOpponentRequestPage> {
  final _noteCtrl = TextEditingController();
  final _teamNameCtrl = TextEditingController();

  TeamModel? _team;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  /// Set while the inline create-team form is in flight, so the section can
  /// show a spinner and the team it creates can be selected automatically.
  bool _creatingTeam = false;
  String _pendingTeamName = '';

  @override
  void initState() {
    super.initState();
    final teams = context.read<OpponentMatchBloc>().state.teams;
    if (teams.isEmpty) {
      context.read<OpponentMatchBloc>().add(const LoadTeamsEvent());
    }
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _noteCtrl.dispose();
    _teamNameCtrl.dispose();
    super.dispose();
  }

  /// Local instant the accept window closes at: `countdown.accept_until_at`,
  /// which every tick re-measures against [DateTime.now]. Only a payload that
  /// gave `remaining_seconds` and no timestamp is anchored, once.
  DateTime? _target;

  /// Countdown on the request's own accept window (server-owned). Nothing to
  /// do with payments — it is simply how long the request stays open.
  /// True once the accept window has run out while this page was open. The
  /// request object still says "fresh" until the list refreshes, so the page
  /// has to remember what its own ticker saw.
  bool _closedLive = false;

  /// The window is shut: the server said so, or it ran out on screen.
  bool get _acceptClosed =>
      widget.request.hasAcceptWindowClosed || _closedLive;

  void _tick() {
    if (widget.request.hasAcceptWindowClosed) {
      _ticker?.cancel();
      _ticker = null;
      if (mounted && _remaining != Duration.zero) {
        setState(() => _remaining = Duration.zero);
      }
      return;
    }
    _target =
        widget.request.acceptDeadline ??
        (_target ??
            (widget.request.acceptRemaining == null
                ? null
                : DateTime.now().add(widget.request.acceptRemaining!)));
    final DateTime? target = _target;
    if (target == null) return;
    final Duration remaining = target.difference(DateTime.now());
    if (remaining.inSeconds <= 0) {
      _ticker?.cancel();
      _ticker = null;
      if (mounted) {
        setState(() {
          _remaining = Duration.zero;
          _closedLive = true;
        });
      }
      return;
    }
    if (mounted) setState(() => _remaining = remaining);
  }

  String get _remainingLabel => OpponentFmt.countdown(_remaining);

  /// `5v5` → 5; 0 when the request carries no parsable format.
  int get _formatSize {
    final match = RegExp(r'(\d+)\s*v\s*\d+').firstMatch(widget.request.summary);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  /// Creates the captain's first team without leaving the accept flow. The
  /// list reload the bloc does after a create is what confirms it, so the
  /// result is picked up in [_onTeamsChanged] rather than awaited here.
  void _createTeam() {
    final String name = _teamNameCtrl.text.trim();
    if (name.isEmpty || _creatingTeam) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _creatingTeam = true;
      _pendingTeamName = name;
    });
    context.read<OpponentMatchBloc>().add(CreateTeamEvent(name));
  }

  /// Selects the team the inline form just created, so the captain can send
  /// the acceptance straight away instead of tapping it again.
  void _onTeamsChanged(OpponentMatchState state) {
    if (!_creatingTeam) return;
    if (state.errorMessage != null) {
      setState(() {
        _creatingTeam = false;
        _pendingTeamName = '';
      });
      AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
      context.read<OpponentMatchBloc>().add(const ClearOpponentMessagesEvent());
      return;
    }
    if (state.teams.isEmpty) return;
    final TeamModel created = state.teams.firstWhere(
      (TeamModel t) =>
          t.name.trim().toLowerCase() == _pendingTeamName.toLowerCase(),
      orElse: () => state.teams.first,
    );
    setState(() {
      _creatingTeam = false;
      _pendingTeamName = '';
      _team = created;
      _teamNameCtrl.clear();
    });
    AppUtils().showSnackBar(
      context,
      MsgType.success,
      '${created.name} created — you can send your acceptance now.',
    );
  }

  void _sendAcceptance() {
    final TeamModel? team = _team;
    if (team == null) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.selectYourTeam,
      );
      return;
    }
    HapticFeedback.mediumImpact();
    context.read<AcceptOpponentRequestBloc>().add(
      SubmitAcceptEvent(
        AcceptOpponentRequestRequest(
          requestId: widget.request.id,
          teamId: team.id,
          message: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        ),
      ),
    );
  }

  /// 403/404/409/410 all mean this invitation can no longer be accepted, so
  /// they end the flow — tell the user, pop, and let the list refresh to the
  /// server's truth. Everything else keeps the screen open for a retry.
  void _handleError(AcceptRequestState state) {
    final String message = switch (state.errorStatusCode) {
      409 =>
        state.errorMessage ?? StringConstants.requestJustAcceptedByAnotherTeam,
      410 => state.errorMessage ?? StringConstants.requestExpiredMessage,
      // The invitation was withdrawn, or it belongs to a team this user no
      // longer captains — either way there is nothing left to accept here.
      403 ||
      404 => state.errorMessage ?? StringConstants.invitationNoLongerAvailable,
      _ => state.errorMessage ?? 'Something went wrong. Please try again.',
    };
    final bool terminal = const <int>{
      403,
      404,
      409,
      410,
    }.contains(state.errorStatusCode);
    AppUtils().showSnackBar(context, MsgType.error, message);
    if (terminal) Navigator.of(context).pop();
  }

  /// The requester — the captain on the other side of this request. Comes from
  /// the payload's `requester`, or the linked booking's `user_id` when the list
  /// endpoint sent no requester block.
  int get _peerUserId => widget.request.requesterUserId;

  String get _peerName => widget.request.requesterName.isEmpty
      ? widget.request.team
      : widget.request.requesterName;

  /// Opens (or reuses) the direct thread with the requester and pushes the chat
  /// page.
  ///
  /// Only the recipient travels. The court behind an opponent request belongs to
  /// a third-party vendor, and `/conversations/direct` rejects a venue that
  /// belongs to neither participant with a 422 — this is a captain-to-captain
  /// thread, not a conversation about someone's venue.
  Future<void> _openChat() {
    if (_peerUserId <= 0) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'This requester cannot be messaged yet.',
      );
      return Future<void>.value();
    }
    return ChatLauncher.startDirectUser(context, userId: _peerUserId);
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = _acceptClosed;
    final bool showCountdown =
        !closed &&
        (widget.request.acceptDeadline != null ||
            widget.request.acceptRemaining != null) &&
        _remaining.inSeconds > 0;
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Accept request'),
      body: SafeArea(
        top: false,
        child: BlocConsumer<AcceptOpponentRequestBloc, AcceptRequestState>(
          listener: (context, state) {
            if (state.submitStatus == AcceptRequestStatus.success &&
                state.result != null) {
              AppUtils().showSnackBar(
                context,
                MsgType.success,
                'Acceptance sent — the requester will confirm the opponent.',
              );
              Navigator.of(context).pop(state.result);
              return;
            }
            if (state.submitStatus == AcceptRequestStatus.failure) {
              _handleError(state);
            }
          },
          builder: (context, state) {
            return BlocConsumer<OpponentMatchBloc, OpponentMatchState>(
              listenWhen: (previous, current) =>
                  previous.teams != current.teams ||
                  previous.errorMessage != current.errorMessage,
              listener: (context, matchState) => _onTeamsChanged(matchState),
              builder: (context, matchState) {
                final teams = matchState.teams;
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: AppUtils().getPadding(
                          symmetricHorizontal: AppDimens.paddingX20,
                          top: AppDimens.paddingX12,
                          bottom: AppDimens.paddingX20,
                        ),
                        children: [
                          const OpponentGuidanceCard(
                            icon: Icons.handshake_outlined,
                            title: 'Accept this challenge — no payment needed',
                            message:
                                'Choose the team that will play and send your '
                                'acceptance — you can message the requester '
                                'from the team section first. They may receive '
                                'several acceptances and pick one opponent. '
                                'The court fee is settled at the venue.',
                          ),
                          if (showCountdown) ...[
                            const SizedBox(height: AppDimens.paddingX14),
                            OpponentCountdownPill(
                              value: _remainingLabel,
                              urgent: _remaining.inMinutes < 5,
                            ),
                          ] else if (closed) ...[
                            const SizedBox(height: AppDimens.paddingX14),
                            const _AcceptClosedNotice(),
                          ],
                          const SizedBox(height: AppDimens.paddingX18),
                          const OpponentSectionLabel('Match details'),
                          _RequestSummaryCard(request: widget.request),
                          const SizedBox(height: AppDimens.paddingX18),
                          const OpponentSectionLabel(
                            StringConstants.whichTeamWillPlay,
                          ),
                          // Squad questions come up right here — "can you field
                          // seven?" — so the captain can reach the requester
                          // without leaving the picker.
                          _RequesterChatCard(
                            name: _peerName,
                            enabled: _peerUserId > 0,
                            onTap: _openChat,
                          ),
                          const SizedBox(height: AppDimens.paddingX12),
                          if (matchState.teamsStatus ==
                                  OpponentMatchStatus.loading &&
                              teams.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(AppDimens.paddingX24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: LightColor.secondaryColor,
                                ),
                              ),
                            )
                          else if (teams.isEmpty)
                            // No team yet: create the first one right here
                            // instead of sending the captain to My Teams and
                            // losing the request they were about to accept.
                            _CreateFirstTeamSection(
                              controller: _teamNameCtrl,
                              busy: _creatingTeam,
                              onCreate: _createTeam,
                            )
                          else
                            ...teams.map(
                              (team) => Padding(
                                padding: AppUtils().getPadding(
                                  bottom: AppDimens.paddingX10,
                                ),
                                child: _TeamOption(
                                  team: team,
                                  request: widget.request,
                                  formatSize: _formatSize,
                                  selected: team.id == _team?.id,
                                  onTap: () => setState(() => _team = team),
                                ),
                              ),
                            ),
                          const SizedBox(height: AppDimens.paddingX8),
                          const OpponentSectionLabel(
                            'Message to the requester',
                          ),
                          OpponentCard(
                            child: CustomTextField(
                              controller: _noteCtrl,
                              labelText: StringConstants.message,
                              hintText:
                                  'Anything the other captain should know…',
                              maxLines: 3,
                              minLines: 3,
                              textInputAction: TextInputAction.newline,
                              textCapitalization: TextCapitalization.sentences,
                              isRequired: false,
                            ),
                          ),
                          const SizedBox(height: AppDimens.paddingX12),
                          _NextStepsCard(request: widget.request),
                        ],
                      ),
                    ),
                    _BottomAction(
                      text: closed
                          ? StringConstants.closedAcceptWindowExpired
                          : 'Send Acceptance',
                      icon: closed
                          ? Icons.hourglass_disabled_rounded
                          : Icons.send_rounded,
                      busy: state.submitStatus == AcceptRequestStatus.loading,
                      // A closed window would only ever come back 410, so the
                      // button stops before the request is sent.
                      enabled: !closed && _team != null,
                      onTap: _sendAcceptance,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// "Message the requester" card sitting with the team picker.
///
/// Disabled rather than hidden when the payload named no requester: the reason
/// the row exists is still worth showing, and a hidden control reads as a
/// missing feature.
class _RequesterChatCard extends StatelessWidget {
  const _RequesterChatCard({
    required this.name,
    required this.enabled,
    required this.onTap,
  });

  final String name;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color accent = enabled
        ? LightColor.secondaryColor
        : LightColor.iconGrey;

    return OpponentCard(
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX38,
            height: AppDimens.sizeX38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_outlined,
              size: AppDimens.sizeX18,
              color: accent,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  enabled ? 'Chat with $name' : 'Chat unavailable',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  enabled
                      ? 'Confirm the squad size and timing before you commit '
                            'a team.'
                      : 'This request did not carry a contact to message.',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX8),
          SizedBox(
            // Bounded on both axes: a button dropped straight into a Row has no
            // width to fill.
            height: AppDimens.sizeX36,
            width: AppDimens.sizeX90,
            child: CustomButton(
              text: 'Chat',
              icon: Icons.chat_bubble_outline_rounded,
              minWidth: AppDimens.sizeX80,
              fontSize: AppDimens.fontBodySubTitle,
              backgroundColor: enabled ? null : LightColor.dividerColor,
              onPressed: enabled ? onTap : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Replaces the countdown pill once the accept window has closed. The request
/// can still be read — the venue, the split, the requester — but not accepted.
class _AcceptClosedNotice extends StatelessWidget {
  const _AcceptClosedNotice();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.redLightColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.redColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.hourglass_disabled_rounded,
            size: AppDimens.sizeX18,
            color: LightColor.redColor,
          ),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Text(
              StringConstants.requestExpiredMessage,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.redColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline "create your first team" form, shown in place of the team picker
/// when the captain has no teams yet.
///
/// The accept body needs a `team_id`, so without a team the acceptance cannot
/// be sent at all — creating one here keeps the request in view instead of
/// bouncing the user to the My Teams tab and back.
class _CreateFirstTeamSection extends StatelessWidget {
  const _CreateFirstTeamSection({
    required this.controller,
    required this.busy,
    required this.onCreate,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX38,
                height: AppDimens.sizeX38,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_2_outlined,
                  size: AppDimens.sizeX18,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Create your team first',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      'You need a team to accept this challenge. Name it now '
                      'and add players later.',
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          CustomTextField(
            controller: controller,
            labelText: 'Team name',
            hintText: 'e.g. Thamel Tigers',
            icon: Icons.groups_2_outlined,
            enabled: !busy,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onCreate(),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          CustomButton(
            text: 'Create Team',
            icon: Icons.add_rounded,
            isLoading: busy,
            minHeight: AppDimens.sizeX44,
            onPressed: busy ? null : onCreate,
          ),
        ],
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({required this.request});

  final OpponentRequestModel request;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.12),
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
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (request.summary.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.sizeX2),
                      Text(
                        request.summary,
                        style: textTheme.bodyMiniSubTitle?.copyWith(
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          _Line(
            icon: Icons.schedule_outlined,
            text: [
              OpponentFmt.friendlyDateTime(request.dateTime),
              request.slot,
            ].where((s) => s.isNotEmpty).join(' · '),
          ),
          const SizedBox(height: AppDimens.paddingX6),
          _Line(icon: Icons.location_on_outlined, text: request.venue),
          const SizedBox(height: AppDimens.paddingX6),
          _Line(
            icon: Icons.payments_outlined,
            text: _feeLine(request),
          ),
        ],
      ),
    );
  }
}

/// The court fee and what the accepting side owes under it.
///
/// A result-keyed rule fixes nothing per side until the match is played, and
/// `yourShare` is 0 for it — quoting that as "your share" told the captain the
/// match was free. It states the stake instead.
String _feeLine(OpponentRequestModel request) {
  final String fee = '${OpponentFmt.npr(request.totalFee)} court fee';
  if (request.isResultCost) {
    final int? loser = request.resolvedLoserAmount;
    final int? pct = request.resolvedLoserPercent;
    if (loser == null) return '$fee · the loser pays';
    return '$fee · lose and you pay ${OpponentFmt.npr(loser)}'
        '${pct == null ? '' : ' ($pct%)'}';
  }
  if (request.myPct == null) {
    return '$fee · loser pays ${OpponentFmt.npr(request.yourShare)}';
  }
  return '$fee · your share ${OpponentFmt.npr(request.yourShare)} '
      '(${request.myPct}%)';
}

/// What this team would owe, per team and per player.
///
/// Under a result-keyed rule the figure is conditional, so it is labelled as
/// the stake rather than a share — and it is derived from the loser's amount,
/// never from `yourShare`, which the server reports as 0 for that rule.
({String label, int amount}) _accepterStake(OpponentRequestModel request) =>
    request.isResultCost
    ? (
        label: 'If you lose',
        amount: request.resolvedLoserAmount ?? request.totalFee,
      )
    : (label: StringConstants.yourTeamShare, amount: request.yourShare);

/// Selectable roster card with this team's share of the court fee.
class _TeamOption extends StatelessWidget {
  const _TeamOption({
    required this.team,
    required this.request,
    required this.formatSize,
    required this.selected,
    required this.onTap,
  });

  final TeamModel team;
  final OpponentRequestModel request;
  final int formatSize;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final ({String label, int amount}) stake = _accepterStake(request);
    final cost = OpponentCostSplit.fromServerShare(
      totalFee: request.totalFee,
      accepterShare: stake.amount,
      playerCount: team.players.length,
    );
    final bool tooSmall = formatSize > 0 && team.players.length < formatSize;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: selected
                ? LightColor.secondaryColor.withValues(alpha: 0.08)
                : LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected
                        ? LightColor.secondaryColor
                        : LightColor.hintTextColor,
                    size: AppDimens.sizeX20,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.paddingX4),
              Text(
                '${team.players.length} players'
                '${team.positionSummary.isEmpty ? '' : ' · ${team.positionSummary}'}',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
              if (team.players.isNotEmpty) ...[
                const SizedBox(height: AppDimens.paddingX8),
                Wrap(
                  spacing: AppDimens.paddingX6,
                  runSpacing: AppDimens.paddingX6,
                  children: team.players
                      .map(
                        (p) => Container(
                          padding: AppUtils().getPadding(
                            horizontal: AppDimens.paddingX8,
                            vertical: AppDimens.paddingX4,
                          ),
                          decoration: BoxDecoration(
                            color: LightColor.background,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusX6,
                            ),
                            border: Border.all(color: LightColor.dividerColor),
                          ),
                          child: Text(
                            '${p.name} · ${p.position.abbr}',
                            style: textTheme.bodyMiniSubTitle?.copyWith(
                              color: LightColor.secondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: AppDimens.paddingX8),
              Text(
                team.players.isEmpty
                    ? '${stake.label}: ${OpponentFmt.npr(stake.amount)}'
                    : '${stake.label}: ${OpponentFmt.npr(stake.amount)} '
                          '· ${OpponentFmt.npr(cost.perPlayerShare)} / player',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                request.isResultCost
                    ? 'Win and you pay nothing. Settled with the venue on '
                          'match day.'
                    : 'Settled with the venue on match day.',
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.hintTextColor,
                ),
              ),
              if (tooSmall) ...[
                const SizedBox(height: AppDimens.paddingX6),
                Text(
                  'This roster has fewer than $formatSize players for the '
                  'requested format.',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.warningColor,
                    fontWeight: FontWeight.w600,
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

/// What happens after the acceptance is sent — the diagram's tail end.
class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard({required this.request});

  final OpponentRequestModel request;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happens next',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          const _StepLine(
            index: 1,
            text:
                '${'Your acceptance reaches'} '
                'the requester as an invitation.',
          ),
          const SizedBox(height: AppDimens.paddingX8),
          const _StepLine(
            index: 2,
            text: 'They may wait for other teams, then select one opponent.',
          ),
          const SizedBox(height: AppDimens.paddingX8),
          _StepLine(
            index: 3,
            text:
                'If your team is picked, the match is created at '
                '${request.venue.isEmpty ? 'the venue' : request.venue} and a '
                'chat room opens for both teams.',
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppDimens.sizeX20,
          height: AppDimens.sizeX20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: textTheme.bodyMiniSubTitle?.copyWith(
              color: LightColor.secondaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.paddingX10),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: LightColor.hintTextColor),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: Text(
            text,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.text,
    required this.icon,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: busy
              ? const Center(
                  child: CircularProgressIndicator(
                    color: LightColor.secondaryColor,
                  ),
                )
              : CustomButton(
                  text: text,
                  icon: icon,
                  onPressed: enabled ? onTap : null,
                ),
        ),
      ),
    );
  }
}
