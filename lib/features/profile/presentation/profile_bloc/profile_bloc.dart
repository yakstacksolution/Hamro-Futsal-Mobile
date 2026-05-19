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
          final ProfileModel? existing = state.profile;
          final ProfileModel merged = existing == null
              ? profile
              : profile.copyWith(data: existing.data.mergeWith(profile.data));
          emit(
            state.copyWith(
              status: ProfileStatus.success,
              profile: merged,
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
}
