import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/features/account/presentation/bloc/account_bloc/account_bloc.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/presentation/utils/account_ui_utils.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';

typedef SettlementRequestDraft = ({
  double amount,
  String transactionReference,
  String? note,
  UploadAttachment paymentProof,
});

class RequestSettlementPage extends StatefulWidget {
  const RequestSettlementPage({
    super.key,
    required this.preview,
    this.venueName = '',
    this.commissionPayable = 0,
    this.totalEarned = 0,
    this.qrCodes = const <SettlementQrCodeModel>[],
    this.venueId,
  });

  final SettlementPreviewModel preview;

  /// Commission the venue owes Hamro Futsal, as the account summary reports it.
  /// A settlement pays this and nothing else, so it stands in when the preview
  /// carries no figure of its own — never the venue's cleared earnings.
  final double commissionPayable;

  /// Lifetime gross earnings, shown as context above the commission.
  final double totalEarned;

  /// `/auth/qr-codes` — every QR the commission may be sent to. Empty falls
  /// back to whatever QR the preview carried.
  final List<SettlementQrCodeModel> qrCodes;

  /// Set for a per-futsal settlement; null files a consolidated one.
  final int? venueId;

  /// Falls back into the scope line when the server sent no `subtitle`.
  final String venueName;

  @override
  State<RequestSettlementPage> createState() => _RequestSettlementPageState();
}

