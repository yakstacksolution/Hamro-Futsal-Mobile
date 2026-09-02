import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';

abstract class AuthRemoteDataSource {
  Future<Result> signIn(Map<String, dynamic> signInData);
  Future<Result> signInWithGoogle(Map<String, dynamic> googleData);
  Future<Result> signInWithApple(Map<String, dynamic> appleData);
  Future<Result> signUp(Map<String, dynamic> signUpData);
  Future<Result> verifyOtp(Map<String, dynamic> otpData);
  Future<Result> resendOtp(Map<String, dynamic> resendOtpData);
  Future<Result> logout();
  Future<Result> forgotPassword(Map<String, dynamic> forgotPasswordData);
  Future<Result> changePassword(Map<String, dynamic> changePasswordData);
}

final class AuthenticationDataSourceImpl extends AuthRemoteDataSource {
  @override
  Future<Result> changePassword(
    Map<String, dynamic> changePasswordData,
  ) async => await Client.instance().getAuthManager().changePassword(
    changePasswordData,
  );

  @override
  Future<Result> forgotPassword(
    Map<String, dynamic> forgotPasswordData,
  ) async => await Client.instance().getAuthManager().forgotPassword(
    forgotPasswordData,
  );

  @override
  Future<Result> signIn(Map<String, dynamic> signInData) async =>
      await Client.instance().getAuthManager().login(signInData);

  @override
  Future<Result> signInWithGoogle(Map<String, dynamic> googleData) async =>
      await Client.instance().getAuthManager().googleLogin(googleData);

  @override
  Future<Result> signInWithApple(Map<String, dynamic> appleData) async =>
      await Client.instance().getAuthManager().appleLogin(appleData);

  @override
  Future<Result> signUp(Map<String, dynamic> signUpData) async =>
      await Client.instance().getAuthManager().register(signUpData);

  @override
  Future<Result> verifyOtp(Map<String, dynamic> otpData) async =>
      await Client.instance().getAuthManager().verifyOtp(otpData);

  @override
  Future<Result> resendOtp(Map<String, dynamic> resendOtpData) async =>
      await Client.instance().getAuthManager().resendOtp(resendOtpData);

  @override
  Future<Result> logout() async =>
      await Client.instance().getAuthManager().logout();
}
