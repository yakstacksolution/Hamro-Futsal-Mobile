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

  TeamModel? _team;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

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
    super.dispose();
  }

  /// Countdown on the request's own accept window (server-owned). Nothing to
  /// do with payments — it is simply how long the request stays open.
  void _tick() {
    final DateTime? deadline = widget.request.acceptDeadline;
    if (deadline == null) return;
    final Duration remaining = deadline.difference(DateTime.now());
    if (remaining.inSeconds <= 0) {
      _ticker?.cancel();
      _ticker = null;
      if (mounted) setState(() => _remaining = Duration.zero);
      return;
    }
    if (mounted) setState(() => _remaining = remaining);
  }

  String get _remainingLabel {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// `5v5` → 5; 0 when the request carries no parsable format.
  int get _formatSize {
    final match = RegExp(r'(\d+)\s*v\s*\d+').firstMatch(widget.request.summary);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
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

  /// 409 (already settled with another team) and 410 (expired) end the flow —
  /// tell the user, pop, and let the list refresh to the server's truth.
  void _handleError(AcceptRequestState state) {
    final String message = switch (state.errorStatusCode) {
      409 =>
        state.errorMessage ?? StringConstants.requestJustAcceptedByAnotherTeam,
      410 => state.errorMessage ?? StringConstants.requestExpiredMessage,
      _ => state.errorMessage ?? 'Something went wrong. Please try again.',
    };
    final bool terminal =
        state.errorStatusCode == 409 || state.errorStatusCode == 410;
    AppUtils().showSnackBar(context, MsgType.error, message);
    if (terminal) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool showCountdown =
        widget.request.acceptDeadline != null && _remaining.inSeconds > 0;
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: 'Accept request',
        actions: [
          // Vet the requester (confirm squad, timing, split) before accepting.
          if (widget.request.requesterUserId > 0)
            IconButton(
              tooltip: 'Message ${widget.request.requesterName}'.trim(),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              onPressed: () => ChatLauncher.startDirectUser(
                context,
                userId: widget.request.requesterUserId,
              ),
            ),
        ],
      ),
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
            return BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
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
                                'Chat with the requester first if you want, '
                                'then choose the team that will play and send '
                                'your acceptance. They may receive several '
                                'acceptances and pick one opponent. The court '
                                'fee is settled at the venue.',
                          ),
                          if (widget.request.requesterUserId > 0) ...[
                            const SizedBox(height: AppDimens.paddingX12),
                            _ChatFirstTile(
                              name: widget.request.requesterName.isEmpty
                                  ? widget.request.team
                                  : widget.request.requesterName,
                              onTap: () => ChatLauncher.startDirectUser(
                                context,
                                userId: widget.request.requesterUserId,
                              ),
                            ),
                          ],
                          if (showCountdown) ...[
                            const SizedBox(height: AppDimens.paddingX14),
                            OpponentCountdownPill(
                              value: _remainingLabel,
                              urgent: _remaining.inMinutes < 5,
                            ),
                          ],
                          const SizedBox(height: AppDimens.paddingX18),
                          const OpponentSectionLabel('Match details'),
                          _RequestSummaryCard(request: widget.request),
                          const SizedBox(height: AppDimens.paddingX18),
                          const OpponentSectionLabel(
                            StringConstants.whichTeamWillPlay,
                          ),
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
                            OpponentCard(
                              child: Text(
                                'You have no teams yet — create one on the My '
                                'Teams tab first.',
                                style: FutsalTheme.getTextTheme(context)
                                    .bodyTextSmall
                                    ?.copyWith(
                                      color: LightColor.secondaryTextColor,
                                    ),
                              ),
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
                            'Message to the requester (optional)',
                          ),
                          OpponentCard(
                            child: CustomTextField(
                              controller: _noteCtrl,
                              labelText: StringConstants.message,
                              hintText:
                                  'Anything the other captain should know…',
                              icon: Icons.chat_bubble_outline_rounded,
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
                      text: 'Send Acceptance',
                      icon: Icons.send_rounded,
                      busy: state.submitStatus == AcceptRequestStatus.loading,
                      enabled: _team != null,
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

/// "Talk before you commit" shortcut into the direct chat with the requester.
class _ChatFirstTile extends StatelessWidget {
  const _ChatFirstTile({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Container(
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimens.sizeX38,
                height: AppDimens.sizeX38,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: AppDimens.sizeX18,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message $name first',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      'Agree the squad, timing and who pays what before you '
                      'accept.',
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.hintTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the request is: teams, kickoff, venue and the agreed split.
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
            text: request.myPct == null
                ? '${OpponentFmt.npr(request.totalFee)} court fee · '
                      'loser pays ${OpponentFmt.npr(request.yourShare)}'
                : '${OpponentFmt.npr(request.totalFee)} court fee · '
                      'your share ${OpponentFmt.npr(request.yourShare)} '
                      '(${request.myPct}%)',
          ),
        ],
      ),
    );
  }
}

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
    final cost = OpponentCostSplit.fromServerShare(
      totalFee: request.totalFee,
      accepterShare: request.yourShare,
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
                    ? '${StringConstants.yourTeamShare}: ${OpponentFmt.npr(request.yourShare)}'
                    : '${StringConstants.yourTeamShare}: ${OpponentFmt.npr(request.yourShare)} '
                          '· ${OpponentFmt.npr(cost.perPlayerShare)} / player',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Settled with the venue on match day.',
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
