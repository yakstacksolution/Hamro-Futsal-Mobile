import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_sheets.dart';

/// How long a `New` incoming request stays acceptable.
const Duration kAcceptWindow = Duration(minutes: 20);

enum RequestFilter { all, open, settled }

extension RequestFilterX on RequestFilter {
  String get label => switch (this) {
    RequestFilter.all => 'All',
    RequestFilter.open => 'Open',
    RequestFilter.settled => 'Settled',
  };
}

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
        RequestFilter.open =>
          requests.where((r) => r.status.isOpen).toList(),
        RequestFilter.settled =>
          requests.where((r) => r.status.isSettled).toList(),
      };

  int _count(List<OpponentRequestModel> requests, RequestFilter f) =>
      switch (f) {
        RequestFilter.all => requests.length,
        RequestFilter.open => requests.where((r) => r.status.isOpen).length,
        RequestFilter.settled =>
          requests.where((r) => r.status.isSettled).length,
      };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
      builder: (context, state) {
        final bloc = context.read<OpponentMatchBloc>();
        final requests = _filtered(state.requests);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          onAccept: () => bloc.add(
                            UpdateRequestStatusEvent(
                              request,
                              RequestStatus.accepted,
                            ),
                          ),
                          onReject: () => bloc.add(
                            UpdateRequestStatusEvent(
                              request,
                              RequestStatus.rejected,
                            ),
                          ),
                          onDelete: () =>
                              bloc.add(DeleteOpponentRequestEvent(request)),
                          onExpire: () {
                            if (request.status == RequestStatus.fresh) {
                              bloc.add(
                                UpdateRequestStatusEvent(
                                  request,
                                  RequestStatus.expired,
                                ),
                              );
                            }
                          },
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
    required this.onReject,
    required this.onDelete,
    required this.onExpire,
  });

  final OpponentRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onDelete;
  final VoidCallback onExpire;

  @override
  State<OpponentRequestCard> createState() => _OpponentRequestCardState();
}

class _OpponentRequestCardState extends State<OpponentRequestCard> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  bool get _hasCountdown =>
      widget.request.status == RequestStatus.fresh &&
      widget.request.createdAt != null;

  @override
  void initState() {
    super.initState();
    _recompute(initial: true);
  }

  @override
  void didUpdateWidget(covariant OpponentRequestCard old) {
    super.didUpdateWidget(old);
    if (old.request.status != widget.request.status ||
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
    final elapsed = DateTime.now().difference(widget.request.createdAt!);
    final remaining = kAcceptWindow - elapsed;
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

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => ConfirmDeleteSheet(
        title: 'Remove request?',
        message:
            'This will remove the request from ${widget.request.team}. You can\'t undo this.',
        onConfirm: () {
          Navigator.pop(ctx);
          widget.onDelete();
        },
      ),
    );
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
        onTap: () {},
        onLongPress: () => _confirmDelete(context),
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            border: Border.all(
              color: emphasised
                  ? LightColor.secondaryColor.withValues(alpha: 0.18)
                  : LightColor.dividerColor,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 2),
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
                      color: LightColor.secondaryColor.withValues(alpha: 0.10),
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
                            fontWeight: emphasised
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
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
                  OpponentStatusBadge(status: request.status),
                ],
              ),
              if (showCountdown) ...[
                const SizedBox(height: AppDimens.paddingX10),
                _CountdownPill(
                  label: _formatRemaining(_remaining),
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
              const SizedBox(height: AppDimens.paddingX12),
              const Divider(
                height: 1,
                thickness: 1,
                color: LightColor.dividerColor,
              ),
              if (isExpired)
                const _FooterNote(
                  icon: Icons.hourglass_disabled_rounded,
                  label: 'Accept window expired',
                )
              else if (request.status.isOpen)
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.close_rounded,
                        label: 'Reject',
                        onTap: widget.onReject,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 18,
                      color: LightColor.dividerColor,
                    ),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Accept',
                        emphasised: true,
                        onTap: widget.onAccept,
                      ),
                    ),
                  ],
                )
              else
                _FooterNote(
                  icon: switch (request.status) {
                    RequestStatus.accepted => Icons.check_circle_rounded,
                    RequestStatus.rejected => Icons.cancel_outlined,
                    _ => Icons.outgoing_mail,
                  },
                  label: request.status == RequestStatus.sent
                      ? 'Awaiting reply'
                      : request.status.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimens.sizeX16, color: LightColor.hintTextColor),
          const SizedBox(width: AppDimens.paddingX6),
          Text(
            label,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.label, required this.urgent});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color fg = urgent ? LightColor.redColor : LightColor.secondaryColor;
    final Color bg = urgent
        ? LightColor.redLightColor
        : LightColor.secondaryColor.withValues(alpha: 0.10);
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      ),
      child: Row(
        children: [
          Icon(
            urgent ? Icons.timer_rounded : Icons.timer_outlined,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: AppDimens.paddingX6),
          Text(
            'Accept within',
            style: textTheme.bodyTextSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: textTheme.bodyTextMedium?.copyWith(
              color: fg,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool enabled = onTap != null;
    final Color color = !enabled
        ? LightColor.disabledTextColor
        : (emphasised
              ? LightColor.secondaryColor
              : LightColor.secondaryTextColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimens.sizeX16, color: color),
            const SizedBox(width: AppDimens.paddingX6),
            Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: color,
                fontWeight: emphasised ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
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
      RequestFilter.settled => (
        'No settled requests',
        'Accepted, rejected and sent requests will show here.',
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
