import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
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
        (ProfileModel profile) => emit(
          state.copyWith(
            status: ProfileStatus.success,
            profile: _mergeProfile(state.profile, profile),
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
        (ProfileModel profile) => emit(
          state.copyWith(
            status: ProfileStatus.updateSuccess,
            profile: _mergeProfile(state.profile, profile),
            successMessage: profile.message.isNotEmpty
                ? profile.message
                : 'Profile updated successfully.',
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

  ProfileModel _mergeProfile(ProfileModel? existing, ProfileModel incoming) {
    if (existing == null) return incoming;
    return incoming.copyWith(data: existing.data.mergeWith(incoming.data));
  }

  Map<String, dynamic> _buildUpdatePayload(UpdateProfileEvent event) {
    return <String, dynamic>{
      if (event.fullName != null) 'full_name': event.fullName,
      if (event.email != null) 'email': event.email,
      if (event.phone != null) 'phone': event.phone,
      if (event.dateOfBirth != null)
        'date_of_birth':
            '${event.dateOfBirth!.year.toString().padLeft(4, '0')}-'
            '${event.dateOfBirth!.month.toString().padLeft(2, '0')}-'
            '${event.dateOfBirth!.day.toString().padLeft(2, '0')}',
      if (event.gender != null) 'gender': event.gender!.toLowerCase(),
      if (event.address != null) 'address': event.address,
      if (event.profilePhoto != null) 'profile_photo': event.profilePhoto,
    };
  }
}
