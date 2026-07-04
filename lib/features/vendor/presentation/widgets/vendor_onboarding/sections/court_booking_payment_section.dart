import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/media/presentation/widgets/media_library_sheet.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

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

  Future<void> _openPaymentQrLibrary(BuildContext context) async {
    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: cubit,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: false,
      initiallySelected: court.paymentQr == null
          ? const <UploadRef>[]
          : <UploadRef>[court.paymentQr!],
    );
    if (picked == null || picked.isEmpty) return;
    cubit.setCourtPaymentQr(picked.first);
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
            _AdvancePaymentToggleSection(
              court: court,
              onChanged: cubit.toggleCourtAdvancePayment,
              onTypeChanged: cubit.setCourtAdvancePaymentType,
              onPriceChanged: (String raw) =>
                  cubit.setCourtAdvancePrice(parseDouble(raw)),
            ),
          if (subsectionIndex == 1)
            VendorUploadSection(
              title: StringConstants.paymentQr,
              subtitle: StringConstants.uploadTheQrUsedToCollectAdvancePayment,
              onPick: () => unawaited(_openPaymentQrLibrary(context)),
              actionLabel: 'Gallery',
              actionIcon: Icons.qr_code_2_rounded,
              files: court.paymentQr == null
                  ? const <UploadRef>[]
                  : <UploadRef>[court.paymentQr!],
              onRemove: court.paymentQr == null
                  ? null
                  : (UploadRef _) => cubit.removeCourtPaymentQr(),
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

class _AdvancePaymentToggleSection extends StatefulWidget {
  const _AdvancePaymentToggleSection({
    required this.court,
    required this.onChanged,
    required this.onTypeChanged,
    required this.onPriceChanged,
  });

  final CourtDraft court;
  final ValueChanged<bool> onChanged;
  final ValueChanged<AdvancePaymentType> onTypeChanged;
  final ValueChanged<String> onPriceChanged;

  @override
  State<_AdvancePaymentToggleSection> createState() =>
      _AdvancePaymentToggleSectionState();
}

class _AdvancePaymentToggleSectionState
    extends State<_AdvancePaymentToggleSection> {
  late final TextEditingController _priceController = TextEditingController(
    text: formatDouble(widget.court.advancePrice),
  );

  @override
  void didUpdateWidget(covariant _AdvancePaymentToggleSection oldWidget) {
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

  String? _priceError() {
    final CourtDraft court = widget.court;
    if (!court.advancePaymentRequired) return null;
    final AdvancePaymentType? type = court.advancePaymentType;
    final double? price = court.advancePrice;
    if (type == null) return null;
    if (price == null) return null;
    if (price <= 0) return 'Amount must be greater than zero.';
    if (type == AdvancePaymentType.percentage && price > 100) {
      return 'Percentage cannot exceed 100.';
    }
    if (type == AdvancePaymentType.flat) {
      final double? base = court.basePrice;
      if (base != null && price > base) {
        return 'Flat amount cannot exceed the base price (${formatDouble(base)}).';
      }
    }
    return null;
  }

  String _priceHint(AdvancePaymentType? type) {
    switch (type) {
      case AdvancePaymentType.percentage:
        return 'Enter a percentage from 0 to 100';
      case AdvancePaymentType.flat:
        final double? base = widget.court.basePrice;
        return base == null
            ? 'Enter the flat advance amount'
            : 'Up to ${formatDouble(base)}';
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
        Container(
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(color: LightColor.borderColor, width: 0.7),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  StringConstants.advancePaymentRequired,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              VendorSwitchButton(
                value: court.advancePaymentRequired,
                onChanged: widget.onChanged,
              ),
            ],
          ),
        ),
        if (court.advancePaymentRequired) ...<Widget>[
          const SizedBox(height: AppDimens.sizeX16),
          Text(
            StringConstants.advancePaymentType,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX8),
          _AdvanceTypeSelector(
            selected: type,
            onSelected: widget.onTypeChanged,
          ),
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
                  ? LightColor.whiteColor
                  : LightColor.secondaryTextColor,
            ),
            const SizedBox(width: AppDimens.sizeX6),
            Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: isSelected
                    ? LightColor.whiteColor
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
