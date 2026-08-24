part of 'hosted_by_bloc.dart';

enum HostedByStatus { idle, loading, success, failure }

final class HostedByState extends Equatable {
  const HostedByState({
    this.status = HostedByStatus.idle,
    this.hostedBy,
    this.errorMessage,
  });

  final HostedByStatus status;
  final HostedByModel? hostedBy;
  final String? errorMessage;

  HostedByState copyWith({
    HostedByStatus? status,
    HostedByModel? hostedBy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HostedByState(
      status: status ?? this.status,
      hostedBy: hostedBy ?? this.hostedBy,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, hostedBy, errorMessage];
}
