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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
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
      vendorOnboardingData: json['vendor_onboarding_data'],
      designation: json['designation'],
      profilePhoto: json['profile_photo'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
    createdAt,
    updatedAt,
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// import 'package:hamro_footsall/features/profile/domain/entities/profile_entity.dart';

// class ProfileModel extends ProfileEntity {
//   const ProfileModel({
//     super.id,
//     required super.fullName,
//     required super.email,
//     super.role,
//     super.phone,
//     super.profilePhoto,
//   });

//   factory ProfileModel.fromJson(Map<String, dynamic> json) {
//     return ProfileModel(
//       id: json['id'] as int?,
//       fullName:
//           (json['full_name'] ?? json['name'] ?? '').toString().trim().isEmpty
//           ? 'Guest User'
//           : (json['full_name'] ?? json['name']).toString(),
//       email: (json['email'] ?? '').toString(),
//       role: json['role']?.toString(),
//       phone: json['phone']?.toString(),
//       profilePhoto: json['profile_photo']?.toString(),
//     );
//   }
// }
