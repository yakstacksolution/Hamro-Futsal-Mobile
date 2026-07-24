import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

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

/// The four `/auth/notification-preferences` flags, served back on `/auth/me`.
class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.pushNotification = true,
    this.bookingAlert = true,
    this.opponentRequest = true,
    this.promotionalEmails = false,
  });

  final bool pushNotification;
  final bool bookingAlert;
  final bool opponentRequest;
  final bool promotionalEmails;

  /// API booleans arrive as true/false, 0/1 or "0"/"1" depending on the
  /// serializer — accept them all.
  static bool _flag(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == '1' || v == 'true') return true;
      if (v == '0' || v == 'false') return false;
    }
    return fallback;
  }

  /// Tolerates the flags living nested under `notification_preferences` or
  /// directly on the `/auth/me` user row.
  factory NotificationPreferences.fromUserJson(Map<String, dynamic> json) {
    final dynamic nested = json['notification_preferences'];
    final Map source = nested is Map ? nested : json;
    return NotificationPreferences(
      pushNotification: _flag(source['enable_push_notification'], true),
      bookingAlert: _flag(source['enable_booking_alert'], true),
      opponentRequest: _flag(source['enable_opponent_request'], true),
      promotionalEmails: _flag(source['enable_promotional_emails'], false),
    );
  }

  /// Payload shape for `POST /auth/notification-preferences`.
  Map<String, dynamic> toJson() => {
    'enable_push_notification': pushNotification,
    'enable_booking_alert': bookingAlert,
    'enable_opponent_request': opponentRequest,
    'enable_promotional_emails': promotionalEmails,
  };

  @override
  List<Object?> get props => [
    pushNotification,
    bookingAlert,
    opponentRequest,
    promotionalEmails,
  ];
}

enum VendorLifecycleStatus {
  notStarted,
  incomplete,
  underReview,
  rejected,
  active,
  suspended,
  actionRequired;

  static VendorLifecycleStatus parse(Object? value) {
    final String status = value?.toString().trim().toLowerCase() ?? '';
    return switch (status) {
      'incomplete' || 'draft' => VendorLifecycleStatus.incomplete,
      'under_review' || 'pending_review' => VendorLifecycleStatus.underReview,
      'rejected' => VendorLifecycleStatus.rejected,
      'active' || 'approved' => VendorLifecycleStatus.active,
      'suspended' => VendorLifecycleStatus.suspended,
      'action_required' => VendorLifecycleStatus.actionRequired,
      _ => VendorLifecycleStatus.notStarted,
    };
  }
}

class UserData extends Equatable {
  final int id;
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
  final UploadRef? profilePhoto;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? futsalId;
  final int? mainStep;
  final int? subStep;
  final Set<String> capabilities;
  final VendorLifecycleStatus vendorStatus;
  final String vendorStatusReason;
  final int profileCompletion;
  final bool businessVerified;
  final bool financeAccess;

  /// Venue ids the user has wishlisted (`wishlists` on `/auth/me`) — drives
  /// the heart state on venue cards.
  final List<int> wishlistVenueIds;

  /// Notification flags from `/auth/me`, edited on the Settings page.
  final NotificationPreferences notificationPreferences;

  const UserData({
    required this.id,
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
    this.capabilities = const <String>{},
    this.vendorStatus = VendorLifecycleStatus.notStarted,
    this.vendorStatusReason = '',
    this.profileCompletion = 0,
    this.businessVerified = false,
    this.financeAccess = false,
    this.wishlistVenueIds = const <int>[],
    this.notificationPreferences = const NotificationPreferences(),
  });

  /// Accepts `[1, 2]` or `[{venue_id: 1}, ...]` / `[{id: 1}, ...]`.
  static List<int> _parseWishlistIds(dynamic value) {
    if (value is! List) return const <int>[];
    return value
        .map(
          (dynamic item) => item is Map
              ? _asInt(item['venue_id'] ?? item['id'])
              : _asInt(item),
        )
        .whereType<int>()
        .toList(growable: false);
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
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
      profilePhoto: json['profile_photo'] != null
          ? UploadRef.fromJson(json['profile_photo'])
          : null,
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
      capabilities: (json['capabilities'] is List)
          ? (json['capabilities'] as List)
                .map((item) => item.toString().trim())
                .where((item) => item.isNotEmpty)
                .toSet()
          : const <String>{},
      vendorStatus: VendorLifecycleStatus.parse(
        json['vendor_status'] ?? json['vendor_lifecycle_status'],
      ),
      vendorStatusReason: json['vendor_status_reason']?.toString().trim() ?? '',
      profileCompletion:
          _asInt(
            json['profile_completion'] ?? json['profile_completion_pct'],
          ) ??
          0,
      businessVerified: json['business_verified'] == true,
      financeAccess:
          json['finance_access'] == true ||
          (json['capabilities'] is List &&
              (json['capabilities'] as List).contains('vendor.finance.read')),
      wishlistVenueIds: _parseWishlistIds(json['wishlists']),
      notificationPreferences: NotificationPreferences.fromUserJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'capabilities': capabilities.toList(growable: false),
      'vendor_status': vendorStatus.name,
      'vendor_status_reason': vendorStatusReason,
      'profile_completion': profileCompletion,
      'business_verified': businessVerified,
      'finance_access': financeAccess,
      'wishlists': wishlistVenueIds,
      'notification_preferences': notificationPreferences.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
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
    capabilities,
    vendorStatus,
    vendorStatusReason,
    profileCompletion,
    businessVerified,
    financeAccess,
    wishlistVenueIds,
    notificationPreferences,
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
    UploadRef? profilePhoto,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? futsalId,
    int? mainStep,
    int? subStep,
    Set<String>? capabilities,
    VendorLifecycleStatus? vendorStatus,
    String? vendorStatusReason,
    int? profileCompletion,
    bool? businessVerified,
    bool? financeAccess,
    List<int>? wishlistVenueIds,
    NotificationPreferences? notificationPreferences,
  }) {
    return UserData(
      id: id ?? this.id,
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
      capabilities: capabilities ?? this.capabilities,
      vendorStatus: vendorStatus ?? this.vendorStatus,
      vendorStatusReason: vendorStatusReason ?? this.vendorStatusReason,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      businessVerified: businessVerified ?? this.businessVerified,
      financeAccess: financeAccess ?? this.financeAccess,
      wishlistVenueIds: wishlistVenueIds ?? this.wishlistVenueIds,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }

  // Merges [other] into this, preserving existing non-null values when [other] has null.
  UserData mergeWith(UserData other) {
    return copyWith(
      id: other.id,
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
      capabilities: other.capabilities.isNotEmpty ? other.capabilities : null,
      vendorStatus: other.vendorStatus,
      vendorStatusReason: other.vendorStatusReason,
      profileCompletion: other.profileCompletion,
      businessVerified: other.businessVerified,
      financeAccess: other.financeAccess,
      wishlistVenueIds: other.wishlistVenueIds.isNotEmpty
          ? other.wishlistVenueIds
          : null,
    );
  }
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}
