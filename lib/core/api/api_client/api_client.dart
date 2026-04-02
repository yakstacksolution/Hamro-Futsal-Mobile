import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/api/api_client/api_call_wrapper.dart';

class ApiClient {
  final ApiCallWrapper _apiCallWrapper;
  final String _baseUrl;

  ApiClient({required ApiCallWrapper apiCallWrapper, required String baseUrl})
    : _apiCallWrapper = apiCallWrapper,
      _baseUrl = baseUrl;

  Future<Result> login({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/login', data: data);
  }

  Future<Result> register({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/register', data: data);
  }

  Future<Result> verifyOtp({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/verify-otp', data: data);
  }

  Future<Result> logout() {
    return _post(url: '$_baseUrl/auth/logout');
  }

  Future<Result> getProfile() {
    return _get(url: '$_baseUrl/auth/me');
  }

  Future<Result> forgotPassword({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/forgot-password', data: data);
  }

  Future<Result> changePassword({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/change-password', data: data);
  }

  Future<Result> getUserDetails() {
    return _get(url: '$_baseUrl/account/2/user/details');
  }

  Future<Result> editPassword({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/account/2/user/edit-password', data: data);
  }

  Future<Result> updateProfile({required Map<String, dynamic> data}) {
    return _put(url: '$_baseUrl/account/2/user/update-profile/', data: data);
  }

  Future<Result> getMedia() {
    return _get(url: '$_baseUrl/media');
  }

  Future<Result> createMedia({required dynamic data}) {
    return _post(url: '$_baseUrl/media', data: data);
  }

  Future<Result> getPublicServices() {
    return _get(url: '$_baseUrl/auth/services');
  }

  Future<Result> getPublicPackages() {
    return _get(url: '$_baseUrl/auth/packages');
  }

  Future<Result> getPublicTemplates() {
    return _get(url: '$_baseUrl/auth/templates');
  }

  Future<Result> _get({required String url}) {
    return _apiCallWrapper.makeRequest(
      url: url,
      token: AppSettings().tokenModel.accessToken,
      method: HttpVerb.get,
    );
  }

  Future<Result> _post({required String url, dynamic data}) {
    return _apiCallWrapper.makeRequest(
      url: url,
      data: data,
      token: AppSettings().tokenModel.accessToken,
      method: HttpVerb.post,
    );
  }

  Future<Result> _put({required String url, dynamic data}) {
    return _apiCallWrapper.makeRequest(
      url: url,
      data: data,
      token: AppSettings().tokenModel.accessToken,
      method: HttpVerb.put,
    );
  }
}
