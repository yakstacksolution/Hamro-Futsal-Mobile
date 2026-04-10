import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

extension VendorOnboardingApiPayload on VendorOnboardingState {
  /// Builds the request body expected by the "create futsal" endpoint.
  ///
  /// `main_step` and `sub_step` default to the last futsal pointer so that
  /// progress can be restored even when the user is currently editing courts.
  Map<String, dynamic> toCreateFutsalBody({int? mainStep, int? subStep}) {
    final int resolvedMainStep = mainStep ?? futsalPointer.sectionIndex;
    final int resolvedSubStep = subStep ?? futsalPointer.subsectionIndex;

    final int? packageId = _packageIdFromPercent(futsal.commissionPercent);
    final int? packagePercent = futsal.commissionPercent?.round();

    final UploadRef? coverImage = futsal.coverImage;
    final int? coverImageId = coverImage?.id;

    final List<int> galleryIds = futsal.gallery
        .where((UploadRef item) => item.id != null)
        .map((UploadRef item) => item.id!)
        .toList();
    final List<String> galleryMedia = futsal.gallery
        .where((UploadRef item) => item.id == null)
        .map((UploadRef item) => item.localPath)
        .toList();

    final List<int> companyDocumentIds = futsal.companyDocuments
        .where((UploadRef item) => item.id != null)
        .map((UploadRef item) => item.id!)
        .toList();
    final List<String> companyDocumentMedia = futsal.companyDocuments
        .where((UploadRef item) => item.id == null)
        .map((UploadRef item) => item.localPath)
        .toList();

    return <String, dynamic>{
      'main_step': resolvedMainStep,
      'sub_step': resolvedSubStep,
      'futsal_name': futsal.title.trim(),
      'slug': futsal.slug.trim(),
      'registration_number': futsal.registrationNumber.trim(),
      'phone': futsal.phone.trim(),
      'email': futsal.email.trim(),
      'social_link': futsal.websiteOrSocialLink.trim(),
      'description': futsal.description.trim(),
      'address': futsal.location.fullAddress.trim(),
      'exact_address': futsal.location.exactLocation.trim(),
      'latitude': _formatCoordinate(futsal.location.latitude),
      'longitude': _formatCoordinate(futsal.location.longitude),
      'cancelled_policy': futsal.cancellationPolicy.trim(),
      'futsal_rules': futsal.futsalRules.trim(),
      'package_id': packageId,
      'package_percentage': packagePercent,
      'cover_image_id': coverImageId,
      'gallery_image_ids': galleryIds,
      'gallery_media': galleryMedia,
      'company_document_ids': companyDocumentIds,
      'company_document_media': companyDocumentMedia,
    };
  }
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
