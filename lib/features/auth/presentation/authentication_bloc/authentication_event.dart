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

final class GoogleLoginEvent extends AuthenticationEvent {
  const GoogleLoginEvent();
}

final class AppleLoginEvent extends AuthenticationEvent {
  const AppleLoginEvent();
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

final class ForgotPasswordEvent extends AuthenticationEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

final class ResetPasswordEvent extends AuthenticationEvent {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordEvent({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [email, otp, password, passwordConfirmation];
}

final class ResendOtpEvent extends AuthenticationEvent {
  final String email;
  final String? purpose;

  const ResendOtpEvent({required this.email, this.purpose});

  @override
  List<Object> get props => [email, purpose ?? ''];
}
