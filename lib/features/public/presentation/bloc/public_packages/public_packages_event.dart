part of 'public_packages_bloc.dart';

sealed class PublicPackagesEvent extends Equatable {
  const PublicPackagesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchPublicPackagesEvent extends PublicPackagesEvent {
  const FetchPublicPackagesEvent();
}
