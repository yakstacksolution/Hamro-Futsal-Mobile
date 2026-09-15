import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/attachment_viewer.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/payment_qr_model.dart';

/// Manual-payment QR card — the QR image (tap to zoom), payee details, note,
/// and an emphasized amount row. Shared by booking checkout and the
/// opponent-request accept flow.
class PaymentQrCard extends StatelessWidget {
  const PaymentQrCard({
    super.key,
    required this.qr,
    this.isLoading = false,
    this.fallbackPayeeName = '',
    this.amountLabel,
    this.amountValue,
  });

  final PaymentQrModel? qr;

  /// True while the QR is still being fetched — shows a spinner placeholder.
  final bool isLoading;
  final String fallbackPayeeName;

  /// Amount row under the divider, e.g. "Advance to pay" / "Rs 300".
  final String? amountLabel;
  final String? amountValue;

  String get _payeeName {
    final String? name = qr?.payeeName;
    return (name != null && name.isNotEmpty) ? name : fallbackPayeeName;
  }

  /// The QR, filling whatever square box the caller gives it.
  Widget _qrImage() {
    final PaymentQrModel? model = qr;
    if (model != null && model.qrImageBytes != null) {
      return Image.memory(
        model.qrImageBytes!,
        fit: BoxFit.contain,
        // A QR is hard pixels, not a photo: smoothing the upscale is what
        // makes a large one look soft and read badly.
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _qrPlaceholder(),
      );
    }
    if (model != null && model.qrImageUrl != null) {
      return CustomImageView(
        url: model.qrImageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }
    return _qrPlaceholder();
  }

  Widget _qrPlaceholder() {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: AppDimens.sizeX24,
          height: AppDimens.sizeX24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: LightColor.secondaryColor,
          ),
        ),
      );
    }
    // No QR from the server: keep the section usable with a neutral placeholder.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.qr_code_2_rounded,
          size: AppDimens.sizeX48,
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
    );
  }

  /// Save action for the QR, or nothing when there is no QR to save.
  ///
  /// The QR is what the player scans in their banking app, and that app is not
  /// this one — so keeping the image is the whole point, exactly as it is for a
  /// payment proof on the booking-details card.
  Widget? _downloadAction({Color? color}) {
    final PaymentQrModel? model = qr;
    if (model == null || !model.hasQr) return null;
    return AttachmentDownloadAction(
      key: const Key('payment-qr-download'),
      bytes: model.qrImageBytes,
      url: model.qrImageUrl,
      fileName: _fileName,
      color: color,
      tooltip: StringConstants.saveQrCode,
    );
  }

  /// A payee-stamped name, so QRs for two venues do not collide in the user's
  /// files. The URL's own name wins when the server gave one with an
  /// extension — [DownloadHelper] falls back to it on its own.
  String get _fileName {
    final String payee = _payeeName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return payee.isEmpty ? 'payment-qr' : 'payment-qr-$payee';
  }

  void _zoom(BuildContext context) {
    if (!(qr?.hasQr ?? false)) return;
    final Widget? saveAction = _downloadAction(color: LightColor.onQrSurface);
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
              AspectRatio(aspectRatio: 1, child: _qrImage()),
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
              if (saveAction != null) saveAction,
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
    final Widget? downloadAction = _downloadAction();
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
          // Payee and save action sit on the card's own surface, so they take
          // the theme's text colours. Only the code itself gets the light
          // field — scanners need it, and a QR with a transparent background
          // would vanish against the dark surface token — and putting the
          // header inside that field is what left dark text on white in dark
          // mode.
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _payeeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (downloadAction != null) downloadAction,
            ],
          ),
          const SizedBox(height: AppDimens.sizeX8),
          GestureDetector(
            onTap: hasQr ? () => _zoom(context) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              child: ColoredBox(
                color: LightColor.qrSurface,
                child: AspectRatio(aspectRatio: 1, child: _qrImage()),
              ),
            ),
          ),
          if (note != null) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX8),
            Text(
              note,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                symmetricVertical: AppDimens.paddingX10,
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
