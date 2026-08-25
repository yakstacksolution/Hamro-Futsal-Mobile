import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/api/api_client/booking_type_payload.dart';
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

  /// Permanently deletes the signed-in user's account.
  Future<Result> deleteAccount({required Map<String, dynamic> data}) {
    return _delete(url: '$_baseUrl/auth/account', data: data);
  }

  Future<Result> requestVendorUpgrade({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/vendor-request', data: data);
  }

  Future<Result> updateNotificationPreferences({
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/auth/notification-preferences', data: data);
  }

  Future<Result> updateFcmToken({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/auth/fcm-token', data: data);
  }

  Future<Result> getAppVersion({required Map<String, dynamic> query}) {
    return _get(url: '$_baseUrl/app-version', query: query);
  }

  // ── Notifications ──

  Future<Result> getNotifications({required String filter, int perPage = 20}) {
    return _get(
      url: '$_baseUrl/notifications',
      query: <String, dynamic>{'filter': filter, 'per_page': perPage},
    );
  }

  Future<Result> markAllNotificationsRead() {
    return _post(url: '$_baseUrl/notifications/read-all');
  }

  Future<Result> markNotificationRead({required String notificationId}) {
    return _patch(url: '$_baseUrl/notifications/$notificationId/read');
  }

  Future<Result> markNotificationUnread({required String notificationId}) {
    return _patch(url: '$_baseUrl/notifications/$notificationId/unread');
  }

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

  Future<Result> getFeedbackTypes() {
    return _get(url: '$_baseUrl/feedback-types');
  }

  Future<Result> getFeedbackCategories() {
    return _get(url: '$_baseUrl/feedback-categories');
  }

  Future<Result> submitFeedback({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/feedback', data: data);
  }

  Future<Result> getMyFeedback({int perPage = 15}) {
    return _get(
      url: '$_baseUrl/feedback',
      query: <String, dynamic>{'per_page': perPage},
    );
  }

  Future<Result> getFeedbackDetails({required String feedbackId}) {
    return _get(url: '$_baseUrl/feedback/$feedbackId');
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
    int perPage = kVenueListPerPage,
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

  Future<Result> getProducts({required int venueId, int perPage = 15}) {
    return _get(
      url: '$_baseUrl/products',
      query: <String, dynamic>{'venue_id': venueId, 'per_page': perPage},
    );
  }

  Future<Result> createProduct({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/products', data: data);
  }

  Future<Result> updateProduct({
    required int productId,
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/products/$productId', data: data);
  }

  Future<Result> deleteProduct({required int productId}) {
    return _delete(url: '$_baseUrl/products/$productId');
  }

  // Products available for sale at a given venue — used to add products to a
  // confirmed/completed booking as a cart.
  Future<Result> getVenueProducts({required int venueId}) {
    return _get(url: '$_baseUrl/venues/$venueId/products');
  }

  // Submits the selected products (cart) against a booking.
  Future<Result> addBookingProducts({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/bookings/$bookingId/extra-items', data: data);
  }

  // Marks a confirmed booking as completed.
  Future<Result> completeBooking({
    required int bookingId,
    bool confirm = true,
    String? paymentType,
    double? discount,
    double? partialAmount,
    List<Map<String, dynamic>>? extraItems,
  }) {
    final Map<String, dynamic> data = <String, dynamic>{
      // Required by the API — the request is rejected with 422 without it.
      'confirm': confirm,
      if (paymentType != null) 'payment_type': paymentType,
      'discount': discount ?? 0,
      if (partialAmount != null) 'partial_amount': partialAmount,
      if (extraItems != null && extraItems.isNotEmpty)
        'extra_items': extraItems,
    };
    return _post(url: '$_baseUrl/bookings/$bookingId/complete', data: data);
  }

  Future<Result> collectBookingDue({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/bookings/$bookingId/collect-due', data: data);
  }

  // Vendor ↔ super-admin financial account (balance, ledger, settlements).
  Future<Result> getSettlementAccount() {
    return _get(url: '$_baseUrl/auth/settlement-account');
  }

  Future<Result> getSettlementBreakdown() {
    return _get(url: '$_baseUrl/auth/settlement-breakdown');
  }

  /// Payment QRs the platform accepts a commission payment on.
  Future<Result> getQrCodes() {
    return _get(url: '$_baseUrl/auth/qr-codes');
  }

  Future<Result> getSettlementPreview({int? venueId}) {
    return _get(
      url: '$_baseUrl/auth/settlement-preview',
      query: venueId == null ? null : <String, dynamic>{'venue_id': venueId},
    );
  }

  /// The account ledger, paged. Backs the full "Account statement" screen;
  /// the account summary carries only a short preview of the same rows.
  Future<Result> getSettlementRecentActivity({Map<String, dynamic>? query}) {
    return _get(
      url: '$_baseUrl/auth/settlement-recent-activity',
      query: query ?? <String, dynamic>{'page': 1, 'per_page': 10},
    );
  }

  Future<Result> getSettlements({Map<String, dynamic>? query}) {
    return _get(
      url: '$_baseUrl/auth/settlements',
      query: query ?? <String, dynamic>{'page': 1, 'per_page': 20},
    );
  }

  Future<Result> createSettlement({required dynamic data}) {
    return _post(url: '$_baseUrl/auth/settlements', data: data);
  }

  Future<Result> getTransactionHistory({Map<String, dynamic>? query}) {
    return _get(
      url: '$_baseUrl/auth/transaction-history',
      query:
          query ??
          <String, dynamic>{'per_page': 20, 'direction': 'all', 'type': 'all'},
    );
  }

  Future<Result> getConversations({
    bool archived = false,
    required int page,
    required int perPage,
  }) {
    return _get(
      url: '$_baseUrl/conversations',
      query: <String, dynamic>{
        'archived': archived,
        'page': page,
        'per_page': perPage,
      },
    );
  }

  Future<Result> startDirectConversation({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/conversations/direct', data: data);
  }

  Future<Result> createGroupConversation({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/conversations/group', data: data);
  }

  Future<Result> addConversationParticipants({
    required int conversationId,
    required List<int> participantIds,
  }) {
    return _post(
      url: '$_baseUrl/conversations/$conversationId/participants',
      data: <String, dynamic>{'participant_ids': participantIds},
    );
  }

  /// Renaming a group. The server returns the updated conversation.
  Future<Result> updateConversationTitle({
    required int conversationId,
    required String title,
  }) {
    return _patch(
      url: '$_baseUrl/conversations/$conversationId/title',
      data: <String, dynamic>{'title': title},
    );
  }

  /// Leaving a group the signed-in user is a member of. The server drops them
  /// from `participants` and keeps the conversation for everyone else.
  Future<Result> leaveConversation({required int conversationId}) {
    return _post(url: '$_baseUrl/conversations/$conversationId/leave');
  }

  /// Answering a group invitation. `accept` joins the conversation; the
  /// decline endpoint drops the user from it.
  Future<Result> respondToConversationInvitation({
    required int conversationId,
    required bool accept,
  }) {
    return _post(
      url:
          '$_baseUrl/conversations/$conversationId/'
          '${accept ? 'accept' : 'decline'}',
    );
  }

  Future<Result> getConversationDetails({required int conversationId}) {
    return _get(url: '$_baseUrl/conversations/$conversationId');
  }

  Future<Result> getUserPresence({required int userId}) {
    return _get(url: '$_baseUrl/presence/$userId');
  }

  /// Public profile of a chat counterpart — name, address, gender and image.
  Future<Result> getMessageProfile({required int userId}) {
    return _get(url: '$_baseUrl/message-profile/$userId');
  }

  Future<Result> setPresence({required bool online}) {
    return _post(url: '$_baseUrl/presence/${online ? 'online' : 'offline'}');
  }

  Future<Result> sendPresenceHeartbeat({required String socketId}) {
    return _post(
      url: '$_baseUrl/presence/heartbeat',
      data: <String, dynamic>{'socket_id': socketId},
    );
  }

  Future<Result> getConversationMessages({
    required int conversationId,
    required int page,
    required int perPage,
  }) {
    return _get(
      url: '$_baseUrl/conversations/$conversationId/messages',
      query: <String, dynamic>{'page': page, 'per_page': perPage},
    );
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

  Future<Result> blockConversationParticipant({
    required int conversationId,
    required int userId,
    String? reason,
  }) {
    return _post(
      url: '$_baseUrl/conversations/$conversationId/block',
      data: <String, dynamic>{
        'blocked_user_id': userId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<Result> unblockConversationParticipant({
    required int conversationId,
    required int userId,
  }) {
    return _post(
      url: '$_baseUrl/conversations/$conversationId/unblock',
      data: <String, dynamic>{'blocked_user_id': userId},
    );
  }

  Future<Result> deleteChatMessage({required int messageId}) {
    return _delete(url: '$_baseUrl/messages/$messageId');
  }

  Future<Result> getVenueHostedBy({required int venueId}) {
    return _get(url: '$_baseUrl/hosted-by/$venueId');
  }

  /// One page of a venue's reviews, newest first as the server orders them.
  Future<Result> getVenueReviews({
    required int venueId,
    int page = 1,
    int perPage = 5,
  }) {
    return _get(
      url: '$_baseUrl/venues/$venueId/reviews',
      query: <String, dynamic>{'page': page, 'per_page': perPage},
    );
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
    String? slotStartTime,
    String? slotEndTime,
    String bookingType = BookingTypePayload.regular,
  }) {
    return _get(
      url: '$_baseUrl/available-courts',
      query: <String, dynamic>{
        'venue_id': venueId,
        'select_date': selectDate,
        if (slotStartTime != null && slotStartTime.trim().isNotEmpty)
          'slot_start_time': slotStartTime,
        if (slotEndTime != null && slotEndTime.trim().isNotEmpty)
          'slot_end_time': slotEndTime,
      },
      // Sent as a body so the server can widen availability for walk-ins
      // (vendor-entered bookings) versus regular player bookings.
      data: <String, dynamic>{'booking_type': bookingType},
    );
  }

  /// [bookingType] scopes what the server reports as bookable: a vendor's
  /// walk-in (`manual`) may see slots a player's own booking (`regular`)
  /// cannot.
  Future<Result> getVenueSlots({
    required int venueId,
    required String date,
    String bookingType = BookingTypePayload.regular,
  }) {
    return _get(
      url: '$_baseUrl/venue-slots',
      query: <String, dynamic>{
        'venue_id': venueId,
        'date': date,
        'type': bookingType,
      },
    );
  }

  Future<Result> getCourtPaymentQr({required int courtId}) {
    return _get(url: '$_baseUrl/courts/$courtId/payment-qr');
  }

  Future<Result> createBooking({required dynamic data}) {
    return _post(url: '$_baseUrl/bookings', data: data);
  }

  Future<Result> getRecurringAvailability({required dynamic data}) {
    return _post(url: '$_baseUrl/bookings/recurring-availability', data: data);
  }

  Future<Result> createBookingHold({required dynamic data}) {
    return _post(url: '$_baseUrl/booking-holds', data: data);
  }

  Future<Result> releaseBookingHold({required String holdToken}) {
    return _delete(url: '$_baseUrl/booking-holds/$holdToken');
  }

  Future<Result> getActiveCoupons() {
    return _get(url: '$_baseUrl/coupons/active');
  }

  Future<Result> applyCoupon({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/bookings/apply-coupon', data: data);
  }

  Future<Result> getRewards() {
    return _get(url: '$_baseUrl/customer/rewards');
  }

  Future<Result> getRewardHistory({int page = 1, int perPage = 20}) {
    return _get(
      url: '$_baseUrl/customer/rewards/history',
      query: <String, dynamic>{'page': page, 'per_page': perPage},
    );
  }

  Future<Result> generateRewardCoupon({Map<String, dynamic>? data}) {
    return _post(
      url: '$_baseUrl/customer/rewards/generate-coupon',
      data: data ?? <String, dynamic>{},
    );
  }

  Future<Result> getVenueCourt({required int page, required int perPage}) {
    return _get(
      url: '$_baseUrl/auth/get-venue-courts',
      query: <String, dynamic>{'page': page, 'per_page': perPage},
    );
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

  /// [status] is the endpoint's own filter — `all`, `pending`, `confirmed`,
  /// `completed`, `cancelled` or `rejected`. Filtering on the server rather
  /// than over the page in hand: a status filtered on-device only ever sees
  /// the rows already fetched, so it hid matches sitting on later pages.
  Future<Result> getMyBookings({
    required int page,
    required int perPage,
    String? status,
  }) {
    return _get(
      url: '$_baseUrl/bookings',
      query: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
  }

  Future<Result> getBookingDetails({required int bookingId}) {
    return _get(url: '$_baseUrl/bookings/$bookingId');
  }

  /// Same `status` filter as [getMyBookings].
  Future<Result> getFutsalBookings({
    required int page,
    required int perPage,
    String? status,
  }) {
    return _get(
      url: '$_baseUrl/futsal-bookings',
      query: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
  }

  /// Aggregated booking analytics. All filter params are optional — omit the
  /// [query] entirely to let the server apply its default window.
  Future<Result> getBookingOverview({Map<String, dynamic>? query}) {
    return _get(url: '$_baseUrl/booking-overview', query: query);
  }

  Future<Result> cancelBooking({required int bookingId}) {
    return _delete(url: '$_baseUrl/bookings/$bookingId');
  }

  /// Returns whether the booking is still within its allowed cancellation
  /// window.
  Future<Result> getBookingCancelBoundary({required int bookingId}) {
    return _get(url: '$_baseUrl/bookings/$bookingId/cancel-boundary');
  }

  /// The review this customer left on the booking, if any. A 404 here is a
  /// normal answer — it means "not reviewed yet", not a failure.
  Future<Result> getBookingReview({required int bookingId}) {
    return _get(url: '$_baseUrl/bookings/$bookingId/review');
  }

  /// Submits `{ rating, review }` for a completed booking.
  Future<Result> submitBookingReview({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/bookings/$bookingId/review', data: data);
  }

  // ── Payment proof verification ──

  Future<Result> verifyBookingPayment({
    required int bookingId,
    required int paymentId,
    required Map<String, dynamic> data,
  }) {
    return _patch(
      url: '$_baseUrl/bookings/$bookingId/payments/$paymentId/verify',
      data: data,
    );
  }

  Future<Result> rejectBookingPayment({
    required int bookingId,
    required int paymentId,
    required Map<String, dynamic> data,
  }) {
    return _patch(
      url: '$_baseUrl/bookings/$bookingId/payments/$paymentId/reject',
      data: data,
    );
  }

  // ── Booking accept / reject ──

  Future<Result> acceptBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/bookings/$bookingId/accept', data: data);
  }

  Future<Result> rejectBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/bookings/$bookingId/reject', data: data);
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

  // ── Opponent-match requests ──

  /// One opponent request by id. Authenticated (`/auth`) so the response is
  /// scoped to the caller — the unauthenticated variant does not answer for a
  /// request the caller is part of, which is what reading a request back after
  /// accepting it needs.
  Future<Result> getOpponentRequest({required String requestId}) {
    return _get(url: '$_baseUrl/auth/opponent-requests/$requestId');
  }

  Future<Result> createOpponentRequest({required Map<String, dynamic> data}) {
    return _post(url: '$_baseUrl/opponent-requests', data: data);
  }

  Future<Result> createOpponentMatchRequest({
    required Map<String, dynamic> data,
  }) {
    return _post(url: '$_baseUrl/auth/opponent-requests', data: data);
  }

  Future<Result> updateOpponentRequestMatch({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return _put(
      url: '$_baseUrl/auth/opponent-requests/$requestId/match',
      data: data,
    );
  }

  /// Loads one server-defined opponent-request tab. The API must always know
  /// which slice is requested; `tab=all` is not a valid replacement for the
  /// `my_requests`, `need_opponent`, and `settled` screens.
  Future<Result> getOpponentRequests({
    required String tab,
    int page = 1,
    int perPage = 15,
  }) {
    return _get(
      url: '$_baseUrl/auth/opponent-requests',
      query: <String, dynamic>{'tab': tab, 'page': page, 'per_page': perPage},
    );
  }

  Future<Result> getMyOpponentRequest({required String requestId}) {
    return _get(url: '$_baseUrl/auth/opponent-requests/$requestId');
  }

  Future<Result> saveOpponentRequestVenue({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return _put(
      url: '$_baseUrl/auth/opponent-requests/$requestId/venue',
      data: data,
    );
  }

  /// Sends the wizard's cost step (step three) — the split rule the accepting
  /// team sees before it pays. PUT, like the venue step: this replaces a
  /// section of a request that already exists.
  Future<Result> saveOpponentRequestCost({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return _put(
      url: '$_baseUrl/auth/opponent-requests/$requestId/cost',
      data: data,
    );
  }

  /// Publishes a draft request — the last wizard step, which flips it out of
  /// `draft` so eligible teams can see it. Only the optional `message` travels;
  /// every other section was saved by its own step.
  ///
  /// POST, unlike the `/venue` and `/cost` steps: publishing is an action on
  /// the request, not a section being replaced.
  Future<Result> publishOpponentRequest({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return _post(
      url: '$_baseUrl/auth/opponent-requests/$requestId/publish',
      data: data,
    );
  }

  /// Places a single-use accept hold and returns the authoritative advance
  /// quote + payment QR.
  Future<Result> createOpponentAcceptQuote({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return _post(
      url: '$_baseUrl/opponent-requests/$requestId/accept-quote',
      data: data,
    );
  }

  /// Finalizes the accept — multipart [data] carries the hold token, team and
  /// the `payment_proof` file.
  Future<Result> acceptOpponentRequest({
    required String requestId,
    required dynamic data,
  }) {
    return _post(
      url: '$_baseUrl/opponent-requests/$requestId/accept',
      data: data,
    );
  }

  /// The confirmed match behind a settled request: fixture, linked venue,
  /// agreed split and the chat room the server opened with it. Only answers
  /// once an opponent has been selected.
  Future<Result> getOpponentMatchDetails({required String requestId}) {
    return _get(
      url: '$_baseUrl/auth/opponent-requests/$requestId/match-details',
    );
  }

  Future<Result> getOpponentInvitations({
    required String requestId,
    Map<String, dynamic>? query,
  }) {
    return _get(
      url: '$_baseUrl/auth/opponent-requests/$requestId/invitations',
      query: query,
    );
  }

  Future<Result> createOpponentInvitation({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return _post(
      url: '$_baseUrl/auth/opponent-requests/$requestId/invitations',
      data: data,
    );
  }

  /// Requester confirms one of the teams that accepted: the match is created
  /// with that invitation and every other invitation on the request is
  /// rejected by the server.
  Future<Result> acceptOpponentInvitation({
    required String requestId,
    required String invitationId,
  }) {
    return _post(
      url:
          '$_baseUrl/auth/opponent-requests/$requestId/invitations/'
          '$invitationId/accept',
    );
  }

  Future<Result> declineOpponentRequest({required String requestId}) {
    return _post(url: '$_baseUrl/opponent-requests/$requestId/decline');
  }

  /// Requester approves the accepter's advance-payment proof.
  Future<Result> verifyOpponentPayment({required String requestId}) {
    return _patch(url: '$_baseUrl/opponent-requests/$requestId/payment/verify');
  }

  /// Requester rejects the proof — the request re-opens for other teams.
  Future<Result> rejectOpponentPayment({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return _patch(
      url: '$_baseUrl/opponent-requests/$requestId/payment/reject',
      data: data,
    );
  }

  /// Removes one of my own requests — drafts included. Owner-scoped, hence the
  /// `/auth` path.
  Future<Result> deleteOpponentRequest({required String requestId}) {
    return _delete(url: '$_baseUrl/auth/opponent-requests/$requestId');
  }

  Future<Result> _get({
    required String url,
    Map<String, dynamic>? query,
    dynamic data,
  }) {
    return _apiCallWrapper.makeRequest(
      url: url,
      token: AppSettings().tokenModel.accessToken,
      method: HttpVerb.get,
      query: query,
      data: data,
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

  Future<Result> _patch({required String url, dynamic data}) {
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
      method: HttpVerb.patch,
    );
  }

  Future<Result> _delete({required String url, dynamic data}) {
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
