part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchProfileEvent extends ProfileEvent {
  const FetchProfileEvent();
}

final class RequestVendorUpgradeEvent extends ProfileEvent {
  const RequestVendorUpgradeEvent({
    required this.businessName,
    required this.phone,
    required this.address,
    this.message,
  });

  final String businessName;
  final String phone;
  final String address;
  final String? message;

  @override
  List<Object?> get props => <Object?>[businessName, phone, address, message];
}

final class UpdateProfileEvent extends ProfileEvent {
  const UpdateProfileEvent({
    this.fullName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profilePhoto,
    this.profilePhotoUrl,
  });

  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profilePhoto;
  final String? profilePhotoUrl;

  @override
  List<Object?> get props => <Object?>[
    fullName,
    email,
    phone,
    dateOfBirth,
    gender,
    address,
    profilePhoto,
    profilePhotoUrl,
  ];
}
