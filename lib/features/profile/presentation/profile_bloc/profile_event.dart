part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchProfileEvent extends ProfileEvent {
  const FetchProfileEvent();
}
