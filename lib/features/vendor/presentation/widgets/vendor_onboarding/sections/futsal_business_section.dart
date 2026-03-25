import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class FutsalBusinessSection extends StatelessWidget {
  const FutsalBusinessSection({
    super.key,
    required this.cubit,
    required this.draft,
    required this.subsectionIndex,
  });

  final VendorOnboardingCubit cubit;
  final FutsalDraft draft;
  final int subsectionIndex;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorPanelHeading(
            title: 'Business Assets',
            subtitle:
                'Upload the parent-level visuals and legal documents once. Courts keep separate media for their own listings.',
          ),
          const SizedBox(height: 18),
          if (subsectionIndex == 0)
            VendorUploadSection(
              title: 'Cover image',
              subtitle: 'Primary business thumbnail for the futsal listing.',
              onPick: () => unawaited(cubit.pickFutsalCoverImage()),
              files: draft.coverImage == null
                  ? const <UploadRef>[]
                  : <UploadRef>[draft.coverImage!],
              onRemove: draft.coverImage == null
                  ? null
                  : (UploadRef _) => cubit.removeFutsalCoverImage(),
            ),
          if (subsectionIndex == 1)
            VendorUploadSection(
              title: 'Gallery',
              subtitle: 'Venue-level gallery images.',
              onPick: () => unawaited(cubit.pickFutsalGalleryImages()),
              files: draft.gallery,
              onRemove: cubit.removeFutsalGalleryImage,
            ),
          if (subsectionIndex == 2)
            VendorUploadSection(
              title: 'Company documents',
              subtitle: 'Registration, PAN, license, or supporting documents.',
              onPick: () => unawaited(cubit.pickCompanyDocuments()),
              files: draft.companyDocuments,
              onRemove: cubit.removeCompanyDocument,
            ),
        ],
      ),
    );
  }
}
