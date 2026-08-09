import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_delete_dialog.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_launcher.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/accept_request_bloc/accept_request_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/pages/accept_opponent_request_page.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/pages/opponent_invitations_page.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/pages/opponent_match_details_page.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Fallback accept window for requests without a server `accept_deadline`
/// (mock data only — the server owns the real deadline).
const Duration kAcceptWindow = Duration(minutes: 20);

enum RequestFilter { all, open, mine, settled }

extension RequestFilterX on RequestFilter {
  String get label => switch (this) {
    RequestFilter.all => 'All',
    RequestFilter.open => 'Need Opponent',
    RequestFilter.mine => 'My Requests',
    RequestFilter.settled => 'Settled',
  };
}

/// Requests I sent live under "My Requests"; they stay pending until the
/// opponent replies and can be removed at any time.
bool _isMine(OpponentRequestModel r) =>
    r.isMine || r.status == RequestStatus.sent;

/// Requests tab: filter chips + request cards.
class OpponentRequestsView extends StatelessWidget {
  const OpponentRequestsView({
    super.key,
    required this.filter,
    required this.onFilter,
  });

  final RequestFilter filter;
  final ValueChanged<RequestFilter> onFilter;

  List<OpponentRequestModel> _filtered(List<OpponentRequestModel> requests) =>
      switch (filter) {
        RequestFilter.all => requests,
        RequestFilter.open => requests.where((r) => r.status.isOpen).toList(),
        RequestFilter.mine => requests.where(_isMine).toList(),
        // Sent requests have their own tab now, so settled is only the
        // requests that reached a final state.
        RequestFilter.settled =>
          requests.where((r) => r.status.isSettled && !_isMine(r)).toList(),
      };

  int _count(List<OpponentRequestModel> requests, RequestFilter f) =>
      switch (f) {
        RequestFilter.all => requests.length,
        RequestFilter.open => requests.where((r) => r.status.isOpen).length,
        RequestFilter.mine => requests.where(_isMine).length,
        RequestFilter.settled =>
          requests.where((r) => r.status.isSettled && !_isMine(r)).length,
      };

  /// Who this card's chat talks to: on my own requests it's the accepting
  /// captain (once someone accepts); on incoming requests it's the requester.
  /// 0 means nobody to chat with yet, so the button stays hidden.
  int _chatPeerId(OpponentRequestModel r) =>
      _isMine(r) ? r.acceptedByUserId : r.requesterUserId;

