import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/media/presentation/widgets/media_library_sheet.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_delete_dialog.dart';

class CourtBookingPaymentSection extends StatelessWidget {
  const CourtBookingPaymentSection({
    super.key,
    required this.cubit,
    required this.court,
    required this.subsectionIndex,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;
  final int subsectionIndex;

  /// Adds QRs from the library to the ones the court already has.
  ///
  /// It adds rather than replaces: a saved court's QRs live in court storage
  /// (`payment_qr_media_list`, ids of their own), not in the library, so they
  /// never show as selected there — replacing with the library selection
  /// would silently drop them. A QR is removed from its own tile instead.
  Future<void> _openPaymentQrLibrary(BuildContext context) async {
    final int remaining = kMaxCourtPaymentQrs - court.paymentQrs.length;
    if (remaining <= 0) return;
    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: cubit,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: true,
      title: 'Add payment QRs',
      subtitle: remaining == 1
          ? 'You can add 1 more QR.'
          : 'You can add up to $remaining more QRs.',
    );
    if (picked == null || picked.isEmpty || !context.mounted) return;

    final Set<String> existing = court.paymentQrs
        .map((UploadRef qr) => qr.storageKey)
        .toSet();
    final List<UploadRef> fresh = picked
        .where((UploadRef qr) => !existing.contains(qr.storageKey))
        .toList(growable: false);
    if (fresh.length > remaining) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'A court can have $kMaxCourtPaymentQrs QRs. Only the first '
        '$remaining ${remaining == 1 ? 'was' : 'were'} added.',
      );
    }
    cubit.setCourtPaymentQrs(<UploadRef>[...court.paymentQrs, ...fresh]);
  }

  @override
  Widget build(BuildContext context) {
    final _CourtPaymentSectionMeta meta = _sectionMeta(subsectionIndex);
    return VendorPanel(
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VendorOnboardingSectionHeader(
            title: meta.title,
            subtitle: meta.subtitle,
            icon: meta.icon,
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (subsectionIndex == 0)
            _AdvancePaymentSection(
              court: court,
              onTypeChanged: cubit.setCourtAdvancePaymentType,
              onPriceChanged: (String raw) =>
                  cubit.setCourtAdvancePrice(parseDouble(raw)),
            ),
          if (subsectionIndex == 1)
            _PaymentQrGallery(
              qrs: court.paymentQrs,
              onAdd: () => unawaited(_openPaymentQrLibrary(context)),
              onRemove: cubit.removeCourtPaymentQr,
            ),
        ],
      ),
    );
  }

  _CourtPaymentSectionMeta _sectionMeta(int index) {
    return switch (index) {
      0 => const _CourtPaymentSectionMeta(
        title: StringConstants.advancePayment,
        subtitle: StringConstants.requirementAndCollectionAmount,
        icon: Icons.payments_rounded,
      ),
      1 => const _CourtPaymentSectionMeta(
        title: StringConstants.paymentQr,
        subtitle: StringConstants.uploadTheQrUsedToCollectAdvancePayments,
        icon: Icons.qr_code_2_rounded,
      ),
      _ => const _CourtPaymentSectionMeta(
        title: StringConstants.bookingAndPaymentTitle,
        subtitle: StringConstants.manageBookingAndPaymentSettings,
        icon: Icons.account_balance_wallet_rounded,
      ),
    };
  }
}

