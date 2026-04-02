import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/media/presentation/widgets/media_library_sheet.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
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
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorPanelHeading(
            title: 'Booking and Payment',
            subtitle:
                'Keep payment requirements conditional so the flow stays simple when advance payment is not needed.',
          ),
          const SizedBox(height: 18),
          if (subsectionIndex == 0)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: court.enableOnlineBooking,
              activeThumbColor: LightColor.secondary,
              title: const Text(
                'Enable online booking',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Disable if this court is managed manually.',
              ),
              onChanged: cubit.toggleCourtOnlineBooking,
            ),
          if (subsectionIndex == 1)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: court.advancePaymentRequired,
              activeThumbColor: LightColor.secondary,
              title: const Text(
                'Advance payment required',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Enable to collect a percentage before booking.',
              ),
              onChanged: court.enableOnlineBooking
                  ? cubit.toggleCourtAdvancePayment
                  : null,
            ),
          if (subsectionIndex == 2)
            VendorInputField(
              label: 'Payment %',
              initialValue: formatDouble(court.paymentPercent),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (String value) => cubit.updateActiveCourt(
                court.copyWith(
                  paymentPercent: parseDouble(value),
                  clearPaymentPercent: value.trim().isEmpty,
                ),
              ),
            ),
          if (subsectionIndex == 3)
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
}
