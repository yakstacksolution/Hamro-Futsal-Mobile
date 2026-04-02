part of 'public_services_bloc.dart';

enum PublicServicesStatus { idle, loading, success, failure }

final class PublicServicesState extends Equatable {
  const PublicServicesState({
    this.status = PublicServicesStatus.idle,
    this.services = const <PublicServiceModel>[],
    this.errorMessage,
  });

  final PublicServicesStatus status;
  final List<PublicServiceModel> services;
  final String? errorMessage;

  PublicServicesState copyWith({
    PublicServicesStatus? status,
    List<PublicServiceModel>? services,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PublicServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, services, errorMessage];
}
