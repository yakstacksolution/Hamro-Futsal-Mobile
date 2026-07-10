import 'dart:async';

import 'package:file_picker/file_picker.dart';
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
import 'package:hamro_footsall/core/widgets/payment_qr_card.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_accept_quote_model.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/accept_request_bloc/accept_request_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/models/opponent_cost_split.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';

/// Two-step "Accept & Pay" flow for an incoming opponent request:
///
/// 1. Pick which of my teams plays (roster + per-player share preview).
/// 2. Pay the server-quoted advance — QR + payment-proof upload — inside the
///    accept hold's countdown, then submit.
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
  static const List<String> _docExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
  static const int _maxDocBytes = 10 * 1024 * 1024;

  final _noteCtrl = TextEditingController();

  TeamModel? _team;
  PlatformFile? _paymentDoc;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    final teams = context.read<OpponentMatchBloc>().state.teams;
    if (teams.isEmpty) {
      context.read<OpponentMatchBloc>().add(const LoadTeamsEvent());
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  /// `5v5` → 5; 0 when the request carries no parsable format.
  int get _formatSize {
    final match = RegExp(r'(\d+)\s*v\s*\d+').firstMatch(widget.request.summary);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  void _continueToPayment() {
    final team = _team;
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
      LoadAcceptQuoteEvent(requestId: widget.request.id, teamId: team.id),
    );
  }

  Future<void> _pickPaymentDoc() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _docExtensions,
    );
    final PlatformFile? file = result?.files.singleOrNull;
    if (file == null || !mounted || file.path == null) return;
    if (file.size > _maxDocBytes) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Payment proof must be smaller than 10 MB.',
        key: 'doc_too_large',
      );
      return;
    }
    setState(() => _paymentDoc = file);
  }

  void _submit(OpponentAcceptQuoteModel quote) {
    if (_paymentDoc?.path == null) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Please upload your payment proof.',
        key: 'doc_required',
      );
      return;
    }
    if (!_agreedToTerms) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Please accept the advance-payment policy.',
        key: 'terms_required',
      );
      return;
    }
    HapticFeedback.mediumImpact();
    context.read<AcceptOpponentRequestBloc>().add(
      SubmitAcceptEvent(
        AcceptOpponentRequestRequest(
          requestId: widget.request.id,
          teamId: _team?.id ?? '',
          holdToken: quote.holdToken,
          paymentProofPath: _paymentDoc!.path!,
          paymentNote: _noteCtrl.text.trim().isEmpty
              ? null
              : _noteCtrl.text.trim(),
        ),
      ),
    );
  }

  /// 409 (taken by another team) and 410 (expired) end the flow — tell the
  /// user, pop, and let the list refresh to the server's truth.
  void _handleTerminalError(AcceptRequestState state) {
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

  void _onHoldExpired() {
    AppUtils().showSnackBar(
      context,
      MsgType.info,
      'The payment window expired — please confirm your team again.',
      key: 'hold_expired',
    );
    setState(() {
      _paymentDoc = null;
      _agreedToTerms = false;
    });
    context.read<AcceptOpponentRequestBloc>().add(
      const ResetAcceptQuoteEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.acceptAndPay),
      body: SafeArea(
        top: false,
        child:
            BlocConsumer<AcceptOpponentRequestBloc, AcceptRequestState>(
              listener: (context, state) {
                if (state.submitStatus == AcceptRequestStatus.success &&
                    state.result != null) {
                  AppUtils().showSnackBar(
                    context,
                    MsgType.success,
                    StringConstants.advanceSubmittedPendingVerification,
                  );
                  Navigator.of(context).pop(state.result);
                  return;
                }
                if (state.submitStatus == AcceptRequestStatus.failure ||
                    state.quoteStatus == AcceptRequestStatus.failure) {
                  _handleTerminalError(state);
                }
              },
              builder: (context, state) {
                final quote = state.quote;
                final bool onPayStep =
                    state.quoteStatus == AcceptRequestStatus.success &&
                    quote != null;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: onPayStep
                      ? _PaymentStep(
                          key: const ValueKey('pay'),
                          request: widget.request,
                          quote: quote,
                          team: _team,
                          paymentDoc: _paymentDoc,
                          agreedToTerms: _agreedToTerms,
                          noteCtrl: _noteCtrl,
                          submitting:
                              state.submitStatus == AcceptRequestStatus.loading,
                          onPick: _pickPaymentDoc,
                          onRemoveDoc: () =>
                              setState(() => _paymentDoc = null),
                          onTerms: (v) => setState(() => _agreedToTerms = v),
                          onHoldExpired: _onHoldExpired,
                          onSubmit: () => _submit(quote),
                        )
                      : _TeamStep(
                          key: const ValueKey('team'),
                          request: widget.request,
                          selected: _team,
                          formatSize: _formatSize,
                          loadingQuote:
                              state.quoteStatus == AcceptRequestStatus.loading,
                          onSelect: (t) => setState(() => _team = t),
                          onContinue: _continueToPayment,
                        ),
                );
              },
            ),
      ),
    );
  }
}

