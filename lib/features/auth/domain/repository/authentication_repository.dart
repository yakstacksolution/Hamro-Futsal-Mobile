import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/auth/data/model/token_model.dart';

abstract class AuthRepository {
  Future<Either<AppException, TokenModel>> signIn(data);
  Future<Either<AppException, TokenModel>> signInWithGoogle(data);
  Future<Either<AppException, TokenModel>> signInWithApple(data);
  Future<Either<AppException, TokenModel>> signUp(data);
  Future<Either<AppException, Map<String, dynamic>>>? verifyOtp(data);
  Future<Either<AppException, Map<String, dynamic>>>? resendOtp(data);
  Future<Either<AppException, bool>>? logout();

  Future<Either<AppException, TokenModel>> getTokenDetails();
  Future<bool> clearTokenDetails();

  /// Clears the session, including any stored biometric session, so the user
  /// has to sign in again — used after the password changes.
  Future<bool> endSession();

  /// Resolves with the API's own `message` so the caller can show exactly
  /// what the server said.
  Future<Either<AppException, String>>? forgotPassword(data);

  /// Completes the reset with the emailed OTP and the new password. Returns
  /// the server's success message.
  Future<Either<AppException, String>> resetPassword(data);
  Future<Either<AppException, bool>>? changePassword(data);
}
