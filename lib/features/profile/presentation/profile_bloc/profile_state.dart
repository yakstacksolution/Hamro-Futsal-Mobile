part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  failure,
  updating,
  updateSuccess,
  requestingVendor,
  vendorRequestSuccess,
}

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.profileImage,
    this.errorMessage,
    this.successMessage,
  });

  final ProfileStatus status;
  final ProfileModel? profile;
  final String? profileImage;
  final String? errorMessage;
  final String? successMessage;

  bool get isUpdating => status == ProfileStatus.updating;
  bool get isRequestingVendor => status == ProfileStatus.requestingVendor;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? profileImage,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearProfileImage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      profileImage: clearProfileImage
          ? null
          : profileImage ?? this.profileImage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    profile,
    profileImage,
    errorMessage,
    successMessage,
  ];
}