/// ─────────────────────── Step 1: team confirmation ───────────────────────

class _TeamStep extends StatelessWidget {
  const _TeamStep({
    super.key,
    required this.request,
    required this.selected,
    required this.formatSize,
    required this.loadingQuote,
    required this.onSelect,
    required this.onContinue,
  });

  final OpponentRequestModel request;
  final TeamModel? selected;
  final int formatSize;
  final bool loadingQuote;
  final ValueChanged<TeamModel> onSelect;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
      builder: (context, state) {
        final teams = state.teams;
        return Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX20,
                  top: AppDimens.paddingX10,
                  bottom: AppDimens.paddingX20,
                ),
                children: [
                  _RequestSummaryCard(request: request),
                  const SizedBox(height: AppDimens.paddingX18),
                  const OpponentSectionLabel(
                    StringConstants.whichTeamWillPlay,
                  ),
                  if (state.teamsStatus == OpponentMatchStatus.loading &&
                      teams.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppDimens.paddingX24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (teams.isEmpty)
                    OpponentCard(
                      child: Text(
                        'You have no teams yet — create one on the My Teams '
                        'tab first.',
                        style: textTheme.bodyTextSmall?.copyWith(
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
                          request: request,
                          formatSize: formatSize,
                          selected: team.id == selected?.id,
                          onTap: () => onSelect(team),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _BottomAction(
              text: StringConstants.confirmTeamAndContinue,
              icon: Icons.arrow_forward_rounded,
              busy: loadingQuote,
              enabled: selected != null,
              onTap: onContinue,
            ),
          ],
        );
      },
    );
  }
}

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
                            border: Border.all(
                              color: LightColor.dividerColor,
                            ),
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

/// ─────────────────────── Step 2: advance payment ───────────────────────

class _PaymentStep extends StatefulWidget {
  const _PaymentStep({
    super.key,
    required this.request,
    required this.quote,
    required this.team,
    required this.paymentDoc,
    required this.agreedToTerms,
    required this.noteCtrl,
    required this.submitting,
    required this.onPick,
    required this.onRemoveDoc,
    required this.onTerms,
    required this.onHoldExpired,
    required this.onSubmit,
  });

  final OpponentRequestModel request;
  final OpponentAcceptQuoteModel quote;
  final TeamModel? team;
  final PlatformFile? paymentDoc;
  final bool agreedToTerms;
  final TextEditingController noteCtrl;
  final bool submitting;
  final VoidCallback onPick;
  final VoidCallback onRemoveDoc;
  final ValueChanged<bool> onTerms;
  final VoidCallback onHoldExpired;
  final VoidCallback onSubmit;

