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
    path: '/dashboard/court-details',
  );

  static const RouteConfig vendorOnboarding = RouteConfig(
    name: 'vendorOnboarding',
    path: '/dashboard/vendor-onboarding',
  );

  static const RouteConfig vendorStepper = RouteConfig(
    name: 'vendorStepper',
    path: '/dashboard/vendor-stepper',
  );
}

class RouteConfig {
  const RouteConfig({required this.name, required this.path});

  final String name;
  final String path;
}
