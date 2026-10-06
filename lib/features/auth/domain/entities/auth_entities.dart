import 'package:equatable/equatable.dart';

class SignInEntity extends Equatable {
  final String password;
  final String email;
  final bool rememberMe;

  const SignInEntity({
    required this.password,
    required this.email,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [password, email];

  Map<String, dynamic> toMap() {
    return {"password": password, "email": email, "rememberMe": rememberMe};
  }
}

abstract final class AccountTypeLabels {
  static const String player = 'Player';
  static const String vendor = 'Venue Vendor';

  static const List<String> all = <String>[player, vendor];
}

class SignUpEntity extends Equatable {
  final String fullName;
  final String password;
  final String passwordConfirmation;
  final String email;
  final bool termAccepted;
  final String accountType;

  const SignUpEntity({
    required this.fullName,
    required this.password,
    required this.passwordConfirmation,
    required this.email,
    required this.termAccepted,
    required this.accountType,
  });

  @override
  List<Object?> get props => [
    password,
    passwordConfirmation,
    email,
    termAccepted,
    accountType,
  ];

  Map<String, dynamic> toMap() {
    return {
      "full_name": fullName,
      "password": password,
      "password_confirmation": passwordConfirmation,
      // UI label → backend value: vendor label → vendor, anything else →
      // candidate.
      "account_type": accountType == AccountTypeLabels.vendor
          ? "vendor"
          : "candidate",
      // Identifies which client app the registration came from.
      "client": "customer",
      "email": email,
      "terms_accepted": termAccepted,
    };
  }
}

class ForgotPasswordOtpRequestEntity extends Equatable {
  final String email;

  const ForgotPasswordOtpRequestEntity({required this.email});

  @override
  List<Object?> get props => [email];

  Map<String, dynamic> toMap() => <String, dynamic>{"email": email};
}

class ResetPasswordEntity extends Equatable {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordEntity({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [email, otp, password, passwordConfirmation];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "email": email,
      "otp": otp,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };
  }
}

class OtpVerificationEntity extends Equatable {
  final String email;
  final String otp;
  final String? password;

  const OtpVerificationEntity({
    required this.email,
    required this.otp,
    this.password,
  });

  @override
  List<Object?> get props => [otp, email, password];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "otp": otp,
      "email": email,
      if (password != null && password!.isNotEmpty) "password": password,
    };
  }
}

class ResendOtpEntity extends Equatable {
  final String email;
  final String? purpose;

  const ResendOtpEntity({required this.email, this.purpose});

  @override
  List<Object?> get props => [email, purpose];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "email": email,
      if (purpose != null && purpose!.isNotEmpty) "purpose": purpose,
    };
  }
}

class GoogleSignInEntity extends Equatable {
  final String? idToken;
  final String? accessToken;

  const GoogleSignInEntity({this.idToken, this.accessToken});

  @override
  List<Object?> get props => [idToken, accessToken];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{"id_token": idToken};
  }
}

class AppleSignInEntity extends Equatable {
  final String? idToken;
  final String? email;
  final String? fullName;

  const AppleSignInEntity({this.idToken, this.email, this.fullName});

  @override
  List<Object?> get props => [idToken, email, fullName];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id_token": idToken,
      if (email != null && email!.isNotEmpty) "email": email,
      if (fullName != null && fullName!.isNotEmpty) "full_name": fullName,
    };
  }
}