  @override
  State<_PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<_PaymentStep> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _tick() {
    final expiresAt = widget.quote.holdExpiresAt;
    if (expiresAt == null) return;
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.inSeconds <= 0) {
      _ticker?.cancel();
      _ticker = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onHoldExpired();
      });
      return;
    }
    if (mounted) setState(() => _remaining = remaining);
  }

  String get _remainingLabel {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final quote = widget.quote;
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX20,
              top: AppDimens.paddingX10,
              bottom: AppDimens.paddingX20,
            ),
            children: [
              if (quote.holdExpiresAt != null)
                OpponentCountdownPill(
                  value: _remainingLabel,
                  urgent: _remaining.inMinutes < 2,
                  label: StringConstants.completePaymentWithin,
                ),
              const SizedBox(height: AppDimens.paddingX14),
              OpponentCard(
                child: Column(
                  children: [
                    _QuoteRow(
                      label: 'Total court fee',
                      value: OpponentFmt.npr(quote.totalFee),
                    ),
                    const SizedBox(height: AppDimens.paddingX8),
                    _QuoteRow(
                      label:
                          '${StringConstants.yourTeamShare}'
                          '${widget.team == null ? '' : ' (${widget.team!.name})'}',
                      value: OpponentFmt.npr(quote.accepterShare),
                    ),
                    const SizedBox(height: AppDimens.paddingX8),
                    _QuoteRow(
                      label: StringConstants.advanceToPay,
                      value: OpponentFmt.npr(quote.advancePayableNow),
                      emphasised: true,
                    ),
                    const SizedBox(height: AppDimens.paddingX8),
                    _QuoteRow(
                      label: 'Balance due later',
                      value: OpponentFmt.npr(quote.balanceDueLater),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.paddingX18),
              const OpponentSectionLabel('Payment'),
              PaymentQrCard(
                qr: quote.paymentQr,
                amountLabel: StringConstants.advanceToPay,
                amountValue: OpponentFmt.npr(quote.advancePayableNow),
              ),
              const SizedBox(height: AppDimens.paddingX18),
              const OpponentSectionLabel(StringConstants.paymentProof),
              _ProofTile(
                file: widget.paymentDoc,
                onPick: widget.onPick,
                onRemove: widget.onRemoveDoc,
              ),
              const SizedBox(height: AppDimens.paddingX14),
              CustomTextField(
                controller: widget.noteCtrl,
                labelText: 'Payment note',
                hintText: 'Transaction id, remarks… (optional)',
                icon: Icons.sticky_note_2_outlined,
                isRequired: false,
              ),
              const SizedBox(height: AppDimens.paddingX14),
              OpponentCard(
                child: Text(
                  StringConstants.advancePolicyNote,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingX12),
              InkWell(
                onTap: () => widget.onTerms(!widget.agreedToTerms),
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                child: Padding(
                  padding: AppUtils().getPadding(all: AppDimens.paddingX4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        widget.agreedToTerms
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: widget.agreedToTerms
                            ? LightColor.secondaryColor
                            : LightColor.hintTextColor,
                        size: AppDimens.sizeX20,
                      ),
                      const SizedBox(width: AppDimens.paddingX8),
                      Expanded(
                        child: Text(
                          StringConstants
                              .iConfirmMyTeamWillPlayAndAcceptAdvancePolicy,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.primaryTextColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _BottomAction(
          text: StringConstants.submitAndAccept,
          icon: Icons.check_rounded,
          busy: widget.submitting,
          enabled: widget.paymentDoc != null && widget.agreedToTerms,
          onTap: widget.onSubmit,
        ),
      ],
    );
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({
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
      children: [
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
          style: (emphasised ? textTheme.bodyTextMedium : textTheme.bodyTextSmall)
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

class _ProofTile extends StatelessWidget {
  const _ProofTile({
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  final PlatformFile? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final picked = file;
    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Container(
          padding: AppUtils().getPadding(all: AppDimens.paddingX14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: picked == null
                  ? LightColor.dividerColor
                  : LightColor.secondaryColor.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Icon(
                picked == null
                    ? Icons.upload_file_rounded
                    : Icons.task_rounded,
                color: picked == null
                    ? LightColor.hintTextColor
                    : LightColor.secondaryColor,
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Text(
                  picked?.name ??
                      'Upload the payment screenshot (jpg, png or pdf).',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: picked == null
                        ? LightColor.secondaryTextColor
                        : LightColor.primaryTextColor,
                    fontWeight: picked == null
                        ? FontWeight.w500
                        : FontWeight.w600,
                  ),
                ),
              ),
              if (picked != null)
                IconButton(
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: AppDimens.sizeX18,
                    color: LightColor.hintTextColor,
                  ),
                ),
            ],
          ),
        ),
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
          Text(
            request.team,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX6),
          Text(
            '${OpponentFmt.friendlyDateTime(request.dateTime)}'
            '${request.summary.isEmpty ? '' : ' · ${request.summary}'}',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          Text(
            [
              request.slot,
              request.venue,
            ].where((s) => s.isNotEmpty).join(' · '),
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
        ],
      ),
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
