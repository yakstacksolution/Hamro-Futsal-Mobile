import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

class VendorOnboardingResponseModel {
  const VendorOnboardingResponseModel({
    this.id,
    this.vendorOnboardingId,
    this.userId,
    this.mainStep = 0,
    this.subStep = 0,
    this.futsalName = '',
    this.slug = '',
    this.registrationNumber = '',
    this.phone = '',
    this.email = '',
    this.socialLink = '',
    this.description = '',
    this.futsalAddress = '',
    this.exactAddress = '',
    this.latitude,
    this.longitude,
    this.cancelledPolicy = '',
    this.futsalRules = '',
    this.packageId,
    this.packagePercentage,
    this.coverImage,
    this.galleryImages = const <UploadRef>[],
    this.companyDocuments = const <UploadRef>[],
  });

  final int? id;
  final int? vendorOnboardingId;
  final int? userId;
  final int mainStep;
  final int subStep;
  final String futsalName;
  final String slug;
  final String registrationNumber;
  final String phone;
  final String email;
  final String socialLink;
  final String description;
  final String futsalAddress;
  final String exactAddress;
  final double? latitude;
  final double? longitude;
  final String cancelledPolicy;
  final String futsalRules;
  final int? packageId;
  final double? packagePercentage;
  final UploadRef? coverImage;
  final List<UploadRef> galleryImages;
  final List<UploadRef> companyDocuments;

  factory VendorOnboardingResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return VendorOnboardingResponseModel(
      id: _asInt(data['id'] ?? data['court_id']),
      vendorOnboardingId: _asInt(data['vendor_onboarding_id']),
      userId: _asInt(data['user_id']),
      mainStep: _asInt(data['main_step']) ?? 0,
      subStep: _asInt(data['sub_step']) ?? 0,
      futsalName: _asTrimmedString(data['futsal_name'] ?? data['name']),
      slug: _asTrimmedString(data['slug']),
      registrationNumber: _asTrimmedString(data['registration_number']),
      phone: _asTrimmedString(data['phone'] ?? data['phone_number']),
      email: _asTrimmedString(data['email'] ?? data['email_address']),
      socialLink: _asTrimmedString(data['social_link']),
      description: _asTrimmedString(data['description']),
      futsalAddress: _asTrimmedString(
        data['futsal_address'] ?? data['address'],
      ),
      exactAddress: _asTrimmedString(data['exact_address']),
      latitude: _asDouble(data['latitude']),
      longitude: _asDouble(data['longitude']),
      cancelledPolicy: _asTrimmedString(
        data['cancelled_policy'] ?? data['cancellation_policy'],
      ),
      futsalRules: _asTrimmedString(data['futsal_rules'] ?? data['rules']),
      packageId: _asInt(data['package_id']),
      packagePercentage: _asDouble(
        data['package_percentage'] ?? data['commission_percent'],
      ),
      coverImage: _uploadFromAny(
        data['cover_image_media'] ?? data['cover_image_id'],
      ),
      galleryImages: _uploadsFromAny(
        data['gallery_media'] ?? data['gallery_image_ids'],
      ),
      companyDocuments: _uploadsFromAny(
        data['company_document_media'] ?? data['company_document_ids'],
      ),
    );
  }

  FutsalDraft toDraft() {
    return FutsalDraft(
      title: futsalName.trim(),
      slug: slug.trim(),
      registrationNumber: registrationNumber.trim(),
      phone: phone.trim(),
      email: email.trim(),
      websiteOrSocialLink: socialLink.trim(),
      description: description.trim(),
      location: LocationDraft(
        fullAddress: futsalAddress.trim(),
        exactLocation: exactAddress.trim(),
        latitude: latitude,
        longitude: longitude,
      ),
      cancellationPolicy: cancelledPolicy.trim(),
      futsalRules: futsalRules.trim(),
      packageId: packageId,
      commissionPercent:
          packagePercentage ?? _commissionPercentFromPackageId(packageId),
      coverImage: coverImage,
      gallery: galleryImages,
      selectedCoverImage: coverImage == null
          ? null
          : SelectedImageRef.fromUploadRef(coverImage!),
      selectedGalleryImages: galleryImages
          .map(SelectedImageRef.fromUploadRef)
          .toList(growable: false),
      companyDocuments: companyDocuments,
    );
  }
}

double? _commissionPercentFromPackageId(int? packageId) {
  switch (packageId) {
    case 1:
      return 5;
    case 2:
      return 10;
    default:
      return null;
  }
}

UploadRef? _uploadFromAny(dynamic value) {
  if (value == null) return null;

  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final int? id = _asInt(map['id']);
    final String remoteUrl = _asTrimmedString(
      map['url'] ??
          map['full_url'] ??
          map['original_url'] ??
          map['preview_url'] ??
          map['media_url'] ??
          map['file_url'] ??
          map['fileUrl'] ??
          map['thumbnail_url'] ??
          map['thumbnailUrl'] ??
          map['src'] ??
          map['remoteUrl'] ??
          map['remote_url'] ??
          map['path'] ??
          map['file_path'],
    );
    final String name = _asTrimmedString(
      map['name'] ?? map['file_name'] ?? _fileNameFromUrl(remoteUrl),
    );
    if (id == null && remoteUrl.isEmpty && name.isEmpty) return null;

    return UploadRef(
      id: id,
      name: name,
      remoteUrl: remoteUrl.isEmpty ? null : remoteUrl,
      verificationStatus: UploadVerificationStatus.fromString(
        _asTrimmedString(map['verification_status']),
      ),
    );
  }

  final id = _asInt(value);
  if (id == null) return null;

  return UploadRef(id: id, name: '', remoteUrl: '');
}

String _fileNameFromUrl(String url) {
  if (url.trim().isEmpty) return '';
  final Uri? uri = Uri.tryParse(url);
  final String path = uri?.path.trim().isNotEmpty == true ? uri!.path : url;
  final List<String> parts = path.split('/');
  return parts.isEmpty ? '' : parts.last;
}

List<UploadRef> _uploadsFromAny(dynamic value) {
  if (value is List) {
    return value
        .map(_uploadFromAny)
        .whereType<UploadRef>()
        .toList(growable: false);
  }

  final single = _uploadFromAny(value);
  if (single == null) return const [];
  return [single];
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

String _asTrimmedString(Object? value) {
  if (value == null) return '';
  return value.toString().trim();
}
