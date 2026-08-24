import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/payment_qr_model.dart';

/// Manual-payment QR card — the QR image (tap to zoom), payee details, note,
/// and an emphasized amount row. Shared by booking checkout and the
/// opponent-request accept flow.
class PaymentQrCard extends StatelessWidget {
  const PaymentQrCard({
    super.key,
    required this.qr,
    this.isLoading = false,
    this.fallbackPayeeName = '',
    this.fallbackPayeeId = '',
    this.amountLabel,
    this.amountValue,
  });

  final PaymentQrModel? qr;

  /// True while the QR is still being fetched — shows a spinner placeholder.
  final bool isLoading;
  final String fallbackPayeeName;
  final String fallbackPayeeId;

  /// Amount row under the divider, e.g. "Advance to pay" / "Rs 300".
  final String? amountLabel;
  final String? amountValue;

  String get _payeeName {
    final String? name = qr?.payeeName;
    return (name != null && name.isNotEmpty) ? name : fallbackPayeeName;
  }

  String get _payeeId {
    final String? id = qr?.accountId;
    return (id != null && id.isNotEmpty) ? id : fallbackPayeeId;
  }

  Widget _qrImage(double size) {
    final PaymentQrModel? model = qr;
    if (model != null && model.qrImageBytes != null) {
      return Image.memory(
        model.qrImageBytes!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _qrPlaceholder(size),
      );
    }
    if (model != null && model.qrImageUrl != null) {
      return CustomImageView(
        url: model.qrImageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return _qrPlaceholder(size);
  }

  Widget _qrPlaceholder(double size) {
    if (isLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: SizedBox(
            width: AppDimens.sizeX24,
            height: AppDimens.sizeX24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: LightColor.secondaryColor,
            ),
          ),
        ),
      );
    }
    // No QR from the server: keep the section usable with a neutral placeholder.
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.qr_code_2_rounded,
            size: size * 0.4,
            color: LightColor.onQrSurfaceMuted,
          ),
          const SizedBox(height: AppDimens.sizeX6),
          Text(
            StringConstants.qrUnavailable,
            style: TextStyle(
              color: LightColor.onQrSurfaceMuted,
              fontSize: AppDimens.sizeX12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _zoom(BuildContext context) {
    if (!(qr?.hasQr ?? false)) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: LightColor.qrSurface,
        insetPadding: AppUtils().getPadding(all: AppDimens.paddingX24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        ),
        child: Padding(
          padding: AppUtils().getPadding(all: AppDimens.paddingX24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _qrImage(AppDimens.sizeX250),
              const SizedBox(height: AppDimens.sizeX16),
              Text(
                _payeeName,
                textAlign: TextAlign.center,
                style: FutsalTheme.getTextTheme(context).bodyTextMedium
                    ?.copyWith(
                      color: LightColor.onQrSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool hasQr = qr?.hasQr ?? false;
    final String? note = qr?.note;
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: hasQr ? () => _zoom(context) : null,
            child: Container(
              padding: AppUtils().getPadding(all: AppDimens.paddingX12),
              decoration: BoxDecoration(
                // Always light, in both themes: scanners need the quiet zone,
                // and a QR with a transparent background disappears entirely
                // against the dark surface token.
                color: LightColor.qrSurface,
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                border: Border.all(
                  color: LightColor.dividerColor.withValues(alpha: 0.9),
                ),
              ),
              child: _qrImage(AppDimens.sizeX150),
            ),
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Text(
            _payeeName,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_payeeId.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX2),
            Text(
              _payeeId,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (note != null) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX6),
            Text(
              note,
              textAlign: TextAlign.center,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.hintTextColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
          if (amountLabel != null && amountValue != null) ...<Widget>[
            Padding(
              padding: AppUtils().getPadding(
                symmetricVertical: AppDimens.paddingX12,
              ),
              child: Divider(
                height: 1,
                color: LightColor.dividerColor.withValues(alpha: 0.8),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  amountLabel!,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: Text(
                    amountValue!,
                    textAlign: TextAlign.right,
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.brandTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
