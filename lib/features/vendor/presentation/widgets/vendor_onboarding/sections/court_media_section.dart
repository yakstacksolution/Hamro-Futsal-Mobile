import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class CourtMediaSection extends StatelessWidget {
  const CourtMediaSection({
    super.key,
    required this.cubit,
    required this.court,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorPanelHeading(
            title: 'Upload Photos and Memories',
            subtitle:
                'Use separate court media to show condition, layout, and events without mixing it into the futsal-level gallery.',
          ),
          const SizedBox(height: 18),
          VendorUploadSection(
            title: 'Court photos',
            subtitle: 'Operational photos for this specific court.',
            onPick: () => unawaited(cubit.pickCourtPhotos()),
            files: court.photos,
            onRemove: cubit.removeCourtPhoto,
          ),
          const SizedBox(height: 16),
          VendorUploadSection(
            title: 'Memories',
            subtitle: 'Tournaments, events, or promotional moments.',
            onPick: () => unawaited(cubit.pickCourtMemories()),
            files: court.memories,
            onRemove: cubit.removeCourtMemory,
          ),
        ],
      ),
    );
  }
}
