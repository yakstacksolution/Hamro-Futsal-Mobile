part of 'authentication_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthenticationState extends Equatable {
  final AuthStatus loginStatus;
  final AuthStatus registrationStatus;
  final String successMessage;
  final String? errorMessage;
  final dynamic loginErrorData;
  final dynamic registrationErrorData;
  final dynamic otpVerificationData;
  final bool obscurePassword;
  final AuthStatus otpVerificationStatus;
  final AuthStatus logoutStatus;

  const AuthenticationState({
    this.loginStatus = AuthStatus.initial,
    this.errorMessage,
    this.loginErrorData,
    this.registrationErrorData,
    this.otpVerificationData,
    this.obscurePassword = true,
    this.registrationStatus = AuthStatus.initial,
    this.successMessage = '',
    this.otpVerificationStatus = AuthStatus.initial,
    this.logoutStatus = AuthStatus.initial,
  });

  AuthenticationState copyWith({
    AuthStatus? loginStatus,
    String? errorMessage,
    dynamic loginErrorData,
    dynamic registrationErrorData,
    dynamic otpVerificationData,
    bool? obscurePassword,
    AuthStatus? registrationStatus,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearErrorData = false,
    bool clearSuccessMessage = false,
    AuthStatus? otpVerificationStatus,
    AuthStatus? logoutStatus,
  }) {
    return AuthenticationState(
      loginStatus: loginStatus ?? this.loginStatus,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      loginErrorData: clearErrorData
          ? null
          : loginErrorData ?? this.loginErrorData,
      registrationErrorData: clearErrorData
          ? null
          : registrationErrorData ?? this.registrationErrorData,
      otpVerificationData: clearErrorData
          ? null
          : otpVerificationData ?? this.otpVerificationData,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      successMessage: clearSuccessMessage
          ? ''
          : successMessage ?? this.successMessage,
      otpVerificationStatus:
          otpVerificationStatus ?? this.otpVerificationStatus,
      logoutStatus: logoutStatus ?? this.logoutStatus,
    );
  }

  @override
  List<Object?> get props => [
    loginStatus,
    errorMessage,
    loginErrorData,
    obscurePassword,
    registrationStatus,
    registrationErrorData,
    otpVerificationData,
    successMessage,
    otpVerificationStatus,
    logoutStatus,
  ];
}
