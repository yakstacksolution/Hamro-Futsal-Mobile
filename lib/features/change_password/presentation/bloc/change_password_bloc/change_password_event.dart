part of 'change_password_bloc.dart';

sealed class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Submits the form to `PUT /auth/password`.
final class SubmitChangePasswordEvent extends ChangePasswordEvent {
  const SubmitChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}
