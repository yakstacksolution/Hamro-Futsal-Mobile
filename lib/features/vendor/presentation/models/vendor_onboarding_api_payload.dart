import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

extension VendorOnboardingApiPayload on VendorOnboardingState {
  Map<String, dynamic> toFutsalBody({
    int? mainStep,
    int? subStep,
    int? futsalId,
  }) {
    final int resolvedMainStep = mainStep ?? futsalPointer.sectionIndex;
    final int resolvedSubStep = subStep ?? futsalPointer.subsectionIndex;

    final int? packageId = _packageIdFromPercent(futsal.commissionPercent);

    final int? coverImageId =
        futsal.selectedCoverImage?.id ?? futsal.coverImage?.id;

    final List<int> galleryIds = futsal.selectedGalleryImages
        .where((SelectedImageRef item) => item.id != null)
        .map((SelectedImageRef item) => item.id!)
        .toList();

    final List<int> fallbackGalleryIds = futsal.gallery
        .where((UploadRef item) => item.id != null)
        .map((UploadRef item) => item.id!)
        .toList();

    final List<int> companyDocumentIds = futsal.companyDocuments
        .where((UploadRef item) => item.id != null)
        .map((UploadRef item) => item.id!)
        .toList();

    final Map<String, dynamic> body = <String, dynamic>{
      'main_step': resolvedMainStep,
      'sub_step': resolvedSubStep,
      'futsal_name': futsal.title.trim(),
      'registration_number': futsal.registrationNumber.trim(),
      'phone_number': futsal.phone.trim(),
      'email_address': futsal.email.trim(),
      'social_link': futsal.websiteOrSocialLink.trim(),
      'description': futsal.description.trim(),
      'address': futsal.location.fullAddress.trim(),
      'exact_address': futsal.location.exactLocation.trim(),
      'latitude': _formatCoordinate(futsal.location.latitude),
      'longitude': _formatCoordinate(futsal.location.longitude),
      'cancellation_policy': futsal.cancellationPolicy.trim(),
      'futsal_rules': futsal.futsalRules.trim(),
      'package_id': packageId,
      'cover_image_id': coverImageId,
      'gallery_image_ids': galleryIds.isNotEmpty
          ? galleryIds
          : fallbackGalleryIds,
      'company_document_ids': companyDocumentIds,
    };

    if (futsalId != null) {
      body['venue_id'] = futsalId;
    }

    return body;
  }

  Map<String, dynamic> toCreateFutsalBody({int? mainStep, int? subStep}) =>
      toFutsalBody(mainStep: mainStep, subStep: subStep);
}

String _formatCoordinate(double? value) {
  if (value == null) return '';
  return value.toStringAsFixed(7);
}

int? _packageIdFromPercent(double? percent) {
  if (percent == null) return null;
  final int rounded = percent.round();
  switch (rounded) {
    case 5:
      return 1;
    case 10:
      return 2;
    default:
      return null;
  }
}
