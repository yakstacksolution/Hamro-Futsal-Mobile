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

  Future<Result> resendOtp(data) async {
    return await _apiClient.resendOtp(data: data);
  }

  Future<Result> logout() async {
    return await _apiClient.logout();
  }

  Future<Result> getProfile() async {
    return await _apiClient.getProfile();
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

  Future<Result> getMedia() async {
    return await _apiClient.getMedia();
  }

  Future<Result> createMedia(data) async {
    return await _apiClient.createMedia(data: data);
  }

  Future<Result> getPublicServices() async {
    return await _apiClient.getPublicServices();
  }

  Future<Result> getPublicPackages() async {
    return await _apiClient.getPublicPackages();
  }

  Future<Result> getCourtTypes() async {
    return await _apiClient.getCourtTypes();
  }

  Future<Result> getMatchFormats() async {
    return await _apiClient.getMatchFormats();
  }

  Future<Result> getAmenities() async {
    return await _apiClient.getAmenities();
  }

  Future<Result> getFacilities() async {
    return await _apiClient.getFacilities();
  }

  Future<Result> getPublicVenueList({
    int page = 1,
    int perPage = 10,
    Map<String, dynamic>? data,
  }) async {
    return await _apiClient.getPublicVenueList(
      page: page,
      perPage: perPage,
      data: data,
    );
  }

  Future<Result> getCategoryFilter() async {
    return await _apiClient.getCategoryFilter();
  }

  Future<Result> getExpenseCategories() async {
    return await _apiClient.getExpenseCategories();
  }

  Future<Result> getVenueHostedBy(int venueId) async {
    return await _apiClient.getVenueHostedBy(venueId: venueId);
  }

  Future<Result> getVenueDescription(int venueId) async {
    return await _apiClient.getVenueDescription(venueId: venueId);
  }

  Future<Result> getVenueAmenitiesFacilities(int venueId) async {
    return await _apiClient.getVenueAmenitiesFacilities(venueId: venueId);
  }

  Future<Result> getVenueCourt() async {
    return await _apiClient.getVenueCourt();
  }

  Future<Result> getVenueCourtByVenueId(int venueId) async {
    return await _apiClient.getVenueCourtByVenueId(venueId: venueId);
  }

  Future<Result> getCourtDetails(int courtId) async {
    return await _apiClient.getCourtDetails(courtId: courtId);
  }

  Future<Result> getCourtSlots(int courtId) async {
    return await _apiClient.getCourtSlots(courtId: courtId);
  }

  Future<Result> createCourtSlot(data) async {
    return await _apiClient.createCourtSlot(
      data: Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Result> updateCourtSlot(data) async {
    return await _apiClient.updateCourtSlot(
      data: Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Result> deleteCourtSlot(data) async {
    return await _apiClient.deleteCourtSlot(
      data: Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Result> getPublicTemplates() async {
    return await _apiClient.getPublicTemplates();
  }

  Future<Result> fetchVendorOnboardingFutsal(int venueId) async {
    return await _apiClient.fetchVendorOnboardingFutsal(venueId: venueId);
  }

  Future<Result> submitVendorOnboardingFutsal(data) async {
    return await _apiClient.submitVendorOnboardingFutsal(
      data: Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Result> updateVendorOnboardingFutsal(data) async {
    return await _apiClient.updateVendorOnboardingFutsal(
      data: Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Result> submitVendorOnboardingCourt(data) async {
    return await _apiClient.submitVendorOnboardingCourt(
      data: Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Result> updateVendorOnboardingCourt(data) async {
    return await _apiClient.updateVendorOnboardingCourt(
      data: Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Result> deleteVendorOnboardingCourt(int courtId) async {
    return await _apiClient.deleteVendorOnboardingCourt(courtId: courtId);
  }

  Future<Result> deleteVendorCourt(data) async {
    return await _apiClient.deleteVendorCourt(
      data: Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Result> getMyBookings() async {
    return await _apiClient.getMyBookings();
  }

  Future<Result> getFutsalBookings() async {
    return await _apiClient.getFutsalBookings();
  }
}
