import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_futsal/features/message/presentation/pages/chat_launcher.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/pages/opponent_match_details_page.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_common.dart';

/// The requester's side of the flow after publishing: every team that accepted
/// the request arrives here as an invitation. The requester can wait for more,
/// review each one, then select a single opponent — which rejects the rest.
class OpponentInvitationsPage extends StatefulWidget {
  const OpponentInvitationsPage({super.key, required this.requestId});

  /// Read from the bloc by id so the page follows list refreshes.
  final String requestId;

  @override
  State<OpponentInvitationsPage> createState() =>
      _OpponentInvitationsPageState();
}

class _OpponentInvitationsPageState extends State<OpponentInvitationsPage> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    context.read<OpponentMatchBloc>().add(
      LoadInvitationsEvent(widget.requestId),
    );
  }

  void _reload() => context.read<OpponentMatchBloc>().add(
    LoadInvitationsEvent(widget.requestId, force: true),
  );

  OpponentRequestModel? _request(OpponentMatchState state) =>
      state.requestById(widget.requestId);

  Future<void> _confirmOpponent(
    OpponentRequestModel request,
    OpponentInvitationModel invitation,
  ) async {
    final int others = request.pendingInvitations
        .where((i) => i.id != invitation.id)
        .length;
    final bool confirmed = await showConfirmDialog(
      context: context,
      title: 'Play ${invitation.teamName}?',
      message: others == 0
          ? 'The match will be created and the venue linked to this request. '
                'A chat room with ${invitation.teamName} opens automatically.'
          : 'The match will be created with ${invitation.teamName} and the '
                'venue linked to this request. The other $others '
                '${others == 1 ? 'invitation' : 'invitations'} will be '
                'rejected automatically.',
      confirmText: 'Confirm opponent',
      icon: Icons.handshake_outlined,
    );
    if (!confirmed || !mounted) return;
    HapticFeedback.mediumImpact();
    // `POST /auth/opponent-requests/{id}/invitations/{invitationId}/accept` —
    // the server call that locks the match in for the chosen team and closes
    // the request for everyone else.
    final OpponentMatchBloc bloc = context.read<OpponentMatchBloc>();
    bloc.add(SelectOpponentEvent(request, invitation));

    // The match only exists once the server says so, so the confirmation waits
    // for the call rather than announcing a match that may have been refused —
    // another team may have been picked, or the window may have closed.
    final OpponentMatchState result = await bloc.stream.firstWhere(
      (OpponentMatchState s) =>
          s.selectOpponentStatus != OpponentMatchStatus.loading,
    );
    if (!mounted) return;

    if (result.selectOpponentStatus == OpponentMatchStatus.failure) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        result.selectOpponentError ?? StringConstants.somethingWentWrong,
        key: 'opponent_select_failed',
      );
      return;
    }
    AppUtils().showSnackBar(
      context,
      MsgType.success,
      others == 0
          ? 'Match confirmed with ${invitation.teamName}.'
          : 'Match confirmed with ${invitation.teamName}. '
                '$others ${others == 1 ? 'invitation' : 'invitations'} '
                'auto-rejected.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Invitations'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
          builder: (context, state) {
            final OpponentRequestModel? request = _request(state);
            if (request == null) {
              // The row is looked up by id across the fetched tabs, so a page
              // opened before (or alongside) that fetch has nothing yet — that
              // is loading, not a request that has gone away.
              if (state.isLoadingAnyRequests) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: LightColor.secondaryColor,
                  ),
                );
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.paddingX32),
                  child: Text('This request is no longer available.'),
                ),
              );
            }
            final List<OpponentInvitationModel> invitations =
                request.invitations;
            final OpponentInvitationModel? selected = _resolveSelection(
              request,
            );

            return Column(
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    color: LightColor.secondaryColor,
                    onRefresh: () async {
                      _reload();
                      context.read<OpponentMatchBloc>().add(
                        const LoadOpponentRequestsEvent(),
                      );
                    },
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: AppUtils().getPadding(
                        symmetricHorizontal: AppDimens.paddingX20,
                        top: AppDimens.paddingX12,
                        bottom: AppDimens.paddingX24,
                      ),
                      children: <Widget>[
                        OpponentGuidanceCard(
                          icon: Icons.mark_email_unread_outlined,
                          title: invitations.isEmpty
                              ? 'Waiting for invitations'
                              : 'Select one opponent',
                          message: invitations.isEmpty
                              ? 'Your request is visible to all eligible teams. '
                                    'As soon as a team accepts, its invitation '
                                    'appears here.'
                              : 'Message a captain to agree the details, then '
                                    'confirm the team you trust. You can wait '
                                    'for more acceptances first — the '
                                    'remaining invitations are rejected '
                                    'automatically once you confirm one.',
                        ),
                        const SizedBox(height: AppDimens.paddingX16),
                        _RequestStrip(request: request),
                        const SizedBox(height: AppDimens.paddingX18),
                        if (request.isMatchConfirmed)
                          _ConfirmedBanner(
                            request: request,
                            onOpen: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<OpponentMatchBloc>(),
                                  child: OpponentMatchDetailsPage(
                                    requestId: request.id,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          OpponentSectionLabel(
                            invitations.isEmpty
                                ? 'No invitations yet'
                                : '${invitations.length} '
                                      '${invitations.length == 1 ? 'invitation' : 'invitations'} received',
                          ),
                        if (invitations.isEmpty &&
                            state.isLoadingInvitations(request.id))
                          const _InvitationsLoading()
                        else if (invitations.isEmpty &&
                            state.invitationErrorFor(request.id) != null)
                          _InvitationsError(
                            message: state.invitationErrorFor(request.id)!,
                            onRetry: _reload,
                          )
                        else if (invitations.isEmpty)
                          const _WaitingCard()
                        else ...<Widget>[
                          // Rows are already on screen, so a refetch reports
                          // itself here instead of replacing them.
                          if (state.isLoadingInvitations(request.id))
                            const _RefreshingStrip(),
                          ...invitations.map(
                            (invitation) => Padding(
                              padding: AppUtils().getPadding(
                                bottom: AppDimens.paddingX12,
                              ),
                              child: _InvitationCard(
                                invitation: invitation,
                                request: request,
                                selected: invitation.id == selected?.id,
                                selectable:
                                    !request.isMatchConfirmed &&
                                    invitation.status ==
                                        InvitationStatus.pending,
                                onSelect: () =>
                                    setState(() => _selectedId = invitation.id),
                                onMessage: invitation.captainUserId > 0
                                    ? () => ChatLauncher.startDirectUser(
                                        context,
                                        userId: invitation.captainUserId,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Once one of the invitations is `selected` the choice is made
                // and cannot be remade, so the footer goes away — the request's
                // own status can lag a beat behind that, which is why the
                // invitation is what gates it rather than [isMatchConfirmed].
                if (!request.isMatchConfirmed &&
                    request.selectedInvitation == null &&
                    invitations.isNotEmpty)
                  _SelectFooter(
                    enabled: selected != null && !state.isSelectingOpponent,
                    busy: state.isSelectingOpponent,
                    othersCount: request.pendingInvitations
                        .where((i) => i.id != selected?.id)
                        .length,
                    onConfirm: selected == null || state.isSelectingOpponent
                        ? null
                        : () => _confirmOpponent(request, selected),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The card currently marked for confirmation: the requester's tap, the
  /// server's selection, or — with a single invitation — that one.
  OpponentInvitationModel? _resolveSelection(OpponentRequestModel request) {
    final OpponentInvitationModel? confirmed = request.selectedInvitation;
    if (confirmed != null) return confirmed;
    for (final i in request.invitations) {
      if (i.id == _selectedId) return i;
    }
    final pending = request.pendingInvitations;
    return pending.length == 1 ? pending.first : null;
  }
}

/// Placeholder cards standing in for the invitations being fetched. Shaped like
/// the real ones so the list does not jump when they land, and carrying one
/// spinner so the wait is legible as work in progress.
class _InvitationsLoading extends StatelessWidget {
  const _InvitationsLoading();

  /// Two is enough to read as a list without pretending to know how many
  /// invitations are coming.
  static const int _cards = 2;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      children: <Widget>[
        for (int i = 0; i < _cards; i++)
          Padding(
            padding: AppUtils().getPadding(bottom: AppDimens.paddingX12),
            child: OpponentCard(
              child: Row(
                children: <Widget>[
                  Container(
                    width: AppDimens.sizeX40,
                    height: AppDimens.sizeX40,
                    decoration: BoxDecoration(
                      color: LightColor.dividerColor.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _LoadingBar(widthFactor: 0.45),
                        const SizedBox(height: AppDimens.paddingX8),
                        _LoadingBar(widthFactor: 0.7, height: AppDimens.sizeX8),
                      ],
                    ),
                  ),
                  if (i == 0) ...<Widget>[
                    const SizedBox(width: AppDimens.paddingX12),
                    const SizedBox(
                      width: AppDimens.sizeX18,
                      height: AppDimens.sizeX18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LightColor.secondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        Text(
          'Loading invitations…',
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: LightColor.hintTextColor,
          ),
        ),
      ],
    );
  }
}

/// Grey bar standing in for a line of text that has not arrived.
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.widthFactor,
    this.height = AppDimens.sizeX10,
  });

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: LightColor.dividerColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppDimens.radiusX4),
        ),
      ),
    );
  }
}

/// Quiet "checking for new invitations" line, shown above a list that already
/// has rows so a refresh never blanks them out.
class _RefreshingStrip extends StatelessWidget {
  const _RefreshingStrip();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(bottom: AppDimens.paddingX12),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: AppDimens.sizeX14,
            height: AppDimens.sizeX14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: LightColor.secondaryColor,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Text(
            'Checking for new invitations…',
            style: textTheme.bodyMiniSubTitle?.copyWith(
              color: LightColor.hintTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// The invitations call failed — say so and offer a retry, rather than showing
/// the "waiting for acceptances" card for a request that may well have some.
class _InvitationsError extends StatelessWidget {
  const _InvitationsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentCard(
      child: Column(
        children: <Widget>[
          Icon(
            Icons.cloud_off_rounded,
            size: AppDimens.sizeX28,
            color: LightColor.hintTextColor,
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          CustomButton(
            text: StringConstants.retry,
            icon: Icons.refresh_rounded,
            minHeight: AppDimens.sizeX44,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// Compact reminder of what was published, above the invitation list.
class _RequestStrip extends StatelessWidget {
  const _RequestStrip({required this.request});

  final OpponentRequestModel request;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  request.team,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              OpponentStatusBadge(
                status: request.status,
                label: request.statusBadgeLabel,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX8),
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
                ? '${OpponentFmt.npr(request.totalFee)} total · loser pays more'
                : '${OpponentFmt.npr(request.totalFee)} total · '
                      'your share ${OpponentFmt.npr(request.yourShare)} '
                      '(${request.myPct}%)',
          ),
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.request,
    required this.selected,
    required this.selectable,
    required this.onSelect,
    this.onMessage,
  });

  final OpponentInvitationModel invitation;
  final OpponentRequestModel request;
  final bool selected;
  final bool selectable;
  final VoidCallback onSelect;
  final VoidCallback? onMessage;

  /// What this team carries of the court fee.
  ///
  /// Under a result-keyed rule nothing is owed by a side until the match is
  /// played, and `yourShare` is 0 for it — so `totalFee - yourShare` quoted the
  /// whole fee as "their share", which is not what either team agreed to.
  String _shareLine() {
    if (invitation.share > 0) {
      return 'Their share ${OpponentFmt.npr(invitation.share)}';
    }
    if (request.isResultCost) {
      final int? loser = request.resolvedLoserAmount;
      final int? pct = request.resolvedLoserPercent;
      if (loser == null) return 'Loser pays — decided by the result';
      return 'If they lose ${OpponentFmt.npr(loser)}'
          '${pct == null ? '' : ' ($pct%)'}';
    }
    return 'Their share ${OpponentFmt.npr(request.totalFee - request.yourShare)}';
  }

  /// The subtitle under the team name: who is behind the invitation and when it
  /// arrived or was answered.
  String _metaLine() => <String>[
    if (invitation.captainName.isNotEmpty) invitation.captainName,
    if (invitation.playerCount > 0) '${invitation.playerCount} players',
    if (invitation.respondedAt != null)
      'answered ${OpponentFmt.friendlyDateTime(invitation.respondedAt!)}'
    else if (invitation.acceptedAt != null)
      'accepted ${OpponentFmt.friendlyDateTime(invitation.acceptedAt!)}',
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool rejected = invitation.status == InvitationStatus.rejected;
    return Opacity(
      opacity: rejected ? 0.6 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        child: InkWell(
          onTap: selectable ? onSelect : null,
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: AppUtils().getPadding(all: AppDimens.paddingX14),
            decoration: BoxDecoration(
              color: selected
                  ? LightColor.secondaryColor.withValues(alpha: 0.07)
                  : LightColor.cardColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX14),
              border: Border.all(
                color: selected
                    ? LightColor.secondaryColor
                    : LightColor.dividerColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: LightColor.secondaryColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusX12,
                        ),
                      ),
                      child: Text(
                        invitation.initials,
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
                        children: <Widget>[
                          Text(
                            invitation.teamName.isEmpty
                                ? 'Opponent team'
                                : invitation.teamName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextMedium?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimens.sizeX2),
                          Text(
                            _metaLine(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMiniSubTitle?.copyWith(
                              color: LightColor.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectable) ...<Widget>[
                      const SizedBox(width: AppDimens.paddingX8),
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        size: AppDimens.sizeX20,
                        color: selected
                            ? LightColor.secondaryColor
                            : LightColor.hintTextColor,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimens.paddingX12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _Line(
                        icon: Icons.payments_outlined,
                        text: _shareLine(),
                      ),
                    ),
                    _StatusPill(status: invitation.status),
                  ],
                ),
                if (invitation.message.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX10),
                  Container(
                    width: double.infinity,
                    padding: AppUtils().getPadding(all: AppDimens.paddingX10),
                    decoration: BoxDecoration(
                      color: LightColor.background,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    ),
                    child: Text(
                      invitation.message,
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                if (onMessage != null && !rejected) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX10),
                  // Talk to the captain before trusting them with the match.
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onMessage,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: LightColor.secondaryColor.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX10,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: AppDimens.sizeX16,
                        color: LightColor.secondaryColor,
                      ),
                      label: Text(
                        invitation.captainName.isEmpty
                            ? 'Chat with ${invitation.teamName.isEmpty ? 'this team' : invitation.teamName}'
                            : 'Chat with ${invitation.captainName}',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final InvitationStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg) = switch (status) {
      InvitationStatus.selected => (
        LightColor.successColor,
        LightColor.secondaryColor.withValues(alpha: 0.10),
      ),
      InvitationStatus.rejected => (
        LightColor.redColor,
        LightColor.redLightColor,
      ),
      InvitationStatus.pending => (
        LightColor.warningColor,
        LightColor.warningLightColor,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        status.label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

/// "Wait for more invitations" state, straight off the diagram's decision.
class _WaitingCard extends StatelessWidget {
  const _WaitingCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentCard(
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 28,
              color: LightColor.secondaryColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            'Waiting for teams to accept',
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX6),
          Text(
            'Pull down to refresh. You will be notified as invitations arrive.',
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmedBanner extends StatelessWidget {
  const _ConfirmedBanner({required this.request, required this.onOpen});

  final OpponentRequestModel request;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String opponent =
        request.selectedInvitation?.teamName.isNotEmpty == true
        ? request.selectedInvitation!.teamName
        : request.acceptedByTeamName;
    return Container(
      width: double.infinity,
      margin: AppUtils().getMargin(bottom: AppDimens.marginX16),
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.emoji_events_outlined,
                size: AppDimens.sizeX18,
                color: LightColor.secondaryColor,
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Expanded(
                child: Text(
                  opponent.isEmpty
                      ? 'Match confirmed'
                      : 'Match confirmed with $opponent',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          SizedBox(
            height: AppDimens.sizeX40,
            width: double.infinity,
            child: CustomButton(
              text: 'View match details',
              icon: Icons.arrow_forward_rounded,
              onPressed: onOpen,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectFooter extends StatelessWidget {
  const _SelectFooter({
    required this.enabled,
    required this.busy,
    required this.othersCount,
    required this.onConfirm,
  });

  final bool enabled;

  /// The confirm call is in flight — the button spins rather than accepting a
  /// second tap that would try to confirm the same invitation twice.
  final bool busy;
  final int othersCount;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
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
        child: Column(
          children: <Widget>[
            if (othersCount > 0)
              Padding(
                padding: AppUtils().getPadding(bottom: AppDimens.paddingX8),
                child: Text(
                  'Confirming rejects the other $othersCount '
                  '${othersCount == 1 ? 'invitation' : 'invitations'} '
                  'automatically.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ),
            SizedBox(
              height: AppDimens.sizeX54,
              width: double.infinity,
              child: CustomButton(
                text: 'Select This Opponent',
                icon: Icons.handshake_outlined,
                isLoading: busy,
                onPressed: enabled ? onConfirm : null,
              ),
            ),
          ],
        ),
      ),
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
      children: <Widget>[
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
