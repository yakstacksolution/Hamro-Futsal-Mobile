part of 'public_services_bloc.dart';

sealed class PublicServicesEvent extends Equatable {
  const PublicServicesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchPublicServicesEvent extends PublicServicesEvent {
  const FetchPublicServicesEvent();
}
