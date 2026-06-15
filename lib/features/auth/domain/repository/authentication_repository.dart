import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/auth/data/model/token_model.dart';

abstract class AuthRepository {
  Future<Either<AppException, TokenModel>> signIn(data);
  Future<Either<AppException, TokenModel>> signInWithGoogle(data);
  Future<Either<AppException, TokenModel>> signUp(data);
  Future<Either<AppException, Map<String, dynamic>>>? verifyOtp(data);
  Future<Either<AppException, Map<String, dynamic>>>? resendOtp(data);
  Future<Either<AppException, bool>>? logout();

  Future<Either<AppException, TokenModel>> getTokenDetails();
  Future<bool> clearTokenDetails();
  Future<Either<AppException, bool>>? forgotPassword(data);
  Future<Either<AppException, bool>>? changePassword(data);
}
