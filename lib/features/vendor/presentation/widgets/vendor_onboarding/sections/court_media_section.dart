import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/media/presentation/widgets/media_library_sheet.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class CourtMediaSection extends StatelessWidget {
  const CourtMediaSection({
    super.key,
    required this.cubit,
    required this.court,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  Future<void> _openPhotoLibrary(BuildContext context) async {
    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: cubit,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: true,
      initiallySelected: court.photos,
    );
    if (picked == null || picked.isEmpty) return;
    cubit.addCourtPhotos(picked);
  }

  Future<void> _openMemoryLibrary(BuildContext context) async {
    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: cubit,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: true,
      initiallySelected: court.memories,
    );
    if (picked == null || picked.isEmpty) return;
    cubit.addCourtMemories(picked);
  }

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorOnboardingSectionHeader(
            title: StringConstants.uploadPhotosAndMemories,
            subtitle: StringConstants
                .useSeparateCourtMediaToShowConditionLayoutAndEvec64b5,
            icon: Icons.collections_rounded,
          ),
          const SizedBox(height: AppDimens.sizeX12),
          VendorUploadSection(
            title: StringConstants.courtPhotos,
            subtitle: StringConstants.operationalPhotosForThisSpecificCourt,
            onPick: () => unawaited(_openPhotoLibrary(context)),
            actionLabel: 'Gallery',
            actionIcon: Icons.photo_library_rounded,
            files: court.photos,
            onRemove: cubit.removeCourtPhoto,
          ),
          const SizedBox(height: AppDimens.sizeX16),
          VendorUploadSection(
            title: StringConstants.memories,
            subtitle: StringConstants.tournamentsEventsOrPromotionalMoments,
            onPick: () => unawaited(_openMemoryLibrary(context)),
            actionLabel: 'Gallery',
            actionIcon: Icons.collections_bookmark_rounded,
            files: court.memories,
            onRemove: cubit.removeCourtMemory,
          ),
        ],
      ),
    );
  }
}
