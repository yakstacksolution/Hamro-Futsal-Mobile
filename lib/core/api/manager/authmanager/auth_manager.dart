import 'package:hamro_footsall/core/api/api_client/api_call_wrapper.dart';
import 'package:hamro_footsall/core/api/api_client/api_client.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/manager/service_manager.dart';

class AuthManager extends ServiceManager {
  String? refreshToken;
  String? token;
  int? userId;
  String? tenantId;
  bool? devModeEnable;

  AuthManager._privateConstructor();

  static final AuthManager _instance = AuthManager._privateConstructor();
  static final ApiClient _apiClient = ApiClient(
    apiCallWrapper: ApiCallWrapper(),
    baseUrl: APIEndpoint.baseUrl,
  );

  factory AuthManager() {
    return _instance;
  }

  factory AuthManager.initializeData(String? refreshToken, String? token) {
    _instance.refreshToken = refreshToken;
    _instance.token = token;
    return _instance;
  }

  Future<Result> login(data) async {
    return await _apiClient.login(data: data);
  }

  Future<Result> register(data) async {
    return await _apiClient.register(data: data);
  }

  Future<Result> verifyOtp(data) async {
    return await _apiClient.verifyOtp(data: data);
  }

  Future<Result> logout() async {
    return await _apiClient.logout();
  }

  Future<Result> getUserDetails() async {
    return await _apiClient.getUserDetails();
  }

  Future<Result> forgotPassword(data) async {
    return await _apiClient.forgotPassword(data: data);
  }

  Future<Result> changePassword(data) async {
    return await _apiClient.changePassword(data: data);
  }

  Future<Result> editPassword(data) async {
    return await _apiClient.editPassword(data: data);
  }

  Future<Result> updateProfile(data) async {
    return await _apiClient.updateProfile(data: data);
  }
}
