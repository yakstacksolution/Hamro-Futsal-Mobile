part of 'change_password_bloc.dart';

enum ChangePasswordStatus { initial, submitting, success, failure }

final class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.message,
  });

  final ChangePasswordStatus status;

  /// Success message from the server, or the failure reason.
  final String? message;

  bool get isSubmitting => status == ChangePasswordStatus.submitting;

  @override
  List<Object?> get props => [status, message];
}
