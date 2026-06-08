import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/wishlist_store.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/domain/usecase/profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._profileUseCase) : super(const ProfileState()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  final ProfileUseCase _profileUseCase;

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
    try {
      emit(
        state.copyWith(
          status: ProfileStatus.updating,
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
            errorMessage: failure.errorMessage,
          ),
        ),
        (ProfileModel profile) {
          final ProfileModel merged = _mergeProfile(state.profile, profile);
          emit(
            state.copyWith(
              status: ProfileStatus.updateSuccess,
              profile: merged,
              profileImage: merged.data.profilePhoto?.remoteUrl,
              successMessage: profile.message.isNotEmpty
                  ? profile.message
                  : 'Profile updated successfully.',
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

  ProfileModel _mergeProfile(ProfileModel? existing, ProfileModel incoming) {
    if (existing == null) return incoming;
    return incoming.copyWith(data: existing.data.mergeWith(incoming.data));
  }

  Map<String, dynamic> _buildUpdatePayload(UpdateProfileEvent event) {
    final DateTime? dob = event.dateOfBirth;
    return <String, dynamic>{
      'full_name': event.fullName ?? '',
      'email': event.email ?? '',
      'phone': event.phone ?? '',
      'date_of_birth': dob == null
          ? ''
          : '${dob.year.toString().padLeft(4, '0')}-'
                '${dob.month.toString().padLeft(2, '0')}-'
                '${dob.day.toString().padLeft(2, '0')}',
      'gender': event.gender?.toLowerCase() ?? '',
      'address': event.address ?? '',
      if (event.profilePhoto?.isNotEmpty == true)
        'profile_photo': int.parse(event.profilePhoto!),
    };
  }
}

 