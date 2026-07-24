import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/payment_qr_card.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/presentation/utils/account_ui_utils.dart';

typedef SettlementRequestDraft = ({
  int amount,
  String transactionReference,
  String? note,
  String paymentProofPath,
});

/// Full-page settlement request form: pay Hamro Futsal by QR, then submit
/// the paid amount with the receipt. Pops with a [SettlementRequestDraft]
/// on submit, null when dismissed.
class RequestSettlementPage extends StatefulWidget {
  const RequestSettlementPage({
    super.key,
    required this.summary,
    required this.availableBalance,
    required this.scopeLabel,
    this.minSettlementAmount,
  });

  final AccountSummaryModel summary;
  final int availableBalance;
  final String scopeLabel;

  /// Scope-specific floor from the settlement preview; falls back to the
  /// account-wide minimum when the preview didn't supply one.
  final int? minSettlementAmount;

  @override
  State<RequestSettlementPage> createState() => _RequestSettlementPageState();
}

class _RequestSettlementPageState extends State<RequestSettlementPage> {
  static const List<String> _proofExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
  static const int _maxProofBytes = 10 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.availableBalance.toString(),
  );
  final _refCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  PlatformFile? _proof;
  bool _proofMissing = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final amount = int.tryParse(value?.trim() ?? '') ?? 0;
    if (amount <= 0) return 'Enter a valid amount.';
    if (amount > widget.availableBalance) {
      return 'Amount can\'t exceed ${AccountFmt.npr(widget.availableBalance)}.';
    }
    final min =
        widget.minSettlementAmount ?? widget.summary.minSettlementAmount;
    if (min > 0 && amount < min) {
      return 'Minimum settlement is ${AccountFmt.npr(min)}.';
    }
    return null;
  }

  Future<void> _pickProof() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _proofExtensions,
      allowMultiple: false,
    );
    final file = result?.files.singleOrNull;
    if (!mounted || file?.path == null) return;
    if (file!.size > _maxProofBytes) {
      setState(() => _proofMissing = true);
      return;
    }
    setState(() {
      _proof = file;
      _proofMissing = false;
    });
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    final hasProof = _proof?.path != null;
    setState(() => _proofMissing = !hasProof);
    if (!valid || !hasProof) return;
    HapticFeedback.mediumImpact();
    final note = _noteCtrl.text.trim();
    Navigator.of(context).pop((
      amount: int.parse(_amountCtrl.text.trim()),
      transactionReference: _refCtrl.text.trim(),
      note: note.isEmpty ? null : note,
      paymentProofPath: _proof!.path!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.requestSettlement),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingX20,
              AppDimens.paddingX16,
              AppDimens.paddingX20,
              AppDimens.paddingX32,
            ),
            children: [
              Text(
                widget.scopeLabel,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX12),
              PaymentQrCard(
                qr: widget.summary.settlementQr,
                fallbackPayeeName: StringConstants.hamroFutsal,
                amountLabel: 'Maximum payable',
                amountValue: AccountFmt.npr(widget.availableBalance),
              ),
              const SizedBox(height: AppDimens.paddingX20),
              CustomTextField(
                labelText: 'Settlement amount (NPR)',
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                icon: Icons.payments_outlined,
                validator: _validateAmount,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                ensureVisibleOnFocus: true,
              ),
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
              CustomButton(
                text: 'Submit Settlement Request',
                icon: Icons.lock_outline_rounded,
                onPressed: _submit,
              ),
            ],
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
    required this.onTap,
  });

  final PlatformFile? proof;
  final bool showError;
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
                        'JPG, PNG or PDF · Max 10 MB',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
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
            'Upload the payment receipt before submitting (max 10 MB).',
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
