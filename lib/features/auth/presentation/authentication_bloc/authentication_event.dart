part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

final class LoginEvent extends AuthenticationEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginEvent({
    required this.email,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
}

final class RegisterEvent extends AuthenticationEvent {
  final String fullName;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String accountType;
  final bool termsAccepted;

  const RegisterEvent({
    required this.fullName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.accountType,
    required this.termsAccepted,
  });

  @override
  List<Object> get props => [
    fullName,
    email,
    password,
    passwordConfirmation,
    accountType,
    termsAccepted,
  ];
}

final class OtpVerificationEvent extends AuthenticationEvent {
  final String email;
  final String otp;

  const OtpVerificationEvent({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

final class LogoutEvent extends AuthenticationEvent {
  const LogoutEvent();
}

final class ForgotPassword extends AuthenticationEvent {
  final String email;

  const ForgotPassword({required this.email});

  @override
  List<Object> get props => [email];
}
