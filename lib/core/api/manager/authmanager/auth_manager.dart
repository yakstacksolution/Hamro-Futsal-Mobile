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

  Future<Result> googleLogin(Map<String, dynamic> data) async {
    return await _apiClient.googleLogin(data: data);
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

  Future<Result> updateNotificationPreferences(
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.updateNotificationPreferences(data: data);
  }

  /// Authenticated password change (Settings) — distinct from the
  /// forgot-password reset flow's `changePassword`.
  Future<Result> updatePassword(Map<String, dynamic> data) async {
    return await _apiClient.updatePassword(data: data);
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

  Future<Result> getFaqs() async {
    return await _apiClient.getFaqs();
  }

  Future<Result> getHelps() async {
    return await _apiClient.getHelps();
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

  Future<Result> getWishlist() async {
    return await _apiClient.getWishlist();
  }

  Future<Result> toggleWishlist(int venueId) async {
    return await _apiClient.toggleWishlist(venueId: venueId);
  }

  Future<Result> getExpenseCategories() async {
    return await _apiClient.getExpenseCategories();
  }

  Future<Result> getDropdownVenueCourts() async {
    return await _apiClient.getDropdownVenueCourts();
  }

  Future<Result> createExpense(dynamic data) async {
    return await _apiClient.createExpense(data: data);
  }

  Future<Result> getExpenses({Map<String, dynamic>? query}) async {
    return await _apiClient.getExpenses(query: query);
  }

  Future<Result> getConversations({bool archived = false}) async {
    return await _apiClient.getConversations(archived: archived);
  }

  Future<Result> startDirectConversation(Map<String, dynamic> data) async {
    return await _apiClient.startDirectConversation(data: data);
  }

  Future<Result> createGroupConversation(Map<String, dynamic> data) async {
    return await _apiClient.createGroupConversation(data: data);
  }

  Future<Result> getConversationDetails(int conversationId) async {
    return await _apiClient.getConversationDetails(
      conversationId: conversationId,
    );
  }

  Future<Result> getConversationMessages(int conversationId) async {
    return await _apiClient.getConversationMessages(
      conversationId: conversationId,
    );
  }

  Future<Result> sendConversationMessage(
    int conversationId,
    dynamic data,
  ) async {
    return await _apiClient.sendConversationMessage(
      conversationId: conversationId,
      data: data,
    );
  }

  Future<Result> markConversationRead(int conversationId) async {
    return await _apiClient.markConversationRead(
      conversationId: conversationId,
    );
  }

  Future<Result> sendConversationTyping(int conversationId, bool typing) async {
    return await _apiClient.sendConversationTyping(
      conversationId: conversationId,
      typing: typing,
    );
  }

  Future<Result> archiveConversation(int conversationId, bool archived) async {
    return await _apiClient.archiveConversation(
      conversationId: conversationId,
      archived: archived,
    );
  }

  Future<Result> muteConversation(int conversationId, bool muted) async {
    return await _apiClient.muteConversation(
      conversationId: conversationId,
      muted: muted,
    );
  }

  Future<Result> deleteChatMessage(int messageId) async {
    return await _apiClient.deleteChatMessage(messageId: messageId);
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

  Future<Result> getAvailableCourts({
    required int venueId,
    required String selectDate,
    String? slotTime,
  }) async {
    return await _apiClient.getAvailableCourts(
      venueId: venueId,
      selectDate: selectDate,
      slotTime: slotTime,
    );
  }

  Future<Result> getVenueSlots({
    required int venueId,
    required String date,
  }) async {
    return await _apiClient.getVenueSlots(venueId: venueId, date: date);
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

  Future<Result> getTeams() async {
    return await _apiClient.getTeams();
  }

  Future<Result> getPlayerPositions() async {
    return await _apiClient.getPlayerPositions();
  }

  Future<Result> getOpponentLevels() async {
    return await _apiClient.getOpponentLevels();
  }

  Future<Result> getTeam(int teamId) async {
    return await _apiClient.getTeam(teamId: teamId);
  }

  Future<Result> createTeam(Map<String, dynamic> data) async {
    return await _apiClient.createTeam(data: data);
  }

  Future<Result> updateTeam(int teamId, Map<String, dynamic> data) async {
    return await _apiClient.updateTeam(teamId: teamId, data: data);
  }

  Future<Result> deleteTeam(int teamId) async {
    return await _apiClient.deleteTeam(teamId: teamId);
  }

  Future<Result> addTeamMember(int teamId, Map<String, dynamic> data) async {
    return await _apiClient.addTeamMember(teamId: teamId, data: data);
  }

  Future<Result> updateTeamMember(
    int teamId,
    int memberId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.updateTeamMember(
      teamId: teamId,
      memberId: memberId,
      data: data,
    );
  }

  Future<Result> removeTeamMember(int teamId, int memberId) async {
    return await _apiClient.removeTeamMember(
      teamId: teamId,
      memberId: memberId,
    );
  }
}
