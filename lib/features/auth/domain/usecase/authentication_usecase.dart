import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/auth/data/model/token_model.dart';
import 'package:hamro_footsall/features/auth/domain/entities/auth_entities.dart';
import 'package:hamro_footsall/features/auth/domain/repository/authentication_repository.dart';

final class AuthUseCase {
  final AuthRepository repository;
  const AuthUseCase(this.repository);
  Future<Either<AppException, TokenModel>> signIn(SignInEntity params) async =>
      await repository.signIn(params.toMap());

  Future<Either<AppException, TokenModel>> signUp(
    SignUpEntity signUpData,
  ) async => await repository.signUp(signUpData.toMap());

  Future<Either<AppException, Map<String, dynamic>>?> verifyOtp(
    OtpVerificationEntity otpData,
  ) async => await repository.verifyOtp(otpData.toMap());

  Future<Either<AppException, Map<String, dynamic>>?> resendOtp(
    ResendOtpEntity resendOtpData,
  ) async => await repository.resendOtp(resendOtpData.toMap());

  Future<Either<AppException, bool>?> logout() async =>
      await repository.logout();
}
