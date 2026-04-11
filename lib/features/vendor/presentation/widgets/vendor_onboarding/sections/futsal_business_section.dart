import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/features/media/presentation/widgets/media_library_sheet.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
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

  Future<void> _openCoverLibrary(BuildContext context) async {
    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: cubit,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: false,
      initiallySelected: draft.coverImage == null
          ? const <UploadRef>[]
          : <UploadRef>[draft.coverImage!],
    );
    if (picked == null || picked.isEmpty) return;
    cubit.setFutsalCoverImage(picked.first);
  }

  Future<void> _openGalleryLibrary(BuildContext context) async {
    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: cubit,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: true,
      initiallySelected: draft.gallery,
    );
    if (picked == null || picked.isEmpty) return;
    cubit.addFutsalGalleryImages(picked);
  }

  Future<void> _openDocumentLibrary(BuildContext context) async {
    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: cubit,
      allowedExtensions: const <String>['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
      initiallySelected: draft.companyDocuments,
    );
    if (picked == null || picked.isEmpty) return;
    cubit.addCompanyDocuments(picked);
  }

  @override
  Widget build(BuildContext context) {
    final _BusinessSectionMeta meta = _sectionMeta(subsectionIndex);

    return VendorPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CompactBusinessSectionHeader(meta: meta),
          const SizedBox(height: 12),
          if (subsectionIndex == 0)
            VendorUploadSection(
              title: 'Cover image',
              subtitle: 'Primary business thumbnail for the futsal listing.',
              onPick: () => unawaited(_openCoverLibrary(context)),
              actionLabel: 'Gallery',
              actionIcon: Icons.photo_library_rounded,
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
              onPick: () => unawaited(_openGalleryLibrary(context)),
              actionLabel: 'Gallery',
              actionIcon: Icons.photo_library_rounded,
              files: draft.gallery,
              onRemove: cubit.removeFutsalGalleryImage,
            ),
          if (subsectionIndex == 2)
            VendorUploadSection(
              title: 'Company documents',
              subtitle: 'Registration, PAN, license, or supporting documents.',
              onPick: () => unawaited(_openDocumentLibrary(context)),
              actionLabel: 'Library',
              actionIcon: Icons.folder_copy_rounded,
              files: draft.companyDocuments,
              onRemove: cubit.removeCompanyDocument,
            ),
        ],
      ),
    );
  }

  _BusinessSectionMeta _sectionMeta(int index) {
    switch (index) {
      case 0:
        return const _BusinessSectionMeta(
          title: 'Business Assets',
          subtitle: 'Upload the primary cover image for your futsal listing.',
          icon: Icons.image_rounded,
        );
      case 1:
        return const _BusinessSectionMeta(
          title: 'Gallery',
          subtitle: 'Add venue-level gallery images for your business profile.',
          icon: Icons.collections_rounded,
        );
      case 2:
        return const _BusinessSectionMeta(
          title: 'Company Docs',
          subtitle: 'Upload registration, PAN, license, and related documents.',
          icon: Icons.description_rounded,
        );
      default:
        return const _BusinessSectionMeta(
          title: 'Business Assets',
          subtitle: 'Upload your futsal business media and documents.',
          icon: Icons.business_center_rounded,
        );
    }
  }
}

class _CompactBusinessSectionHeader extends StatelessWidget {
  const _CompactBusinessSectionHeader({required this.meta});

  final _BusinessSectionMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            LightColor.secondaryLight.withValues(alpha: 0.5),
            LightColor.secondaryLight.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LightColor.secondaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta.icon, size: 18, color: LightColor.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  meta.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: LightColor.titleText,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meta.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: LightColor.subtitleText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessSectionMeta {
  const _BusinessSectionMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
