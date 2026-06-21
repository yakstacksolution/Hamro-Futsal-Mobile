import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/api/api_client/api_call_wrapper.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';

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

  Future<Result> resendOtp({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/resend-otp', data: data);
  }

  Future<Result> logout() {
    return _post(url: '$_baseUrl/auth/logout');
  }

  Future<Result> getProfile() {
    return _get(url: '$_baseUrl/auth/me');
  }

  Future<Result> updateNotificationPreferences({
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/auth/notification-preferences', data: data);
  }

  /// Exchanges a Google id token for the app's own session token.
  Future<Result> googleLogin({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/google-login', data: data);
  }

  Future<Result> updatePassword({required Map<String, dynamic> data}) {
    return _put(url: '$_baseUrl/auth/password', data: data);
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
    return _put(url: '$_baseUrl/auth/profile', data: data);
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

  Future<Result> getCourtTypes() {
    return _get(url: '$_baseUrl/court-types');
  }

  Future<Result> getFaqs() {
    return _get(url: '$_baseUrl/faqs');
  }

  Future<Result> getHelps() {
    return _get(url: '$_baseUrl/helps');
  }

  Future<Result> getMatchFormats() {
    return _get(url: '$_baseUrl/match-formate');
  }

  Future<Result> getAmenities() {
    return _get(url: '$_baseUrl/auth/amenities');
  }

  Future<Result> getFacilities() {
    return _get(url: '$_baseUrl/auth/facilities');
  }

  Future<Result> getPublicVenueList({
    int page = 1,
    int perPage = 10,
    Map<String, dynamic>? data,
  }) {
    return _get(
      url: '$_baseUrl/venues',
      query: data ?? <String, dynamic>{'page': page, 'per_page': perPage},
    );
  }

  Future<Result> getCategoryFilter() {
    return _get(url: '$_baseUrl/filters');
  }

  Future<Result> getWishlist() {
    return _get(url: '$_baseUrl/auth/wishlist');
  }

  Future<Result> toggleWishlist({required int venueId}) {
    return _post(url: '$_baseUrl/auth/venues/$venueId/wishlist');
  }

  Future<Result> getExpenseCategories() {
    return _get(url: '$_baseUrl/expense-categories');
  }

  Future<Result> getDropdownVenueCourts() {
    return _get(url: '$_baseUrl/auth/dropdown-venue-courts');
  }

  Future<Result> createExpense({required dynamic data}) {
    return _post(url: '$_baseUrl/auth/expenses', data: data);
  }

  Future<Result> getExpenses({Map<String, dynamic>? query}) {
    return _get(url: '$_baseUrl/auth/expenses', query: query);
  }

  // ── Chat ──

  Future<Result> getConversations({bool archived = false}) {
    return _get(
      url: '$_baseUrl/conversations',
      query: <String, dynamic>{'archived': archived},
    );
  }

  Future<Result> startDirectConversation({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/conversations/direct', data: data);
  }

  Future<Result> createGroupConversation({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/conversations/group', data: data);
  }

  Future<Result> getConversationDetails({required int conversationId}) {
    return _get(url: '$_baseUrl/conversations/$conversationId');
  }

  Future<Result> getConversationMessages({required int conversationId}) {
    return _get(url: '$_baseUrl/conversations/$conversationId/messages');
  }

  Future<Result> sendConversationMessage({
    required int conversationId,
    required dynamic data,
  }) {
    return _post(
      url: '$_baseUrl/conversations/$conversationId/messages',
      data: data,
    );
  }

  Future<Result> markConversationRead({required int conversationId}) {
    return _post(url: '$_baseUrl/conversations/$conversationId/read');
  }

  Future<Result> sendConversationTyping({
    required int conversationId,
    required bool typing,
  }) {
    return _post(
      url:
          '$_baseUrl/conversations/$conversationId/${typing ? 'typing' : 'stop-typing'}',
    );
  }

  Future<Result> archiveConversation({
    required int conversationId,
    required bool archived,
  }) {
    return _post(
      url:
          '$_baseUrl/conversations/$conversationId/${archived ? 'archive' : 'unarchive'}',
    );
  }

  Future<Result> muteConversation({
    required int conversationId,
    required bool muted,
  }) {
    return _post(
      url:
          '$_baseUrl/conversations/$conversationId/${muted ? 'mute' : 'unmute'}',
    );
  }

  Future<Result> deleteChatMessage({required int messageId}) {
    return _delete(url: '$_baseUrl/messages/$messageId');
  }

  Future<Result> getVenueHostedBy({required int venueId}) {
    return _get(url: '$_baseUrl/hosted-by/2');
  }

  Future<Result> getVenueDescription({required int venueId}) {
    return _get(url: '$_baseUrl/venue-description/$venueId');
  }

  Future<Result> getVenueAmenitiesFacilities({required int venueId}) {
    return _get(url: '$_baseUrl/venue-amenities-facilities/$venueId');
  }

  Future<Result> getAvailableCourts({
    required int venueId,
    required String selectDate,
    String? slotTime,
  }) {
    return _get(
      url: '$_baseUrl/available-courts',
      query: <String, dynamic>{
        'venue_id': venueId,
        'select_date': selectDate,
        if (slotTime != null && slotTime.trim().isNotEmpty)
          'slot_time': slotTime,
      },
    );
  }

  Future<Result> getVenueSlots({required int venueId, required String date}) {
    return _get(
      url: '$_baseUrl/venue-slots',
      query: <String, dynamic>{'venue_id': venueId, 'date': date},
    );
  }

  Future<Result> getVenueCourt() {
    return _get(url: '$_baseUrl/auth/get-venue-courts');
  }

  Future<Result> getVenueCourtByVenueId({required int venueId}) {
    return _get(url: '$_baseUrl/auth/get-court/$venueId');
  }

  Future<Result> getCourtDetails({required int courtId}) {
    return _get(url: '$_baseUrl/auth/court/$courtId');
  }

  Future<Result> getCourtSlots({required int courtId}) {
    return _get(
      url: '$_baseUrl/auth/vendor/onboarding/get-court-slots/$courtId',
    );
  }

  Future<Result> createCourtSlot({required Map<String, dynamic> data}) {
    return _post(
      url: '$_baseUrl/auth/vendor/onboarding/create-court-slot',
      data: data,
    );
  }

  Future<Result> updateCourtSlot({required Map<String, dynamic> data}) {
    return _post(
      url: '$_baseUrl/auth/vendor/onboarding/update-court-slot',
      data: data,
    );
  }

  Future<Result> deleteCourtSlot({required Map<String, dynamic> data}) {
    return _post(
      url: '$_baseUrl/auth/vendor/onboarding/delete-court-slot',
      data: data,
    );
  }

  Future<Result> getPublicTemplates() {
    return _get(url: '$_baseUrl/auth/templates');
  }

  Future<Result> fetchVendorOnboardingFutsal({required int venueId}) {
    return _get(url: '$_baseUrl/auth/get-venue/$venueId');
  }

  Future<Result> submitVendorOnboardingFutsal({
    required Map<String, dynamic> data,
  }) {
    return _post(
      url: '$_baseUrl/auth/vendor/onboarding/store-venue',
      data: data,
    );
  }

  Future<Result> updateVendorOnboardingFutsal({
    required Map<String, dynamic> data,
  }) {
    return _post(
      url: '$_baseUrl/auth/vendor/onboarding/update-venue',
      data: data,
    );
  }

  Future<Result> submitVendorOnboardingCourt({
    required Map<String, dynamic> data,
  }) {
    return _post(
      url: '$_baseUrl/auth/vendor/onboarding/store-court',
      data: data,
    );
  }

  Future<Result> updateVendorOnboardingCourt({
    required Map<String, dynamic> data,
  }) {
    return _post(
      url: '$_baseUrl/auth/vendor/onboarding/update-court',
      data: data,
    );
  }

  Future<Result> deleteVendorOnboardingCourt({required int courtId}) {
    return _delete(
      url: '$_baseUrl/auth/vendor/onboarding/delete-court/$courtId',
    );
  }

  Future<Result> deleteVendorCourt({required Map<String, dynamic> data}) {
    return _post(
      url: '$_baseUrl/auth/vendor/onboarding/delete-court',
      data: data,
    );
  }

  Future<Result> getMyBookings() {
    return _get(url: '$_baseUrl/bookings/my-bookings');
  }

  Future<Result> getFutsalBookings() {
    return _get(url: '$_baseUrl/bookings/futsal-bookings');
  }

  // ── Opponent-match teams ──

  Future<Result> getTeams() {
    return _get(url: '$_baseUrl/auth/teams');
  }

  Future<Result> getPlayerPositions() {
    return _get(url: '$_baseUrl/positions');
  }

  Future<Result> getOpponentLevels() {
    return _get(url: '$_baseUrl/opponent-levels');
  }

  Future<Result> getTeam({required int teamId}) {
    return _get(url: '$_baseUrl/auth/teams/$teamId');
  }

  Future<Result> createTeam({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/teams', data: data);
  }

  Future<Result> updateTeam({
    required int teamId,
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/auth/teams/$teamId/update', data: data);
  }

  Future<Result> deleteTeam({required int teamId}) {
    return _delete(url: '$_baseUrl/auth/teams/$teamId');
  }

  Future<Result> addTeamMember({
    required int teamId,
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/auth/teams/$teamId/members', data: data);
  }

  Future<Result> updateTeamMember({
    required int teamId,
    required int memberId,
    required Map<String, dynamic> data,
  }) {
    return _post(
      url: '$_baseUrl/auth/teams/$teamId/members/$memberId/update',
      data: data,
    );
  }

  Future<Result> removeTeamMember({
    required int teamId,
    required int memberId,
  }) {
    return _delete(url: '$_baseUrl/auth/teams/$teamId/members/$memberId');
  }

  Future<Result> _get({required String url, Map<String, dynamic>? query}) {
    return _apiCallWrapper.makeRequest(
      url: url,
      token: AppSettings().tokenModel.accessToken,
      method: HttpVerb.get,
      query: query,
    );
  }

  Future<Result> _post({required String url, dynamic data}) {
    final dynamic requestData;
    if (data is Map<String, dynamic>) {
      requestData = AppUtils().cleanUnwantedMapValue(data);
    } else if (data is Map) {
      requestData = AppUtils().cleanUnwantedMapValue(
        Map<String, dynamic>.from(data),
      );
    } else {
      requestData = data;
    }

    return _apiCallWrapper.makeRequest(
      url: url,
      data: requestData,
      token: AppSettings().tokenModel.accessToken,
      method: HttpVerb.post,
    );
  }

  Future<Result> _delete({required String url}) {
    return _apiCallWrapper.makeRequest(
      url: url,
      token: AppSettings().tokenModel.accessToken,
      method: HttpVerb.delete,
    );
  }

  Future<Result> _put({required String url, dynamic data}) {
    final dynamic requestData;
    if (data is Map<String, dynamic>) {
      requestData = AppUtils().cleanUnwantedMapValue(data);
    } else if (data is Map) {
      requestData = AppUtils().cleanUnwantedMapValue(
        Map<String, dynamic>.from(data),
      );
    } else {
      requestData = data;
    }

    return _apiCallWrapper.makeRequest(
      url: url,
      data: requestData,
      token: AppSettings().tokenModel.accessToken,
      method: HttpVerb.put,
    );
  }
}
