import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/presentation/utils/account_ui_utils.dart';
import 'package:hamro_footsall/features/account/presentation/widgets/account_widgets.dart';

typedef SettlementRequestDraft = ({
  double amount,
  String transactionReference,
  String? note,
  String paymentProofPath,
});

/// Full-page settlement request form, driven entirely by
/// `/auth/settlement-preview`: the server supplies the copy, who to pay, the
/// ceiling, whether a partial amount is allowed, and what a proof file may be.
///
/// Pops with a [SettlementRequestDraft] on submit, null when dismissed.
class RequestSettlementPage extends StatefulWidget {
  const RequestSettlementPage({
    super.key,
    required this.preview,
    this.venueName = '',
  });

  final SettlementPreviewModel preview;

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
  PlatformFile? _proof;
  bool _proofMissing = false;
  String? _proofError;

  SettlementPreviewModel get _preview => widget.preview;

  /// The whole payable balance must go in one request — the field is shown
  /// read-only rather than validated, so the rule is visible up front.
  bool get _amountLocked => _preview.exactAmountRequired;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: AccountFmt.amountInput(_preview.defaultAmount),
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
    if (amount > _preview.maximumPayable) {
      return "Amount can't exceed ${AccountFmt.npr(_preview.maximumPayable)}.";
    }
    // Compared in paisa: 11711.99 never equals itself in binary floating point.
    if (_amountLocked &&
        (amount * 100).round() != (_preview.defaultAmount * 100).round()) {
      return 'Settle the full ${AccountFmt.npr(_preview.defaultAmount)}.';
    }
    return null;
  }

  Future<void> _pickProof() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _preview.acceptedProofTypes,
      allowMultiple: false,
    );
    final file = result?.files.singleOrNull;
    if (!mounted || file?.path == null) return;
    if (file!.size > _preview.proofMaxBytes) {
      setState(() {
        _proof = null;
        _proofMissing = true;
        _proofError =
            'That file is larger than ${_preview.proofMaxSizeMb} MB. Pick a smaller one.';
      });
      return;
    }
    setState(() {
      _proof = file;
      _proofMissing = false;
      _proofError = null;
    });
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    final hasProof = _proof?.path != null;
    setState(() {
      _proofMissing = !hasProof;
      if (!hasProof) {
        _proofError =
            'Upload the payment receipt before submitting (max ${_preview.proofMaxSizeMb} MB).';
      }
    });
    if (!valid || !hasProof) return;
    HapticFeedback.mediumImpact();
    final note = _noteCtrl.text.trim();
    Navigator.of(context).pop((
      // Locked scope submits the server's own figure, not the rendered text.
      amount: _amountLocked
          ? _preview.defaultAmount
          : double.parse(_amountCtrl.text.trim()),
      transactionReference: _refCtrl.text.trim(),
      note: note.isEmpty ? null : note,
      paymentProofPath: _proof!.path!,
    ));
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
    final textTheme = FutsalTheme.getTextTheme(context);
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: _preview.title.isEmpty
            ? StringConstants.payCommission
            : _preview.title,
      ),
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
                    maximumPayable: _preview.maximumPayable,
                    pendingClearance: _preview.pendingClearance,
                  ),
                  const SizedBox(height: AppDimens.paddingX20),
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
                  if (context.isTabletOrWider)
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: AppDimens.formActionMaxWidth,
                        child: CustomButton(
                          text: 'Submit Commission Payment',
                          icon: Icons.lock_outline_rounded,
                          onPressed: _submit,
                        ),
                      ),
                    )
                  else
                    CustomButton(
                      text: 'Submit Commission Payment',
                      icon: Icons.lock_outline_rounded,
                      onPressed: _submit,
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

/// Receipt/screenshot upload tile with inline validation message.
class _ProofPicker extends StatelessWidget {
  const _ProofPicker({
    required this.proof,
    required this.showError,
    required this.hint,
    required this.errorText,
    required this.onTap,
  });

  final PlatformFile? proof;
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
        : LightColor.secondaryColor;
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
                  color: LightColor.secondaryColor,
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
                        hint,
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
