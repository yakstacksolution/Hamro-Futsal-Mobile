part of 'public_packages_bloc.dart';

enum PublicPackagesStatus { idle, loading, success, failure }

final class PublicPackagesState extends Equatable {
  const PublicPackagesState({
    this.status = PublicPackagesStatus.idle,
    this.packages = const <PublicPackageModel>[],
    this.errorMessage,
  });

  final PublicPackagesStatus status;
  final List<PublicPackageModel> packages;
  final String? errorMessage;

  PublicPackagesState copyWith({
    PublicPackagesStatus? status,
    List<PublicPackageModel>? packages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PublicPackagesState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, packages, errorMessage];
}
