part of 'authentication_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthenticationState extends Equatable {
  final AuthStatus loginStatus;
  final AuthStatus googleLoginStatus;
  final AuthStatus appleLoginStatus;
  final AuthStatus registrationStatus;
  final String successMessage;
  final String? errorMessage;
  final dynamic loginErrorData;
  final dynamic googleLoginErrorData;
  final dynamic appleLoginErrorData;
  final dynamic registrationErrorData;
  final dynamic otpVerificationData;
  final bool obscurePassword;
  final AuthStatus otpVerificationStatus;
  final AuthStatus resendOtpStatus;
  final AuthStatus logoutStatus;

  const AuthenticationState({
    this.loginStatus = AuthStatus.initial,
    this.googleLoginStatus = AuthStatus.initial,
    this.appleLoginStatus = AuthStatus.initial,
    this.errorMessage,
    this.loginErrorData,
    this.googleLoginErrorData,
    this.appleLoginErrorData,
    this.registrationErrorData,
    this.otpVerificationData,
    this.obscurePassword = true,
    this.registrationStatus = AuthStatus.initial,
    this.successMessage = '',
    this.otpVerificationStatus = AuthStatus.initial,
    this.resendOtpStatus = AuthStatus.initial,
    this.logoutStatus = AuthStatus.initial,
  });

  AuthenticationState copyWith({
    AuthStatus? loginStatus,
    AuthStatus? googleLoginStatus,
    AuthStatus? appleLoginStatus,
    String? errorMessage,
    dynamic loginErrorData,
    dynamic googleLoginErrorData,
    dynamic appleLoginErrorData,
    dynamic registrationErrorData,
    dynamic otpVerificationData,
    bool? obscurePassword,
    AuthStatus? registrationStatus,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearErrorData = false,
    bool clearSuccessMessage = false,
    AuthStatus? otpVerificationStatus,
    AuthStatus? resendOtpStatus,
    AuthStatus? logoutStatus,
  }) {
    return AuthenticationState(
      loginStatus: loginStatus ?? this.loginStatus,
      googleLoginStatus: googleLoginStatus ?? this.googleLoginStatus,
      appleLoginStatus: appleLoginStatus ?? this.appleLoginStatus,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      loginErrorData: clearErrorData
          ? null
          : loginErrorData ?? this.loginErrorData,
      googleLoginErrorData: clearErrorData
          ? null
          : googleLoginErrorData ?? this.googleLoginErrorData,
      appleLoginErrorData: clearErrorData
          ? null
          : appleLoginErrorData ?? this.appleLoginErrorData,
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
      resendOtpStatus: resendOtpStatus ?? this.resendOtpStatus,
      logoutStatus: logoutStatus ?? this.logoutStatus,
    );
  }

  @override
  List<Object?> get props => [
    loginStatus,
    googleLoginStatus,
    appleLoginStatus,
    errorMessage,
    loginErrorData,
    googleLoginErrorData,
    appleLoginErrorData,
    obscurePassword,
    registrationStatus,
    registrationErrorData,
    otpVerificationData,
    successMessage,
    otpVerificationStatus,
    resendOtpStatus,
    logoutStatus,
  ];
}
