import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_launcher.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/pages/opponent_match_details_page.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';

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
    // This is the server call that locks the match in for the chosen team and
    // closes the request for everyone else.
    context.read<OpponentMatchBloc>().add(SelectOpponentEvent(request));
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
                    onRefresh: () async => context
                        .read<OpponentMatchBloc>()
                        .add(const LoadOpponentRequestsEvent()),
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
                        if (invitations.isEmpty)
                          const _WaitingCard()
                        else
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
                    ),
                  ),
                ),
                if (!request.isMatchConfirmed && invitations.isNotEmpty)
                  _SelectFooter(
                    enabled: selected != null,
                    othersCount: request.pendingInvitations
                        .where((i) => i.id != selected?.id)
                        .length,
                    onConfirm: selected == null
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
              OpponentStatusBadge(status: request.status),
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

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool rejected = invitation.status == InvitationStatus.rejected;
    final int share = invitation.share > 0
        ? invitation.share
        : request.totalFee - request.yourShare;
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
                            <String>[
                              if (invitation.captainName.isNotEmpty)
                                invitation.captainName,
                              if (invitation.playerCount > 0)
                                '${invitation.playerCount} players',
                              if (invitation.acceptedAt != null)
                                'accepted ${OpponentFmt.friendlyDateTime(invitation.acceptedAt!)}',
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMiniSubTitle?.copyWith(
                              color: LightColor.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onMessage != null)
                      IconButton(
                        onPressed: onMessage,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Message captain',
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: AppDimens.sizeX18,
                          color: LightColor.secondaryColor,
                        ),
                      ),
                    if (selectable)
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
                ),
                const SizedBox(height: AppDimens.paddingX12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _Line(
                        icon: Icons.payments_outlined,
                        text: 'Their share ${OpponentFmt.npr(share)}',
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
                            ? 'Chat before deciding'
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
    required this.othersCount,
    required this.onConfirm,
  });

  final bool enabled;
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