class _RequestSettlementPageState extends State<RequestSettlementPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  final _refCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  UploadAttachment? _proof;
  bool _proofMissing = false;
  String? _proofError;

  SettlementPreviewModel get _preview => widget.preview;

  List<SettlementQrCodeModel> get _qrCodes => widget.qrCodes;

  /// What this request pays: the commission owed to Hamro Futsal.
  ///
  /// The commission leads deliberately. `/auth/settlement-preview` returns the
  /// vendor's *cleared balance* in `maximum_payable` — the pot the commission
  /// was taken out of, not the debt — so honouring it billed the vendor several
  /// times what they owed. The preview's figure is kept only as a fallback for
  /// when the summary has no commission to report.
  double get _payable => widget.commissionPayable > 0
      ? widget.commissionPayable
      : _preview.maximumPayable;

  /// What the amount field is pre-filled with. The whole commission is the
  /// default, and the server's own `default_amount` is honoured only while it
  /// stays within that — it is derived from the same balance as
  /// [SettlementPreviewModel.maximumPayable] and overshoots for the same reason.
  double get _defaultAmount {
    final double preferred = _preview.defaultAmount > 0
        ? _preview.defaultAmount
        : _payable;
    return preferred > _payable ? _payable : preferred;
  }

  /// The whole commission must go in one request — the field is shown
  /// read-only rather than validated, so the rule is visible up front.
  bool get _amountLocked => _preview.exactAmountRequired;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: AccountFmt.amountInput(_defaultAmount),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '') ?? 0;
    if (amount <= 0) return 'Enter a valid amount.';
    if (amount > _payable) {
      return "Amount can't exceed ${AccountFmt.npr(_payable)}.";
    }
    // Compared in paisa: 11711.99 never equals itself in binary floating point.
    if (_amountLocked &&
        (amount * 100).round() != (_defaultAmount * 100).round()) {
      return 'Settle the full ${AccountFmt.npr(_defaultAmount)}.';
    }
    return null;
  }

  Future<void> _pickProof() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _preview.acceptedProofTypes,
      allowMultiple: false,
      // The bytes are read here, while the pick is fresh. Re-reading the path
      // at submit time is what produced 0-byte uploads: this form is filled in
      // between the two, and the OS can reclaim the picker's cached copy in
      // the meantime.
      withData: true,
    );
    final PlatformFile? file = result?.files.singleOrNull;
    if (!mounted || file == null) return;
    try {
      final UploadPolicy policy = UploadPolicy(
        allowedExtensions: _preview.acceptedProofTypes.toSet(),
        maxInputBytes: _preview.proofMaxBytes,
      );
      final UploadAttachment attachment;
      final Uint8List? pickedBytes = file.bytes;
      if (pickedBytes != null && pickedBytes.isNotEmpty) {
        attachment = await normalizeUploadAttachment(
          bytes: pickedBytes,
          filename: file.name,
          sourcePath: file.path,
          originalSize: file.size,
          policy: policy,
        );
      } else {
        attachment = await loadUploadAttachment(
          path: file.path ?? '',
          filename: file.name,
          policy: policy,
        );
      }
      if (!mounted) return;
      setState(() {
        _proof = attachment;
        _proofMissing = false;
        _proofError = null;
      });
    } on UploadValidationException catch (error) {
      if (!mounted) return;
      setState(() {
        _proof = null;
        _proofMissing = true;
        _proofError = error.message;
      });
    }
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    final bool hasProof = _proof != null && _proof!.bytes.isNotEmpty;
    setState(() {
      _proofMissing = !hasProof;
      if (!hasProof) {
        _proofError =
            'Upload the payment receipt before submitting (max ${_preview.proofMaxSizeMb} MB).';
      }
    });
    if (!valid || !hasProof) return;
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    final note = _noteCtrl.text.trim();
    // Filed from here rather than popped back to the caller: an upload can take
    // a while, and the vendor needs to watch it on the screen they filled in —
    // popping first left them on the account screen with no idea whether their
    // payment had gone through.
    context.read<AccountBloc>().add(
      RequestSettlementEvent(
        // Locked scope submits the server's own figure, not the rendered text.
        amount: _amountLocked
            ? _defaultAmount
            : double.parse(_amountCtrl.text.trim()),
        transactionReference: _refCtrl.text.trim(),
        note: note.isEmpty ? null : note,
        paymentProof: _proof!,
        venueId: widget.venueId,
      ),
    );
  }

  String get _scopeLabel {
    if (_preview.subtitle.isNotEmpty) return _preview.subtitle;
    if (widget.venueName.isNotEmpty) return widget.venueName;
    return 'All futsals';
  }

  String get _proofHint {
    final types = _preview.acceptedProofTypes
        .map((e) => e.toUpperCase())
        .toSet()
        .join(', ');
    return '$types · Max ${_preview.proofMaxSizeMb} MB';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listenWhen: (AccountState p, AccountState c) =>
          p.submitStatus != c.submitStatus,
      listener: (BuildContext context, AccountState state) {
        // Success only lands once the account has been reconciled, so by the
        // time this pops the screen underneath is already up to date.
        if (state.submitStatus == AccountStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.submitStatus == AccountStatus.failure) {
          // Stay put: the form is still filled in, so the vendor can retry
          // without re-attaching the proof.
          AppUtils().showSnackBar(
            context,
            MsgType.error,
            state.errorMessage ??
                StringConstants.couldNotSubmitSettlementRequest,
          );
        }
      },
      child: BlocBuilder<AccountBloc, AccountState>(
        buildWhen: (AccountState p, AccountState c) =>
            p.submitStatus != c.submitStatus,
        builder: (BuildContext context, AccountState state) {
          // Leaving mid-upload would strand the request with no screen to
          // report back to, and the vendor with no idea whether they paid.
          return PopScope(
            canPop: state.submitStatus != AccountStatus.loading,
            child: _buildScaffold(context),
          );
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(title: StringConstants.payCommission),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              // Forms stay one readable column; fields are never paired.
              constraints: BoxConstraints(
                maxWidth: context.isTabletOrWider
                    ? AppDimens.formContentMaxWidth
                    : double.infinity,
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  context.responsive<double>(
                    mobile: AppDimens.paddingX20,
                    tablet: AppDimens.paddingX32,
                  ),
                  AppDimens.paddingX16,
                  context.responsive<double>(
                    mobile: AppDimens.paddingX20,
                    tablet: AppDimens.paddingX32,
                  ),
                  AppDimens.paddingX32,
                ),
                children: [
                  Text(
                    _scopeLabel,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX12),
                  SettlementRecipientCard(
                    recipient: _preview.recipient,
                    maximumPayable: _payable,
                    pendingClearance: _preview.pendingClearance,
                    totalEarned: widget.totalEarned,
                  ),
                  const SizedBox(height: AppDimens.paddingX20),
                  const _StepHeader(
                    step: 1,
                    title: 'Scan and pay',
                    subtitle:
                        'Send the commission to Hamro Futsal using this QR.',
                  ),
                  const SizedBox(height: AppDimens.paddingX12),
                  SettlementQrCarouselCard(
                    codes: _qrCodes,
                    fallbackQr: _preview.paymentQr,
                    fallbackPayeeName: _preview.recipient.name,
                    payeePhone: _preview.recipient.phone,
                    amountLabel: 'Commission to pay',
                    amountValue: AccountFmt.npr(_payable),
                  ),
                  const SizedBox(height: AppDimens.paddingX20),
                  const _StepHeader(
                    step: 2,
                    title: 'Confirm the payment',
                    subtitle:
                        'Enter what you sent and attach the receipt as proof.',
                  ),
                  const SizedBox(height: AppDimens.paddingX12),
                  CustomTextField(
                    labelText: 'Commission amount (NPR)',
                    controller: _amountCtrl,
                    readOnly: _amountLocked,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      // Paisa matter: the server rejects a rounded amount.
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    icon: Icons.payments_outlined,
                    validator: _validateAmount,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    ensureVisibleOnFocus: true,
                  ),
                  if (_amountLocked) ...[
                    const SizedBox(height: AppDimens.paddingX6),
                    Text(
                      'The full commission must be paid in one request.',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimens.paddingX16),
                  CustomTextField(
                    labelText: 'Transaction reference',
                    hintText: 'Bank / eSewa / Khalti transaction ID',
                    controller: _refCtrl,
                    icon: Icons.tag_rounded,
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Enter the payment transaction reference.'
                        : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    ensureVisibleOnFocus: true,
                  ),
                  const SizedBox(height: AppDimens.paddingX16),
                  _ProofPicker(
                    proof: _proof,
                    uploadBytes: _proof?.size,
                    showError: _proofMissing,
                    hint: _proofHint,
                    errorText: _proofError,
                    onTap: _pickProof,
                  ),
                  const SizedBox(height: AppDimens.paddingX16),
                  CustomTextField(
                    labelText: 'Note (optional)',
                    hintText: 'Payment remark',
                    controller: _noteCtrl,
                    maxLines: 2,
                    isRequired: false,
                    textCapitalization: TextCapitalization.sentences,
                    ensureVisibleOnFocus: true,
                  ),
                  const SizedBox(height: AppDimens.paddingX24),
                  BlocBuilder<AccountBloc, AccountState>(
                    buildWhen: (AccountState p, AccountState c) =>
                        p.submitStatus != c.submitStatus,
                    builder: (BuildContext context, AccountState state) {
                      final bool submitting =
                          state.submitStatus == AccountStatus.loading;
                      // The button carries the whole wait: the upload, and the
                      // account refresh that follows it.
                      final Widget button = CustomButton(
                        text: submitting
                            ? 'Submitting…'
                            : 'Submit Commission Payment',
                        icon: Icons.lock_outline_rounded,
                        isLoading: submitting,
                        onPressed: submitting ? () {} : _submit,
                      );
                      if (!context.isTabletOrWider) return button;
                      return Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: AppDimens.formActionMaxWidth,
                          child: button,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Numbered step label that splits the form into "pay" and "confirm". The two
/// halves ask for very different things, and the QR is useless once the vendor
/// has already paid — the numbering makes the order explicit.
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  final int step;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppDimens.sizeX24,
          height: AppDimens.sizeX24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: textTheme.bodyMiniSubTitle?.copyWith(
              color: LightColor.onBrandSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.paddingX10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Receipt/screenshot upload tile with inline validation message.
String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class _ProofPicker extends StatelessWidget {
  const _ProofPicker({
    required this.proof,
    this.uploadBytes,
    required this.showError,
    required this.hint,
    required this.errorText,
    required this.onTap,
  });

  final UploadAttachment? proof;

  /// Byte count of what will be sent, once compression has run.
  final int? uploadBytes;
  final bool showError;

  /// Accepted types and size ceiling, as the server reported them.
  final String hint;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color borderColor = showError
        ? LightColor.redColor
        : proof == null
        ? LightColor.dividerColor
        : LightColor.brandTextColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            decoration: BoxDecoration(
              color: LightColor.cardColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  proof == null
                      ? Icons.cloud_upload_outlined
                      : Icons.check_circle_rounded,
                  size: AppDimens.sizeX22,
                  color: LightColor.brandTextColor,
                ),
                const SizedBox(width: AppDimens.paddingX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proof?.name ?? 'Upload payment proof',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        // The size that will actually be uploaded, after
                        // compression — the number that decides whether the
                        // server accepts it.
                        uploadBytes == null
                            ? hint
                            : '${_formatSize(uploadBytes!)} · $hint',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: LightColor.iconGrey,
                  size: AppDimens.sizeX20,
                ),
              ],
            ),
          ),
        ),
        if (showError) ...[
          const SizedBox(height: AppDimens.paddingX6),
          Text(
            errorText ?? 'Upload the payment receipt before submitting.',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.redColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
