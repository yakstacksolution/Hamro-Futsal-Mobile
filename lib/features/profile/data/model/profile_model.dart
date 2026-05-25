import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String status;
  final String message;
  final UserData data;

  const ProfileModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: UserData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }

  @override
  List<Object?> get props => [status, message, data];

  ProfileModel copyWith({String? status, String? message, UserData? data}) {
    return ProfileModel(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

class UserData extends Equatable {
  final int id;
  final String name;
  final String fullName;
  final String email;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String role;
  final DateTime? emailVerifiedAt;
  final bool requiresVendorOnboarding;
  final DateTime? vendorOnboardingCompletedAt;
  final Map<String, dynamic>? vendorOnboardingData;
  final String? designation;
  final String? profilePhoto;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? futsalId;
  final int? mainStep;
  final int? subStep;

  const UserData({
    required this.id,
    required this.name,
    required this.fullName,
    required this.email,
    this.phone,
    this.latitude,
    this.longitude,
    required this.role,
    this.emailVerifiedAt,
    required this.requiresVendorOnboarding,
    this.vendorOnboardingCompletedAt,
    this.vendorOnboardingData,
    this.designation,
    this.profilePhoto,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.futsalId,
    this.mainStep,
    this.subStep,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      role: json['role'] ?? '',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
      requiresVendorOnboarding: json['requires_vendor_onboarding'] ?? false,
      vendorOnboardingCompletedAt:
          json['vendor_onboarding_completed_at'] != null
          ? DateTime.tryParse(json['vendor_onboarding_completed_at'])
          : null,
      vendorOnboardingData: json['vendor_onboarding_data'] is Map
          ? Map<String, dynamic>.from(json['vendor_onboarding_data'] as Map)
          : null,
      designation: json['designation'],
      profilePhoto: json['profile_photo'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      futsalId:
          _asInt(json['futsal_id']) ??
          _asInt((json['vendor_onboarding_data'] as Map?)?['id']),
      mainStep:
          _asInt(json['main_step']) ??
          _asInt((json['vendor_onboarding_data'] as Map?)?['main_step']),
      subStep:
          _asInt(json['sub_step']) ??
          _asInt((json['vendor_onboarding_data'] as Map?)?['sub_step']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'role': role,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'requires_vendor_onboarding': requiresVendorOnboarding,
      'vendor_onboarding_completed_at': vendorOnboardingCompletedAt
          ?.toIso8601String(),
      'vendor_onboarding_data': vendorOnboardingData,
      'designation': designation,
      'profile_photo': profilePhoto,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'futsal_id': futsalId,
      'main_step': mainStep,
      'sub_step': subStep,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    fullName,
    email,
    phone,
    latitude,
    longitude,
    role,
    emailVerifiedAt,
    requiresVendorOnboarding,
    vendorOnboardingCompletedAt,
    vendorOnboardingData,
    designation,
    profilePhoto,
    dateOfBirth,
    gender,
    address,
    createdAt,
    updatedAt,
    futsalId,
    mainStep,
    subStep,
  ];

  UserData copyWith({
    int? id,
    String? name,
    String? fullName,
    String? email,
    String? phone,
    double? latitude,
    double? longitude,
    String? role,
    DateTime? emailVerifiedAt,
    bool? requiresVendorOnboarding,
    DateTime? vendorOnboardingCompletedAt,
    Map<String, dynamic>? vendorOnboardingData,
    String? designation,
    String? profilePhoto,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? futsalId,
    int? mainStep,
    int? subStep,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      role: role ?? this.role,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      requiresVendorOnboarding:
          requiresVendorOnboarding ?? this.requiresVendorOnboarding,
      vendorOnboardingCompletedAt:
          vendorOnboardingCompletedAt ?? this.vendorOnboardingCompletedAt,
      vendorOnboardingData: vendorOnboardingData ?? this.vendorOnboardingData,
      designation: designation ?? this.designation,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      futsalId: futsalId ?? this.futsalId,
      mainStep: mainStep ?? this.mainStep,
      subStep: subStep ?? this.subStep,
    );
  }

  // Merges [other] into this, preserving existing non-null values when [other] has null.
  UserData mergeWith(UserData other) {
    return copyWith(
      id: other.id,
      name: other.name.isNotEmpty ? other.name : null,
      fullName: other.fullName.isNotEmpty ? other.fullName : null,
      email: other.email.isNotEmpty ? other.email : null,
      phone: other.phone,
      latitude: other.latitude,
      longitude: other.longitude,
      role: other.role.isNotEmpty ? other.role : null,
      emailVerifiedAt: other.emailVerifiedAt,
      requiresVendorOnboarding: other.requiresVendorOnboarding,
      vendorOnboardingCompletedAt: other.vendorOnboardingCompletedAt,
      vendorOnboardingData: other.vendorOnboardingData,
      designation: other.designation,
      profilePhoto: other.profilePhoto,
      dateOfBirth: other.dateOfBirth,
      gender: other.gender,
      address: other.address,
      createdAt: other.createdAt,
      updatedAt: other.updatedAt,
      futsalId: other.futsalId,
      mainStep: other.mainStep,
      subStep: other.subStep,
    );
  }
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}