class _CourtPaymentSectionMeta {
  const _CourtPaymentSectionMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _AdvancePaymentSection extends StatefulWidget {
  const _AdvancePaymentSection({
    required this.court,
    required this.onTypeChanged,
    required this.onPriceChanged,
  });

  final CourtDraft court;
  final ValueChanged<AdvancePaymentType> onTypeChanged;
  final ValueChanged<String> onPriceChanged;

  @override
  State<_AdvancePaymentSection> createState() => _AdvancePaymentSectionState();
}

class _AdvancePaymentSectionState extends State<_AdvancePaymentSection> {
  // Assigned in initState, never as a lazy field initialiser: a lazy
  // `late final` runs on first *read*, so a state that is torn down before the
  // input subtree builds would construct the controller inside dispose() —
  // throwing while the framework finalises the widget tree.
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: formatDouble(widget.court.advancePrice),
    );
  }

  @override
  void didUpdateWidget(covariant _AdvancePaymentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String desired = formatDouble(widget.court.advancePrice);
    // Only sync the field from state when the value didn't come from the
    // user typing into it — i.e. defaults or auto-fill from base price.
    if (!widget.court.advancePriceUserEdited &&
        desired != _priceController.text) {
      _priceController.value = TextEditingValue(
        text: desired,
        selection: TextSelection.collapsed(offset: desired.length),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  String get _minimumPercentLabel => kMinimumAdvancePercent.toStringAsFixed(0);

  /// The lowest flat amount allowed for this court: the minimum share of the
  /// base price. Null while no base price has been entered.
  double? get _minimumFlatAmount {
    final double? base = widget.court.basePrice;
    if (base == null || base <= 0) return null;
    return base * kMinimumAdvancePercent / 100;
  }

  String? _priceError() {
    final CourtDraft court = widget.court;
    final AdvancePaymentType? type = court.advancePaymentType;
    final double? price = court.advancePrice;
    if (type == null) return null;
    if (price == null) return 'Enter the advance amount.';
    if (price <= 0) return 'Amount must be greater than zero.';
    if (type == AdvancePaymentType.percentage) {
      if (price < kMinimumAdvancePercent) {
        return 'The advance must be at least $_minimumPercentLabel%.';
      }
      if (price > 100) return 'Percentage cannot exceed 100.';
    }
    if (type == AdvancePaymentType.flat) {
      final double? base = court.basePrice;
      if (base != null && price > base) {
        return 'Flat amount cannot exceed the base price (${formatDouble(base)}).';
      }
      final double? minimum = _minimumFlatAmount;
      if (minimum != null && price < minimum) {
        return 'The advance must be at least $_minimumPercentLabel% of the '
            'base price (${formatDouble(minimum)}).';
      }
    }
    return null;
  }

  String _priceHint(AdvancePaymentType? type) {
    switch (type) {
      case AdvancePaymentType.percentage:
        return 'Minimum $_minimumPercentLabel%, up to 100%';
      case AdvancePaymentType.flat:
        final double? minimum = _minimumFlatAmount;
        final double? base = widget.court.basePrice;
        if (minimum == null || base == null) {
          return 'Enter the flat advance amount';
        }
        return 'From ${formatDouble(minimum)} to ${formatDouble(base)}';
      case null:
        return 'Enter the advance amount';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final CourtDraft court = widget.court;
    final AdvancePaymentType? type = court.advancePaymentType;
    final String? error = _priceError();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Advance payment is a platform rule, not a per-court choice: the row
        // states the requirement instead of offering a switch.
        Container(
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: LightColor.secondaryColor.withValues(alpha: 0.35),
              width: 0.7,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.lock_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.brandTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      StringConstants.advancePaymentRequired,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      'Every court collects an advance of at least '
                      '$_minimumPercentLabel% before a booking is confirmed.',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.sizeX16),
        Text(
          StringConstants.advancePaymentType,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX8),
        _AdvanceTypeSelector(selected: type, onSelected: widget.onTypeChanged),
        const SizedBox(height: AppDimens.sizeX16),
        VendorInputField(
          controller: _priceController,
          initialValue: '',
          label: type == AdvancePaymentType.percentage
              ? 'Advance percentage (%)'
              : 'Advance amount',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          hintText: _priceHint(type),
          onChanged: widget.onPriceChanged,
        ),
        if (error != null) ...<Widget>[
          const SizedBox(height: AppDimens.sizeX6),
          Text(
            error,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.redColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _AdvanceTypeSelector extends StatelessWidget {
  const _AdvanceTypeSelector({
    required this.selected,
    required this.onSelected,
  });

  final AdvancePaymentType? selected;
  final ValueChanged<AdvancePaymentType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.sizeX4),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _AdvanceTypeOption(
              label: StringConstants.flat,
              icon: Icons.attach_money_rounded,
              isSelected: selected == AdvancePaymentType.flat,
              onTap: () => onSelected(AdvancePaymentType.flat),
            ),
          ),
          const SizedBox(width: AppDimens.sizeX4),
          Expanded(
            child: _AdvanceTypeOption(
              label: StringConstants.percentage,
              icon: Icons.percent_rounded,
              isSelected: selected == AdvancePaymentType.percentage,
              onTap: () => onSelected(AdvancePaymentType.percentage),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvanceTypeOption extends StatelessWidget {
  const _AdvanceTypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: AppUtils().getPadding(
          vertical: AppDimens.sizeX10,
          horizontal: AppDimens.sizeX12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? LightColor.secondaryColor
              : LightColor.transparentColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: AppDimens.sizeX16,
              color: isSelected
                  ? LightColor.inverseTextColor
                  : LightColor.secondaryTextColor,
            ),
            const SizedBox(width: AppDimens.sizeX6),
            Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: isSelected
                    ? LightColor.inverseTextColor
                    : LightColor.primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Every payment QR the court accepts, as square tiles (a QR must never be
/// cropped), with an "Add QR" tile until the limit. Tapping a tile opens a
/// full-screen viewer that swipes between all of them.
class _PaymentQrGallery extends StatelessWidget {
  const _PaymentQrGallery({
    required this.qrs,
    required this.onAdd,
    required this.onRemove,
  });

  final List<UploadRef> qrs;
  final VoidCallback onAdd;
  final ValueChanged<UploadRef> onRemove;

  Future<void> _confirmRemove(BuildContext context, UploadRef qr) async {
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: 'Remove QR',
      message: 'Remove this payment QR from the court?',
      confirmText: StringConstants.delete,
      cancelText: StringConstants.cancel,
      icon: Icons.delete_outline_rounded,
      confirmColor: LightColor.redColor,
    );
    if (confirmed) onRemove(qr);
  }

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _PaymentQrViewer(qrs: qrs, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool canAdd = qrs.length < kMaxCourtPaymentQrs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Add a QR for each wallet or bank you accept. Players can '
                'pay through any of them.',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Text(
              '${qrs.length}/$kMaxCourtPaymentQrs',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.brandTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sizeX12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int columns = constraints.maxWidth >= 520 ? 4 : 3;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              mainAxisSpacing: AppDimens.sizeX10,
              crossAxisSpacing: AppDimens.sizeX10,
              children: <Widget>[
                for (int i = 0; i < qrs.length; i++)
                  _PaymentQrTile(
                    key: ValueKey<String>(qrs[i].storageKey),
                    qr: qrs[i],
                    label: 'QR ${i + 1}',
                    onTap: () => _openViewer(context, i),
                    onRemove: () => unawaited(_confirmRemove(context, qrs[i])),
                  ),
                if (canAdd)
                  _AddPaymentQrTile(isFirst: qrs.isEmpty, onTap: onAdd),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PaymentQrTile extends StatelessWidget {
  const _PaymentQrTile({
    super.key,
    required this.qr,
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  final UploadRef qr;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusX12);
    return Semantics(
      button: true,
      label: '$label, tap to view',
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Material(
            // QRs are printed dark-on-white; a white card keeps them scannable
            // in dark mode too.
            color: LightColor.qrSurface,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: LightColor.greyBorderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingX6),
                child: Hero(
                  tag: 'payment-qr-${qr.storageKey}',
                  child: VendorUploadImageView(file: qr, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            left: AppDimens.sizeX6,
            bottom: AppDimens.sizeX6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX6,
                  vertical: AppDimens.paddingX2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: AppDimens.sizeX4,
            right: AppDimens.sizeX4,
            child: Material(
              color: LightColor.redColor,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(AppDimens.paddingX4),
                  child: Icon(
                    Icons.close_rounded,
                    size: AppDimens.sizeX14,
                    color: Colors.white,
                    semanticLabel: 'Remove QR',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPaymentQrTile extends StatelessWidget {
  const _AddPaymentQrTile({required this.isFirst, required this.onTap});

  final bool isFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.secondaryColor.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        side: BorderSide(
          color: LightColor.secondaryColor.withValues(alpha: 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              isFirst ? Icons.qr_code_2_rounded : Icons.add_rounded,
              color: LightColor.brandTextColor,
              size: AppDimens.sizeX28,
            ),
            const SizedBox(height: AppDimens.sizeX4),
            Text(
              isFirst ? 'Upload QR' : 'Add QR',
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.brandTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen QR preview: swipe between QRs, pinch to zoom.
class _PaymentQrViewer extends StatefulWidget {
  const _PaymentQrViewer({required this.qrs, required this.initialIndex});

  final List<UploadRef> qrs;
  final int initialIndex;

  @override
  State<_PaymentQrViewer> createState() => _PaymentQrViewerState();
}

class _PaymentQrViewerState extends State<_PaymentQrViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.qrs.length > 1
              ? '${StringConstants.paymentQr} ${_index + 1} of ${widget.qrs.length}'
              : StringConstants.paymentQr,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.qrs.length,
          onPageChanged: (int index) => setState(() => _index = index),
          itemBuilder: (BuildContext context, int index) {
            final UploadRef qr = widget.qrs[index];
            return InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingX24),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: LightColor.qrSurface,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusX16,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.paddingX16),
                        child: Hero(
                          tag: 'payment-qr-${qr.storageKey}',
                          child: VendorUploadImageView(
                            file: qr,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
