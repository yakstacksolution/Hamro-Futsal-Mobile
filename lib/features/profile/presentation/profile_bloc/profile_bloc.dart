import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/wishlist_store.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/domain/usecase/profile_usecase.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._profileUseCase) : super(const ProfileState()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<RequestVendorUpgradeEvent>(_onRequestVendorUpgrade);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  final ProfileUseCase _profileUseCase;

  FutureOr<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final String reason = event.reason.trim();
    if (reason.isEmpty || state.isDeletingAccount) return;

    try {
      emit(
        state.copyWith(
          status: ProfileStatus.deletingAccount,
          clearErrorMessage: true,
          clearSuccessMessage: true,
        ),
      );
      final Either<AppException, bool> response = await _profileUseCase
          .deleteAccount(reason: reason);
      response.fold(
        (AppException failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        ),
        (_) => emit(
          state.copyWith(
            status: ProfileStatus.accountDeleted,
            successMessage: StringConstants.accountDeleted,
            clearErrorMessage: true,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onRequestVendorUpgrade(
    RequestVendorUpgradeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile?.data.role != 'candidate' ||
        state.profile?.data.isVendorRequested == true ||
        state.isRequestingVendor) {
      return;
    }

    try {
      emit(
        state.copyWith(
          status: ProfileStatus.requestingVendor,
          clearErrorMessage: true,
          clearSuccessMessage: true,
        ),
      );
      final Either<AppException, String> response = await _profileUseCase
          .requestVendorUpgrade(<String, dynamic>{
            'business_name': event.businessName.trim(),
            'phone': event.phone.trim(),
            'address': event.address.trim(),
            'message': event.message?.trim().isEmpty == true
                ? null
                : event.message?.trim(),
          });
      response.fold(
        (AppException failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        ),
        (String message) {
          final ProfileModel? profile = state.profile;
          emit(
            state.copyWith(
              status: ProfileStatus.vendorRequestSuccess,
              profile: profile?.copyWith(
                data: profile.data.copyWith(isVendorRequested: true),
              ),
              successMessage: message,
              clearErrorMessage: true,
            ),
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: ProfileStatus.loading, clearErrorMessage: true),
      );
      final Either<AppException, ProfileModel> response = await _profileUseCase
          .getProfile();
      response.fold(
        (AppException failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        ),
        (ProfileModel profile) {
          final ProfileModel merged = _mergeProfile(state.profile, profile);
          // Seed the app-wide heart state from the profile's wishlist ids.
          WishlistStore.instance.seed(merged.data.wishlistVenueIds);
          emit(
            state.copyWith(
              status: ProfileStatus.success,
              profile: merged,
              profileImage: merged.data.profilePhoto?.remoteUrl,
              clearErrorMessage: true,
            ),
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final ProfileModel? previousProfile = state.profile;
    final String? previousProfileImage = state.profileImage;
    final String? previewUrl = _nonEmpty(event.profilePhotoUrl);

    try {
      emit(
        state.copyWith(
          status: ProfileStatus.updating,
          profile: _withPreviewPhoto(state.profile, event, previewUrl),
          profileImage: previewUrl,
          clearErrorMessage: true,
          clearSuccessMessage: true,
        ),
      );

      final Map<String, dynamic> payload = _buildUpdatePayload(event);
      final Either<AppException, ProfileModel> response = await _profileUseCase
          .updateProfile(payload);

      response.fold(
        (AppException failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            profile: previousProfile,
            profileImage: previousProfileImage,
            clearProfileImage: previousProfileImage == null,
            errorMessage: failure.errorMessage,
          ),
        ),
        (ProfileModel profile) {
          final ProfileModel merged = _withPreviewPhoto(
            _mergeProfile(state.profile, profile),
            event,
            previewUrl,
          )!;
          emit(
            state.copyWith(
              status: ProfileStatus.updateSuccess,
              profile: merged,
              profileImage: previewUrl ?? merged.data.profilePhoto?.remoteUrl,
              successMessage: profile.message.isNotEmpty
                  ? profile.message
                  : StringConstants.profileUpdatedSuccessfully,
              clearErrorMessage: true,
            ),
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          profile: previousProfile,
          profileImage: previousProfileImage,
          clearProfileImage: previousProfileImage == null,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  ProfileModel _mergeProfile(ProfileModel? existing, ProfileModel incoming) {
    if (existing == null) return incoming;
    return incoming.copyWith(data: existing.data.mergeWith(incoming.data));
  }

  ProfileModel? _withPreviewPhoto(
    ProfileModel? profile,
    UpdateProfileEvent event,
    String? previewUrl,
  ) {
    if (profile == null || previewUrl == null) return profile;

    final UploadRef? currentPhoto = profile.data.profilePhoto;
    return profile.copyWith(
      data: profile.data.copyWith(
        profilePhoto: UploadRef(
          name: currentPhoto?.name ?? '',
          id: int.tryParse(event.profilePhoto ?? ''),
          remoteUrl: previewUrl,
          verificationStatus:
              currentPhoto?.verificationStatus ?? UploadVerificationStatus.none,
        ),
      ),
    );
  }

  String? _nonEmpty(String? value) {
    final String normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  Map<String, dynamic> _buildUpdatePayload(UpdateProfileEvent event) {
    final DateTime? dob = event.dateOfBirth;
    final String gender = event.gender?.trim().toLowerCase() ?? '';
    return <String, dynamic>{
      'full_name': event.fullName ?? '',
      'email': event.email ?? '',
      'phone': event.phone ?? '',
      'date_of_birth': dob == null
          ? ''
          : '${dob.year.toString().padLeft(4, '0')}-'
                '${dob.month.toString().padLeft(2, '0')}-'
                '${dob.day.toString().padLeft(2, '0')}',
      'gender': gender == 'other' ? 'others' : gender,
      'address': event.address ?? '',
      if (event.profilePhoto?.isNotEmpty == true)
        'profile_photo': int.parse(event.profilePhoto!),
    };
  }
}
