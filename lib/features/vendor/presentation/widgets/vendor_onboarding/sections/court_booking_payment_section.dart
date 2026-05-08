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
              onPercentChanged: (String value) => cubit.updateActiveCourt(
                court.copyWith(
                  paymentPercent: parseDouble(value),
                  clearPaymentPercent: value.trim().isEmpty,
                ),
              ),
            ),
          if (subsectionIndex == 1)
            VendorUploadSection(
              title: 'Payment QR',
              subtitle: 'Upload the QR used to collect advance payment.',
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
        title: 'Advance Payment',
        subtitle: 'Requirement and collection percentage',
        icon: Icons.payments_rounded,
      ),
      1 => const _CourtPaymentSectionMeta(
        title: 'Payment QR',
        subtitle: 'Upload the QR used to collect advance payments',
        icon: Icons.qr_code_2_rounded,
      ),
      _ => const _CourtPaymentSectionMeta(
        title: 'Booking and Payment',
        subtitle: 'Manage booking and payment settings',
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

class _AdvancePaymentToggleSection extends StatelessWidget {
  const _AdvancePaymentToggleSection({
    required this.court,
    required this.onChanged,
    required this.onPercentChanged,
  });

  final CourtDraft court;
  final ValueChanged<bool> onChanged;
  final ValueChanged<String> onPercentChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
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
                  'Advance payment required',
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              VendorSwitchButton(
                value: court.advancePaymentRequired,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (court.advancePaymentRequired) ...<Widget>[
          const SizedBox(height: AppDimens.sizeX16),
          VendorInputField(
            label: 'Payment %',
            initialValue: formatDouble(court.paymentPercent),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onPercentChanged,
          ),
        ],
      ],
    );
  }
}
