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

/// UI labels for the account-type picker.
///
/// These are the single source of truth for the strings the picker offers and
/// the string [SignUpEntity.toMap] matches on. Keeping them in one place
/// matters: the mapping is a plain `==` against a display label, so a
/// well-meaning edit to the picker's wording alone would quietly register every
/// vendor as a candidate.
abstract final class AccountTypeLabels {
  static const String player = 'Player';
  static const String vendor = 'Futsal Vendor';

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

/// Tokens from the Google sign-in flow, exchanged with the backend for the
/// app's own session token.
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

/// Credentials from the Apple sign-in flow, exchanged with the backend for the
/// app's own session token.
///
/// Apple only returns [email] and [fullName] on the very first authorization
/// for an Apple ID; every later sign-in omits them, so [toMap] leaves those
/// keys out rather than sending blanks and letting the backend overwrite a
/// stored name with an empty string.
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
