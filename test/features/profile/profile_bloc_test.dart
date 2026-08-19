import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/domain/repository/profile_repository.dart';
import 'package:hamro_footsall/features/profile/domain/usecase/profile_usecase.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

void main() {
  test(
    'normalizes legacy Other gender to the supported others value',
    () async {
      final _FakeProfileRepository repository = _FakeProfileRepository();
      final ProfileBloc bloc = ProfileBloc(ProfileUseCase(repository));
      addTearDown(bloc.close);

      bloc.add(const FetchProfileEvent());
      await bloc.stream.firstWhere(
        (ProfileState state) => state.status == ProfileStatus.success,
      );

      final Completer<Either<AppException, ProfileModel>> update =
          Completer<Either<AppException, ProfileModel>>();
      repository.updateResponse = update;
      bloc.add(const UpdateProfileEvent(gender: 'Other'));

      await bloc.stream.firstWhere(
        (ProfileState state) => state.status == ProfileStatus.updating,
      );
      expect(repository.lastUpdate?['gender'], 'others');
      update.complete(right(_profile(profilePhoto: null)));
      await bloc.stream.firstWhere(
        (ProfileState state) => state.status == ProfileStatus.updateSuccess,
      );
    },
  );

  test(
    'shows a selected profile photo while the update is in flight',
    () async {
      final _FakeProfileRepository repository = _FakeProfileRepository();
      final ProfileBloc bloc = ProfileBloc(ProfileUseCase(repository));
      addTearDown(bloc.close);

      bloc.add(const FetchProfileEvent());
      await bloc.stream.firstWhere(
        (ProfileState state) => state.status == ProfileStatus.success,
      );

      final Completer<Either<AppException, ProfileModel>> update =
          Completer<Either<AppException, ProfileModel>>();
      repository.updateResponse = update;

      bloc.add(
        const UpdateProfileEvent(
          fullName: 'Player One',
          email: 'player@example.com',
          profilePhoto: '22',
          profilePhotoUrl: 'https://example.com/new-avatar.jpg',
        ),
      );

      final ProfileState updating = await bloc.stream.firstWhere(
        (ProfileState state) => state.status == ProfileStatus.updating,
      );
      expect(updating.profileImage, 'https://example.com/new-avatar.jpg');
      expect(
        updating.profile?.data.profilePhoto?.remoteUrl,
        'https://example.com/new-avatar.jpg',
      );

      update.complete(right(_profile(profilePhoto: null)));
      final ProfileState updated = await bloc.stream.firstWhere(
        (ProfileState state) => state.status == ProfileStatus.updateSuccess,
      );

      expect(updated.profileImage, 'https://example.com/new-avatar.jpg');
      expect(repository.lastUpdate?['profile_photo'], 22);
    },
  );
}

ProfileModel _profile({required UploadRef? profilePhoto}) {
  return ProfileModel(
    status: 'success',
    message: 'Updated',
    data: UserData(
      id: 1,
      fullName: 'Player One',
      email: 'player@example.com',
      role: 'candidate',
      requiresVendorOnboarding: false,
      profilePhoto: profilePhoto,
    ),
  );
}

class _FakeProfileRepository implements ProfileRepository {
  Completer<Either<AppException, ProfileModel>>? updateResponse;
  Map<String, dynamic>? lastUpdate;

  @override
  Future<Either<AppException, ProfileModel>> getProfile() async {
    return right(
      _profile(
        profilePhoto: const UploadRef(
          name: 'old-avatar.jpg',
          id: 10,
          remoteUrl: 'https://example.com/old-avatar.jpg',
        ),
      ),
    );
  }

  @override
  Future<Either<AppException, String>> requestVendorUpgrade(
    Map<String, dynamic> data,
  ) async {
    return right('Request submitted');
  }

  @override
  Future<Either<AppException, ProfileModel>> updateProfile(
    Map<String, dynamic> data,
  ) {
    lastUpdate = data;
    return updateResponse!.future;
  }

  @override
  Future<Either<AppException, bool>> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    return right(true);
  }
}
