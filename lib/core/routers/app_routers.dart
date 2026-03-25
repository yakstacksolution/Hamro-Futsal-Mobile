import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/features/auth/presentation/forgot_password_screen.dart';
import 'package:hamro_footsall/features/auth/presentation/login_screen.dart';
import 'package:hamro_footsall/features/auth/presentation/otp_verification_screen.dart';
import 'package:hamro_footsall/features/auth/presentation/register_screen.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/profile_page.dart';
import 'package:hamro_footsall/features/courts/presentation/pages/create_courts_page.dart';
import 'package:hamro_footsall/features/splash/presentation/splash_screen.dart';
import 'package:hamro_footsall/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/pages/stepper_logic_screen.dart';
import 'package:hamro_footsall/features/vendor/presentation/pages/vendor_onboarding_page.dart';

class AppRouters {
  AppRouters._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRouterParams.splash.path,
    routes: <RouteBase>[
      GoRoute(
        name: AppRouterParams.splash.name,
        path: AppRouterParams.splash.path,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRouterParams.login.name,
        path: AppRouterParams.login.path,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: AppRouterParams.register.name,
        path: AppRouterParams.register.path,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: AppRouterParams.forgotPassword.name,
        path: AppRouterParams.forgotPassword.path,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: AppRouterParams.otpVerification.name,
        path: AppRouterParams.otpVerification.path,
        builder: (context, state) =>
            OtpVerificationScreen(email: state.extra as String?),
      ),
      GoRoute(
        name: AppRouterParams.dashboard.name,
        path: AppRouterParams.dashboard.path,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        name: AppRouterParams.createCourts.name,
        path: AppRouterParams.createCourts.path,
        builder: (context, state) => const CreateCourtsPage(),
      ),
      GoRoute(
        name: AppRouterParams.profile.name,
        path: AppRouterParams.profile.path,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRouterParams.courtDetails.path,
        builder: (context, state) => const CourtDetailPage(),
      ),
      GoRoute(
        name: AppRouterParams.vendorOnboarding.name,
        path: AppRouterParams.vendorOnboarding.path,
        builder: (context, state) => const VendorOnboardingPage(),
      ),
      GoRoute(
        name: AppRouterParams.vendorStepper.name,
        path: AppRouterParams.vendorStepper.path,
        builder: (context, state) => BlocProvider<VendorOnboardingCubit>(
          create: (_) => VendorOnboardingCubit(
            const SharedPreferencesVendorDraftRepository(),
          ),
          child: const StepperLogicScreen(),
        ),
      ),
    ],
  );
}
