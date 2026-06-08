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
      // UI label → backend value: Player → candidate, Footsall Vendor → vendor.
      "account_type": accountType == "Footsall Vendor" ? "vendor" : "candidate",
      // Identifies which client app the registration came from.
      "client": "customer",
      "email": email,
      "terms_accepted": termAccepted,
    };
  }
}

class ForgotPasswordEntity extends Equatable {
  final String email;
  final int otp;
  final String newPassword;

  const ForgotPasswordEntity({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [otp, email, newPassword];

  Map<String, dynamic> toMap() {
    return {"newPassword": newPassword, "otp": otp, "email": email};
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

  const ResendOtpEntity({
    required this.email,
    this.purpose,
  });

  @override
  List<Object?> get props => [email, purpose];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "email": email,
      if (purpose != null && purpose!.isNotEmpty) "purpose": purpose,
    };
  }
}
