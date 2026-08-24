class AppRouterParams {
  AppRouterParams._();

  static const RouteConfig splash = RouteConfig(name: 'splash', path: '/');

  static const RouteConfig login = RouteConfig(name: 'login', path: '/login');

  static const RouteConfig register = RouteConfig(
    name: 'register',
    path: '/register',
  );

  static const RouteConfig forgotPassword = RouteConfig(
    name: 'forgotPassword',
    path: '/forgot-password',
  );

  static const RouteConfig otpVerification = RouteConfig(
    name: 'otpVerification',
    path: '/otp-verification',
  );

  static const RouteConfig dashboard = RouteConfig(
    name: 'dashboard',
    path: '/dashboard',
  );

  static const RouteConfig notifications = RouteConfig(
    name: 'notifications',
    path: '/dashboard/notifications',
  );

  static const RouteConfig transactions = RouteConfig(
    name: 'transactions',
    path: '/dashboard/transactions',
  );

  static const RouteConfig createCourts = RouteConfig(
    name: 'createCourts',
    path: '/dashboard/create-courts',
  );

  static const RouteConfig profile = RouteConfig(
    name: 'profile',
    path: '/dashboard/profile',
  );
  static const RouteConfig profileDetails = RouteConfig(
    name: 'profileDetails',
    path: '/dashboard/profile/details',
  );

  static const RouteConfig courtDetails = RouteConfig(
    name: 'courtDetails',
    path: 'court-details',
  );

  static const RouteConfig vendorOnboarding = RouteConfig(
    name: 'vendorOnboarding',
    path: '/dashboard/vendor-onboarding',
  );

  static const RouteConfig vendorStepper = RouteConfig(
    name: 'vendorStepper',
    path: '/dashboard/vendor-stepper',
  );

  static const RouteConfig helpFaq = RouteConfig(
    name: 'helpFaq',
    path: '/dashboard/help-faq',
  );

  static const RouteConfig feedback = RouteConfig(
    name: 'feedback',
    path: '/dashboard/feedback',
  );

  static const RouteConfig myFeedback = RouteConfig(
    name: 'myFeedback',
    path: '/dashboard/my-feedback',
  );

  static const RouteConfig feedbackDetails = RouteConfig(
    name: 'feedbackDetails',
    path: '/dashboard/my-feedback/details',
  );

  static const RouteConfig settings = RouteConfig(
    name: 'settings',
    path: '/dashboard/settings',
  );

  static const RouteConfig changePassword = RouteConfig(
    name: 'changePassword',
    path: '/dashboard/settings/change-password',
  );

  static const RouteConfig aboutApp = RouteConfig(
    name: 'aboutApp',
    path: '/dashboard/about-app',
  );

  static const RouteConfig opponentMatch = RouteConfig(
    name: 'opponentMatch',
    path: '/dashboard/opponent-match',
  );

  static const RouteConfig bookingOverview = RouteConfig(
    name: 'bookingOverview',
    path: '/dashboard/booking-overview',
  );

  static const RouteConfig account = RouteConfig(
    name: 'account',
    path: '/dashboard/account',
  );

  static const RouteConfig products = RouteConfig(
    name: 'products',
    path: '/dashboard/products',
  );

  static const RouteConfig expenses = RouteConfig(
    name: 'expenses',
    path: '/dashboard/expenses',
  );

  static const RouteConfig yourVenues = RouteConfig(
    name: 'yourVenues',
    path: '/dashboard/your-venues',
  );

  static const RouteConfig bookingDetails = RouteConfig(
    name: 'bookingDetails',
    path: '/dashboard/booking-details',
  );

  static const RouteConfig courtLocationMap = RouteConfig(
    name: 'courtLocationMap',
    path: '/dashboard/court-location-map',
  );

  static const RouteConfig slotsSelection = RouteConfig(
    name: 'slotsSelection',
    path: '/dashboard/slots-selection',
  );

  static const RouteConfig manualBooking = RouteConfig(
    name: 'manualBooking',
    path: '/dashboard/manual-booking',
  );

  static const RouteConfig venueFilter = RouteConfig(
    name: 'venueFilter',
    path: '/dashboard/venue-filter',
  );

  static const RouteConfig rewards = RouteConfig(
    name: 'rewards',
    path: '/dashboard/rewards',
  );

  static const RouteConfig rewardHistory = RouteConfig(
    name: 'rewardHistory',
    path: '/dashboard/rewards/history',
  );

  static const RouteConfig bookingCheckout = RouteConfig(
    name: 'bookingCheckout',
    path: '/dashboard/booking-checkout',
  );
}

class RouteConfig {
  const RouteConfig({required this.name, required this.path});

  final String name;
  final String path;
}