  /// Accept → the accept page (pick my team, send the acceptance).
  /// A successful accept pops with the updated request, patched in place.
  Future<void> _openAcceptFlow(
    BuildContext context,
    OpponentRequestModel request,
  ) async {
    final bloc = context.read<OpponentMatchBloc>();
    final OpponentRequestModel? updated = await Navigator.of(context)
        .push<OpponentRequestModel>(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: bloc),
                BlocProvider(
                  create: (_) => AcceptOpponentRequestBloc(bloc.useCase),
                ),
              ],
              child: AcceptOpponentRequestPage(request: request),
            ),
          ),
        );
    if (updated != null) bloc.add(RequestAcceptedEvent(updated));
  }

  /// My request → review the invitations that came in and pick one opponent.
  void _openInvitations(BuildContext context, OpponentRequestModel request) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<OpponentMatchBloc>(),
          child: OpponentInvitationsPage(requestId: request.id),
        ),
      ),
    );
  }

  /// Confirmed match → the fixture both teams see, with the match chat.
  void _openMatchDetails(BuildContext context, OpponentRequestModel request) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<OpponentMatchBloc>(),
          child: OpponentMatchDetailsPage(requestId: request.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
      builder: (context, state) {
        final bloc = context.read<OpponentMatchBloc>();
        final requests = _filtered(state.requests);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Padding(
            //   padding: EdgeInsets.fromLTRB(
            //     AppDimens.paddingX20,
            //     0,
            //     AppDimens.paddingX20,
            //     AppDimens.paddingX10,
            //   ),
            //   child: OpponentGuidanceCard(
            //     icon: Icons.sports_soccer_rounded,
            //     title: 'Find a team or respond to a challenge',
            //     message:
            //         'Need Opponent shows teams you can play. My Requests shows challenges sent by your team. To accept, just choose the team that will play — the court fee is settled at the venue.',
            //   ),
            // ),
            SizedBox(
              height: AppDimens.sizeX32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX20,
                ),
                itemCount: RequestFilter.values.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimens.paddingX8),
                itemBuilder: (_, i) {
                  final f = RequestFilter.values[i];
                  return OpponentCountChip(
                    label: f.label,
                    count: _count(state.requests, f),
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
                      itemBuilder: (_, i) {
                        final request = requests[i];
                        return OpponentRequestCard(
                          key: ValueKey(request.id),
                          request: request,
                          onAccept: () => _openAcceptFlow(context, request),
                          onMessage: _chatPeerId(request) > 0
                              ? () => ChatLauncher.startDirectUser(
                                  context,
                                  userId: _chatPeerId(request),
                                )
                              : null,
                          onDelete: () =>
                              bloc.add(DeleteOpponentRequestEvent(request)),
                          onIgnore: () =>
                              bloc.add(DeclineRequestEvent(request)),
                          onInvitations: () =>
                              _openInvitations(context, request),
                          onMatchDetails: () =>
                              _openMatchDetails(context, request),
                          // The deadline passed on-device: re-fetch so the
                          // card reflects the server's (swept) status.
                          onExpire: () =>
                              bloc.add(const LoadOpponentRequestsEvent()),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class OpponentRequestCard extends StatefulWidget {
  const OpponentRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDelete,
    required this.onExpire,
    required this.onIgnore,
    required this.onInvitations,
    required this.onMatchDetails,
    this.onMessage,
  });

  final OpponentRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onDelete;
  final VoidCallback onExpire;

  /// Declines an incoming request so it leaves my "Need Opponent" list.
  final VoidCallback onIgnore;

  /// Opens the invitation review for a request I published.
  final VoidCallback onInvitations;

  /// Opens the confirmed-match view once an opponent is locked in.
  final VoidCallback onMatchDetails;

  /// Opens a direct chat with the request's counterparty (the requester on
  /// incoming requests, the accepting captain on my own); hidden when null.
  final VoidCallback? onMessage;

  @override
  State<OpponentRequestCard> createState() => _OpponentRequestCardState();
}

class _OpponentRequestCardState extends State<OpponentRequestCard> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  /// Server-owned deadline; falls back to `createdAt + kAcceptWindow` for
  /// mock rows without one.
  DateTime? get _deadline =>
      widget.request.acceptDeadline ??
      widget.request.createdAt?.add(kAcceptWindow);

  bool get _hasCountdown =>
      widget.request.status == RequestStatus.fresh && _deadline != null;

  @override
  void initState() {
    super.initState();
    _recompute(initial: true);
  }

  @override
  void didUpdateWidget(covariant OpponentRequestCard old) {
    super.didUpdateWidget(old);
    if (old.request.status != widget.request.status ||
        old.request.acceptDeadline != widget.request.acceptDeadline ||
        old.request.createdAt != widget.request.createdAt) {
      _ticker?.cancel();
      _ticker = null;
      _recompute(initial: true);
    }
  }

  void _recompute({bool initial = false}) {
    if (!_hasCountdown) {
      if (_remaining != Duration.zero) {
        setState(() => _remaining = Duration.zero);
      }
      return;
    }
    final remaining = _deadline!.difference(DateTime.now());
    if (remaining.inSeconds <= 0) {
      _ticker?.cancel();
      _ticker = null;
      if (mounted) setState(() => _remaining = Duration.zero);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onExpire();
      });
      return;
    }
    if (initial) {
      _remaining = remaining;
      _ticker ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => _recompute(),
      );
    } else if (mounted) {
      setState(() => _remaining = remaining);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatRemaining(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Footer label for the invitation review action on my own requests.
  String _invitationsLabel(OpponentRequestModel request) {
    final int count = request.invitations.length;
    if (count == 0) return 'Awaiting Invitations';
    return count == 1 ? 'Review Invitation' : 'Review $count Invitations';
  }

  Future<void> _confirmIgnore(BuildContext context) async {
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: 'Ignore this request?',
      message:
          '${widget.request.team} will not receive an acceptance from you and '
          'the request leaves your list.',
      confirmText: 'Ignore',
    );
    if (confirmed) widget.onIgnore();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: StringConstants.removeRequest,
      message:
          'This will remove the request from ${widget.request.team}. You can\'t undo this.',
      confirmText: StringConstants.remove,
    );
    if (confirmed) widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final request = widget.request;
    final emphasised = request.status == RequestStatus.fresh;
    final isExpired = request.status == RequestStatus.expired;
    final showCountdown = _hasCountdown && _remaining.inSeconds > 0;
    final urgent = showCountdown && _remaining.inMinutes < 5;

    final String priceText;
    if (request.myPct == null) {
      priceText =
          '${OpponentFmt.npr(request.yourShare)} if loser · ${OpponentFmt.npr(request.totalFee)} total';
    } else {
      priceText =
          '${OpponentFmt.npr(request.yourShare)} · ${request.myPct}% of ${OpponentFmt.npr(request.totalFee)}';
    }

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        // Tapping follows the request's stage: the confirmed match, or the
        // invitations I still have to choose between.
        onTap: request.isMatchConfirmed
            ? widget.onMatchDetails
            : _isMine(request)
            ? widget.onInvitations
            : null,
        onLongPress: () => _confirmDelete(context),
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            border: Border.all(
              color: emphasised
                  ? LightColor.secondaryColor.withValues(alpha: 0.35)
                  : LightColor.dividerColor,
              width: 1,
            ),
            // Fresh requests glow softly in the brand green — same accent
            // language as the segmented tab bar indicator.
            boxShadow: [
              BoxShadow(
                color: emphasised
                    ? LightColor.secondaryColor.withValues(alpha: 0.12)
                    : LightColor.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 2),
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
                        color: LightColor.secondaryColor.withValues(
                          alpha: 0.12,
                        ),
                      ),
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
                            Icon(
                              Icons.access_time_rounded,
                              size: 9,
                              color: LightColor.hintTextColor,
                            ),
                            const SizedBox(width: AppDimens.paddingX4),
                            Flexible(
                              child: Text(
                                '${OpponentFmt.friendlyDateTime(request.dateTime)} · ${request.summary}',
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
                  if (widget.onMessage != null) ...[
                    _MessageIconButton(onTap: widget.onMessage!),
                    const SizedBox(width: AppDimens.paddingX6),
                  ],
                  OpponentStatusBadge(status: request.status),
                ],
              ),
              if (showCountdown) ...[
                const SizedBox(height: AppDimens.paddingX10),
                OpponentCountdownPill(
                  value: _formatRemaining(_remaining),
                  urgent: urgent,
                ),
              ],
              const SizedBox(height: AppDimens.paddingX12),
              _InfoMini(icon: Icons.event_outlined, label: request.slot),
              const SizedBox(height: AppDimens.paddingX6),
              _InfoMini(icon: Icons.location_on_outlined, label: request.venue),
              const SizedBox(height: AppDimens.paddingX6),
              _InfoMini(
                icon: Icons.payments_outlined,
                label: priceText,
                emphasised: true,
              ),
              if (_isMine(request) && request.invitations.isNotEmpty) ...[
                const SizedBox(height: AppDimens.paddingX6),
                _InfoMini(
                  icon: Icons.groups_2_outlined,
                  label: request.isMatchConfirmed
                      ? 'Opponent: ${request.selectedInvitation?.teamName ?? request.acceptedByTeamName}'
                      : '${request.invitations.length} '
                            '${request.invitations.length == 1 ? 'team wants' : 'teams want'} '
                            'to play — pick one',
                  emphasised: true,
                ),
              ],
              const SizedBox(height: AppDimens.paddingX12),
              if (isExpired) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: LightColor.dividerColor,
                ),
                const _FooterNote(
                  icon: Icons.hourglass_disabled_rounded,
                  label: StringConstants.closedAcceptWindowExpired,
                ),
              ] else if (request.isMatchConfirmed)
                // Match created & venue linked — both teams open the same
                // confirmed-match view (fixture, venue, chat room).
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingX6),
                  child: _ActionButton(
                    icon: Icons.emoji_events_outlined,
                    label: 'View Match Details',
                    foreground: LightColor.inverseTextColor,
                    background: LightColor.secondaryColor,
                    glow: true,
                    onTap: widget.onMatchDetails,
                  ),
                )
              else if (request.status == RequestStatus.invitationSent) ...[
                if (_isMine(request))
                  // A team accepted: review the invitation(s) and select the
                  // opponent.
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.paddingX6),
                    child: _ActionButton(
                      icon: Icons.mark_email_unread_outlined,
                      label: _invitationsLabel(request),
                      foreground: LightColor.inverseTextColor,
                      background: LightColor.secondaryColor,
                      glow: true,
                      onTap: widget.onInvitations,
                    ),
                  )
                else ...[
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: LightColor.dividerColor,
                  ),
                  const _FooterNote(
                    icon: Icons.hourglass_top_rounded,
                    label:
                        'Acceptance sent — waiting for the requester to '
                        'pick an opponent',
                    color: LightColor.secondaryColor,
                  ),
                ],
              ] else if (request.status.isOpen)
                // Accept → choose my team and send the acceptance. Ignore →
                // the request drops off my list; the countdown closes it
                // anyway if nobody replies.
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingX6),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.close_rounded,
                          label: 'Ignore',
                          foreground: LightColor.secondaryTextColor,
                          background: LightColor.dividerColor.withValues(
                            alpha: 0.45,
                          ),
                          onTap: () => _confirmIgnore(context),
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX8),
                      Expanded(
                        flex: 2,
                        child: _ActionButton(
                          icon: Icons.handshake_outlined,
                          label: 'Accept Request',
                          foreground: LightColor.inverseTextColor,
                          background: LightColor.secondaryColor,
                          glow: true,
                          onTap: widget.onAccept,
                        ),
                      ),
                    ],
                  ),
                )
              else if (request.status == RequestStatus.sent)
                // My published request: visible to eligible teams. Review the
                // invitations as they arrive; removable until one is picked.
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingX6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _ActionButton(
                          icon: Icons.mark_email_unread_outlined,
                          label: _invitationsLabel(request),
                          foreground: request.invitations.isEmpty
                              ? LightColor.secondaryColor
                              : LightColor.inverseTextColor,
                          background: request.invitations.isEmpty
                              ? LightColor.secondaryColor.withValues(
                                  alpha: 0.10,
                                )
                              : LightColor.secondaryColor,
                          glow: request.invitations.isNotEmpty,
                          onTap: widget.onInvitations,
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX8),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: StringConstants.remove,
                          foreground: LightColor.redColor,
                          background: LightColor.redLightColor,
                          onTap: () => _confirmDelete(context),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: LightColor.dividerColor,
                ),
                _FooterNote(
                  icon: switch (request.status) {
                    RequestStatus.accepted => Icons.check_circle_rounded,
                    RequestStatus.rejected => Icons.cancel_outlined,
                    _ => Icons.outgoing_mail,
                  },
                  label: request.status.label,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color fg = color ?? LightColor.hintTextColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimens.sizeX16, color: fg),
          const SizedBox(width: AppDimens.paddingX6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: FutsalTheme.getTextTheme(
                context,
              ).bodyTextSmall?.copyWith(color: fg, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact chat entry in the card header — pre-accept vetting and
/// post-accept coordination with the requester.
class _MessageIconButton extends StatelessWidget {
  const _MessageIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.secondaryColor.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(AppDimens.paddingX6),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            size: AppDimens.sizeX16,
            color: LightColor.secondaryColor,
          ),
        ),
      ),
    );
  }
}

