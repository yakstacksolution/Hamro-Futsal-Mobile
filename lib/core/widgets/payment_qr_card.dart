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
///
/// A court with several QRs (eSewa, a bank, ...) shows them as a swipeable
/// carousel with a page indicator; zoom and save act on the QR in view.
class PaymentQrCard extends StatefulWidget {
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

  @override
  State<PaymentQrCard> createState() => _PaymentQrCardState();
}

class _PaymentQrCardState extends State<PaymentQrCard> {
  final PageController _pageController = PageController();
  int _page = 0;

  List<PaymentQrImage> get _images =>
      widget.qr?.images ?? const <PaymentQrImage>[];

  /// The QR in view, or null when there is none to show.
  PaymentQrImage? get _current {
    final List<PaymentQrImage> images = _images;
    if (images.isEmpty) return null;
    return images[_page.clamp(0, images.length - 1)];
  }

  @override
  void didUpdateWidget(covariant PaymentQrCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A refetch can return fewer QRs than before; keep the index in range so
    // the header and save action never point past the list.
    final int count = _images.length;
    if (_page >= count && count > 0) {
      _page = count - 1;
      if (_pageController.hasClients) _pageController.jumpToPage(_page);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _payeeName {
    final String? name = widget.qr?.payeeName;
    return (name != null && name.isNotEmpty) ? name : widget.fallbackPayeeName;
  }

  /// [image], filling whatever square box the caller gives it.
  Widget _qrImage(PaymentQrImage? image) {
    if (image != null && image.bytes != null) {
      return Image.memory(
        image.bytes!,
        fit: BoxFit.contain,
        // A QR is hard pixels, not a photo: smoothing the upscale is what
        // makes a large one look soft and read badly.
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _qrPlaceholder(),
      );
    }
    if (image != null && image.url != null) {
      return CustomImageView(
        url: image.url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }
    return _qrPlaceholder();
  }

  Widget _qrPlaceholder() {
    if (widget.isLoading) {
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

  /// Save action for [image], or nothing when there is no QR to save.
  ///
  /// The QR is what the player scans in their banking app, and that app is not
  /// this one — so keeping the image is the whole point, exactly as it is for a
  /// payment proof on the booking-details card.
  Widget? _downloadAction(PaymentQrImage? image, {Color? color}) {
    if (image == null || !image.hasImage) return null;
    return AttachmentDownloadAction(
      // Keyed per QR so the action's saving state does not carry over when
      // the user swipes to another one mid-download.
      key: ValueKey<String>('payment-qr-download-${image.id ?? image.url}'),
      bytes: image.bytes,
      url: image.url,
      fileName: _fileName(image),
      color: color,
      tooltip: StringConstants.saveQrCode,
    );
  }

  /// A payee-stamped name, so QRs for two venues — or two QRs of one venue —
  /// do not collide in the user's files.
  String _fileName(PaymentQrImage image) {
    final String payee = _payeeName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final String base = payee.isEmpty ? 'payment-qr' : 'payment-qr-$payee';
    return _images.length > 1 ? '$base-${_images.indexOf(image) + 1}' : base;
  }

  void _zoom(BuildContext context, PaymentQrImage image) {
    final Widget? saveAction = _downloadAction(
      image,
      color: LightColor.onQrSurface,
    );
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
              AspectRatio(aspectRatio: 1, child: _qrImage(image)),
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

  /// The QR box: a single image, or a swipeable pager when there are several.
  Widget _qrViewport(BuildContext context) {
    final List<PaymentQrImage> images = _images;
    if (images.length <= 1) {
      final PaymentQrImage? image = images.isEmpty ? null : images.first;
      return GestureDetector(
        onTap: image != null ? () => _zoom(context, image) : null,
        child: _qrImage(image),
      );
    }
    return PageView.builder(
      controller: _pageController,
      itemCount: images.length,
      onPageChanged: (int page) => setState(() => _page = page),
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () => _zoom(context, images[index]),
        child: _qrImage(images[index]),
      ),
    );
  }

  /// "1 of 2" with dots under a multi-QR carousel; tapping a dot jumps to it.
  Widget _pageIndicator(BuildContext context) {
    final int count = _images.length;
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(top: AppDimens.paddingX10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(count, (int index) {
              final bool active = index == _page;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
                child: Padding(
                  padding: AppUtils().getPadding(
                    symmetricHorizontal: AppDimens.paddingX4,
                    symmetricVertical: AppDimens.paddingX4,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? AppDimens.sizeX16 : AppDimens.sizeX6,
                    height: AppDimens.sizeX6,
                    decoration: BoxDecoration(
                      color: active
                          ? LightColor.secondaryColor
                          : LightColor.dividerColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimens.sizeX4),
          Text(
            '${_page + 1} of $count · ${StringConstants.swipeForMoreQrs}',
            style: textTheme.bodyMiniSubTitle?.copyWith(
              color: LightColor.hintTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String? note = widget.qr?.note;
    final Widget? downloadAction = _downloadAction(_current);
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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            child: ColoredBox(
              color: LightColor.qrSurface,
              child: AspectRatio(aspectRatio: 1, child: _qrViewport(context)),
            ),
          ),
          if (_images.length > 1) _pageIndicator(context),
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
          if (widget.amountLabel != null &&
              widget.amountValue != null) ...<Widget>[
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
                  widget.amountLabel!,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: Text(
                    widget.amountValue!,
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
