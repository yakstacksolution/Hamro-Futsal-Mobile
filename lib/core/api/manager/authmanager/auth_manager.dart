import 'package:hamro_footsall/core/api/api_client/api_call_wrapper.dart';
import 'package:hamro_footsall/core/api/api_client/api_client.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/api/api_client/booking_type_payload.dart';
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

  Future<Result> deleteAccount(Map<String, dynamic> data) async {
    return await _apiClient.deleteAccount(data: data);
  }

  Future<Result> requestVendorUpgrade(Map<String, dynamic> data) async {
    return await _apiClient.requestVendorUpgrade(data: data);
  }

  Future<Result> updateNotificationPreferences(
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.updateNotificationPreferences(data: data);
  }

  Future<Result> updateFcmToken(Map<String, dynamic> data) async {
    return await _apiClient.updateFcmToken(data: data);
  }

  Future<Result> getAppVersion(Map<String, dynamic> query) async {
    return await _apiClient.getAppVersion(query: query);
  }

  Future<Result> getNotifications(String filter, int perPage) async {
    return await _apiClient.getNotifications(filter: filter, perPage: perPage);
  }

  Future<Result> markAllNotificationsRead() async {
    return await _apiClient.markAllNotificationsRead();
  }

  Future<Result> markNotificationRead(String notificationId) async {
    return await _apiClient.markNotificationRead(
      notificationId: notificationId,
    );
  }

  Future<Result> markNotificationUnread(String notificationId) async {
    return await _apiClient.markNotificationUnread(
      notificationId: notificationId,
    );
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

  Future<Result> getFeedbackTypes() async {
    return await _apiClient.getFeedbackTypes();
  }

  Future<Result> getFeedbackCategories() async {
    return await _apiClient.getFeedbackCategories();
  }

  Future<Result> submitFeedback(Map<String, dynamic> data) async {
    return await _apiClient.submitFeedback(data: data);
  }

  Future<Result> getMyFeedback({int perPage = 15}) async {
    return await _apiClient.getMyFeedback(perPage: perPage);
  }

  Future<Result> getFeedbackDetails(String feedbackId) async {
    return await _apiClient.getFeedbackDetails(feedbackId: feedbackId);
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

  Future<Result> getProducts({required int venueId, int perPage = 15}) async {
    return await _apiClient.getProducts(venueId: venueId, perPage: perPage);
  }

  Future<Result> createProduct(Map<String, dynamic> data) async {
    return await _apiClient.createProduct(data: data);
  }

  Future<Result> updateProduct({
    required int productId,
    required Map<String, dynamic> data,
  }) async {
    return await _apiClient.updateProduct(productId: productId, data: data);
  }

  Future<Result> deleteProduct({required int productId}) async {
    return await _apiClient.deleteProduct(productId: productId);
  }

  Future<Result> getVenueProducts({required int venueId}) async {
    return await _apiClient.getVenueProducts(venueId: venueId);
  }

  Future<Result> addBookingProducts({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    return await _apiClient.addBookingProducts(
      bookingId: bookingId,
      data: data,
    );
  }

  Future<Result> completeBooking({
    required int bookingId,
    bool confirm = true,
    String? paymentType,
    double? discount,
    double? partialAmount,
    List<Map<String, dynamic>>? extraItems,
  }) async {
    return await _apiClient.completeBooking(
      bookingId: bookingId,
      confirm: confirm,
      paymentType: paymentType,
      discount: discount,
      partialAmount: partialAmount,
      extraItems: extraItems,
    );
  }

  Future<Result> collectBookingDue({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    return await _apiClient.collectBookingDue(bookingId: bookingId, data: data);
  }

  Future<Result> getSettlementAccount() async {
    return await _apiClient.getSettlementAccount();
  }

  Future<Result> getSettlementBreakdown() async {
    return await _apiClient.getSettlementBreakdown();
  }

  Future<Result> getQrCodes() async {
    return await _apiClient.getQrCodes();
  }

  Future<Result> getSettlementPreview({int? venueId}) async {
    return await _apiClient.getSettlementPreview(venueId: venueId);
  }

  Future<Result> getSettlementRecentActivity({
    Map<String, dynamic>? query,
  }) async {
    return await _apiClient.getSettlementRecentActivity(query: query);
  }

  Future<Result> getSettlements({Map<String, dynamic>? query}) async {
    return await _apiClient.getSettlements(query: query);
  }

  Future<Result> createSettlement(dynamic data) async {
    return await _apiClient.createSettlement(data: data);
  }

  Future<Result> getTransactionHistory({Map<String, dynamic>? query}) async {
    return await _apiClient.getTransactionHistory(query: query);
  }

  Future<Result> getConversations({
    bool archived = false,
    required int page,
    required int perPage,
  }) async {
    return await _apiClient.getConversations(
      archived: archived,
      page: page,
      perPage: perPage,
    );
  }

  Future<Result> startDirectConversation(Map<String, dynamic> data) async {
    return await _apiClient.startDirectConversation(data: data);
  }

  Future<Result> createGroupConversation(Map<String, dynamic> data) async {
    return await _apiClient.createGroupConversation(data: data);
  }

  Future<Result> updateConversationTitle(
    int conversationId,
    String title,
  ) async {
    return await _apiClient.updateConversationTitle(
      conversationId: conversationId,
      title: title,
    );
  }

  Future<Result> leaveConversation(int conversationId) async {
    return await _apiClient.leaveConversation(conversationId: conversationId);
  }

  Future<Result> addConversationParticipants(
    int conversationId,
    List<int> participantIds,
  ) async {
    return await _apiClient.addConversationParticipants(
      conversationId: conversationId,
      participantIds: participantIds,
    );
  }

  Future<Result> respondToConversationInvitation(
    int conversationId,
    bool accept,
  ) async {
    return await _apiClient.respondToConversationInvitation(
      conversationId: conversationId,
      accept: accept,
    );
  }

  Future<Result> getConversationDetails(int conversationId) async {
    return await _apiClient.getConversationDetails(
      conversationId: conversationId,
    );
  }

  Future<Result> getUserPresence(int userId) async {
    return await _apiClient.getUserPresence(userId: userId);
  }

  Future<Result> getMessageProfile(int userId) async {
    return await _apiClient.getMessageProfile(userId: userId);
  }

  Future<Result> setPresence(bool online) async {
    return await _apiClient.setPresence(online: online);
  }

  Future<Result> sendPresenceHeartbeat(String socketId) async {
    return await _apiClient.sendPresenceHeartbeat(socketId: socketId);
  }

  Future<Result> getConversationMessages(
    int conversationId, {
    required int page,
    required int perPage,
  }) async {
    return await _apiClient.getConversationMessages(
      conversationId: conversationId,
      page: page,
      perPage: perPage,
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

  Future<Result> blockConversationParticipant(
    int conversationId,
    int userId, {
    String? reason,
  }) async {
    return await _apiClient.blockConversationParticipant(
      conversationId: conversationId,
      userId: userId,
      reason: reason,
    );
  }

  Future<Result> unblockConversationParticipant(
    int conversationId,
    int userId,
  ) async {
    return await _apiClient.unblockConversationParticipant(
      conversationId: conversationId,
      userId: userId,
    );
  }

  Future<Result> deleteChatMessage(int messageId) async {
    return await _apiClient.deleteChatMessage(messageId: messageId);
  }

  Future<Result> getVenueHostedBy(int venueId) async {
    return await _apiClient.getVenueHostedBy(venueId: venueId);
  }

  Future<Result> getVenueReviews(
    int venueId, {
    int page = 1,
    int perPage = 5,
  }) async {
    return await _apiClient.getVenueReviews(
      venueId: venueId,
      page: page,
      perPage: perPage,
    );
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
    String? slotStartTime,
    String? slotEndTime,
    String bookingType = BookingTypePayload.regular,
  }) async {
    return await _apiClient.getAvailableCourts(
      venueId: venueId,
      selectDate: selectDate,
      slotStartTime: slotStartTime,
      slotEndTime: slotEndTime,
      bookingType: bookingType,
    );
  }

  Future<Result> getVenueSlots({
    required int venueId,
    required String date,
    String bookingType = BookingTypePayload.regular,
  }) async {
    return await _apiClient.getVenueSlots(
      venueId: venueId,
      date: date,
      bookingType: bookingType,
    );
  }

  Future<Result> getCourtPaymentQr({required int courtId}) async {
    return await _apiClient.getCourtPaymentQr(courtId: courtId);
  }

  Future<Result> createBooking(dynamic data) async {
    return await _apiClient.createBooking(data: data);
  }

  Future<Result> getRecurringAvailability(dynamic data) async {
    return await _apiClient.getRecurringAvailability(data: data);
  }

  Future<Result> createBookingHold(dynamic data) async {
    return await _apiClient.createBookingHold(data: data);
  }

  Future<Result> releaseBookingHold(String holdToken) async {
    return await _apiClient.releaseBookingHold(holdToken: holdToken);
  }

  Future<Result> getActiveCoupons() async {
    return await _apiClient.getActiveCoupons();
  }

  Future<Result> applyCoupon({required Map<String, dynamic> data}) async {
    return await _apiClient.applyCoupon(data: data);
  }

  Future<Result> getRewards() async {
    return await _apiClient.getRewards();
  }

  Future<Result> getRewardHistory({int page = 1, int perPage = 20}) async {
    return await _apiClient.getRewardHistory(page: page, perPage: perPage);
  }

  Future<Result> generateRewardCoupon({Map<String, dynamic>? data}) async {
    return await _apiClient.generateRewardCoupon(data: data);
  }

  Future<Result> getVenueCourt({
    required int page,
    required int perPage,
  }) async {
    return await _apiClient.getVenueCourt(page: page, perPage: perPage);
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

  Future<Result> getMyBookings({
    required int page,
    required int perPage,
    String? status,
  }) async {
    return await _apiClient.getMyBookings(
      page: page,
      perPage: perPage,
      status: status,
    );
  }

  Future<Result> getBookingDetails(int bookingId) async {
    return await _apiClient.getBookingDetails(bookingId: bookingId);
  }

  Future<Result> getFutsalBookings({
    required int page,
    required int perPage,
    String? status,
  }) async {
    return await _apiClient.getFutsalBookings(
      page: page,
      perPage: perPage,
      status: status,
    );
  }

  Future<Result> getBookingOverview({Map<String, dynamic>? query}) async {
    return await _apiClient.getBookingOverview(query: query);
  }

  Future<Result> cancelBooking(int bookingId) async {
    return await _apiClient.cancelBooking(bookingId: bookingId);
  }

  Future<Result> getBookingReview(int bookingId) async {
    return await _apiClient.getBookingReview(bookingId: bookingId);
  }

  Future<Result> submitBookingReview(
    int bookingId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.submitBookingReview(
      bookingId: bookingId,
      data: data,
    );
  }

  Future<Result> getBookingCancelBoundary(int bookingId) async {
    return await _apiClient.getBookingCancelBoundary(bookingId: bookingId);
  }

  Future<Result> verifyBookingPayment(
    int bookingId,
    int paymentId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.verifyBookingPayment(
      bookingId: bookingId,
      paymentId: paymentId,
      data: data,
    );
  }

  Future<Result> rejectBookingPayment(
    int bookingId,
    int paymentId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.rejectBookingPayment(
      bookingId: bookingId,
      paymentId: paymentId,
      data: data,
    );
  }

  Future<Result> acceptBooking(int bookingId, Map<String, dynamic> data) async {
    return await _apiClient.acceptBooking(bookingId: bookingId, data: data);
  }

  Future<Result> rejectBooking(int bookingId, Map<String, dynamic> data) async {
    return await _apiClient.rejectBooking(bookingId: bookingId, data: data);
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

  Future<Result> getOpponentRequest(String requestId) async {
    return await _apiClient.getOpponentRequest(requestId: requestId);
  }

  Future<Result> createOpponentRequest(Map<String, dynamic> data) async {
    return await _apiClient.createOpponentRequest(data: data);
  }

  Future<Result> createOpponentMatchRequest(Map<String, dynamic> data) async {
    return await _apiClient.createOpponentMatchRequest(data: data);
  }

  Future<Result> updateOpponentRequestMatch(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.updateOpponentRequestMatch(
      requestId: requestId,
      data: data,
    );
  }

  Future<Result> getOpponentRequests({
    required String tab,
    int page = 1,
    int perPage = 15,
  }) async {
    return await _apiClient.getOpponentRequests(
      tab: tab,
      page: page,
      perPage: perPage,
    );
  }

  Future<Result> saveOpponentRequestCost(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.saveOpponentRequestCost(
      requestId: requestId,
      data: data,
    );
  }

  Future<Result> publishOpponentRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.publishOpponentRequest(
      requestId: requestId,
      data: data,
    );
  }

  Future<Result> getMyOpponentRequest(String requestId) async {
    return await _apiClient.getMyOpponentRequest(requestId: requestId);
  }

  Future<Result> saveOpponentRequestVenue(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.saveOpponentRequestVenue(
      requestId: requestId,
      data: data,
    );
  }

  Future<Result> createOpponentAcceptQuote(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.createOpponentAcceptQuote(
      requestId: requestId,
      data: data,
    );
  }

  Future<Result> acceptOpponentRequest(String requestId, dynamic data) async {
    return await _apiClient.acceptOpponentRequest(
      requestId: requestId,
      data: data,
    );
  }

  Future<Result> getOpponentMatchDetails(String requestId) async {
    return await _apiClient.getOpponentMatchDetails(requestId: requestId);
  }

  Future<Result> getOpponentInvitations(
    String requestId, {
    Map<String, dynamic>? query,
  }) async {
    return await _apiClient.getOpponentInvitations(
      requestId: requestId,
      query: query,
    );
  }

  Future<Result> createOpponentInvitation(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.createOpponentInvitation(
      requestId: requestId,
      data: data,
    );
  }

  Future<Result> acceptOpponentInvitation(
    String requestId,
    String invitationId,
  ) async {
    return await _apiClient.acceptOpponentInvitation(
      requestId: requestId,
      invitationId: invitationId,
    );
  }

  Future<Result> declineOpponentRequest(String requestId) async {
    return await _apiClient.declineOpponentRequest(requestId: requestId);
  }

  Future<Result> verifyOpponentPayment(String requestId) async {
    return await _apiClient.verifyOpponentPayment(requestId: requestId);
  }

  Future<Result> rejectOpponentPayment(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.rejectOpponentPayment(
      requestId: requestId,
      data: data,
    );
  }

  Future<Result> deleteOpponentRequest(String requestId) async {
    return await _apiClient.deleteOpponentRequest(requestId: requestId);
  }
}
