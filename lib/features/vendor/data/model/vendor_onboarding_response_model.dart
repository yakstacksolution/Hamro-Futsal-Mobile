import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

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
    return VendorOnboardingResponseModel(
      id: _asInt(json['id']),
      vendorOnboardingId: _asInt(json['vendor_onboarding_id']),
      userId: _asInt(json['user_id']),
      mainStep: _asInt(json['main_step']) ?? 0,
      subStep: _asInt(json['sub_step']) ?? 0,
      futsalName: json['futsal_name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      socialLink: _asTrimmedString(json['social_link']),
      description: _asTrimmedString(json['description']),
      futsalAddress: _asTrimmedString(json['futsal_address']),
      exactAddress: _asTrimmedString(json['exact_address']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      cancelledPolicy: _asTrimmedString(json['cancelled_policy']),
      futsalRules: json['futsal_rules']?.toString() ?? '',
      packageId: _asInt(json['package_id']),
      packagePercentage: _asDouble(json['package_percentage']),
      coverImage: _uploadFromAny(
        json['cover_image_media'] ?? json['cover_image_id'],
      ),
      galleryImages: _uploadsFromAny(
        json['gallery_media'] ?? json['gallery_image_ids'],
      ),
      companyDocuments: _uploadsFromAny(
        json['company_document_media'] ?? json['company_document_ids'],
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
      commissionPercent:
          packagePercentage ?? _commissionPercentFromPackageId(packageId),
      coverImage: coverImage,
      gallery: galleryImages,
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
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    return UploadRef(
      id: _asInt(map['id']),
      name: map['name']?.toString() ?? map['file_name']?.toString() ?? '',
      localPath:
          map['localPath']?.toString() ??
          map['path']?.toString() ??
          map['url']?.toString() ??
          '',
      remoteUrl: map['url']?.toString(),
    );
  }

  final int? id = _asInt(value);
  if (id == null) return null;
  return UploadRef(id: id, name: '', localPath: '');
}

List<UploadRef> _uploadsFromAny(dynamic value) {
  if (value is List) {
    return value
        .map(_uploadFromAny)
        .whereType<UploadRef>()
        .toList(growable: false);
  }

  final UploadRef? single = _uploadFromAny(value);
  if (single == null) return const <UploadRef>[];
  return <UploadRef>[single];
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