class _InfoMini extends StatelessWidget {
  const _InfoMini({
    required this.icon,
    required this.label,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final color = emphasised
        ? LightColor.primaryTextColor
        : LightColor.secondaryTextColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: emphasised
              ? LightColor.secondaryColor
              : LightColor.hintTextColor,
        ),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: color,
              fontWeight: emphasised ? FontWeight.w700 : FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tinted (Reject) or filled (Accept) pill action at the foot of an open
/// request card. [glow] adds the same soft brand shadow as the tab indicator.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.onTap,
    this.glow = false,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: background.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          child: Container(
            height: AppDimens.sizeX40,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppDimens.sizeX16, color: foreground),
                const SizedBox(width: AppDimens.paddingX6),
                Text(
                  label,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
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

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests({required this.filter});

  final RequestFilter filter;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final (title, body) = switch (filter) {
      RequestFilter.all => (
        'No requests yet',
        'Create a request to challenge an opponent.',
      ),
      RequestFilter.open => (
        'Nothing to act on',
        'Open requests will appear here.',
      ),
      RequestFilter.mine => (
        'No requests sent',
        'Requests you send to opponents will appear here while they wait for a reply.',
      ),
      RequestFilter.settled => (
        'No settled requests',
        'Accepted, rejected and closed requests will show here.',
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
