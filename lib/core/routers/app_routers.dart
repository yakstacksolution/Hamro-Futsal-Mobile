import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/features/auth/data/repositories/authentication_repository_impl.dart';
import 'package:hamro_footsall/features/auth/presentation/forgot_password_screen.dart';
import 'package:hamro_footsall/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_footsall/features/auth/presentation/login_screen.dart';
import 'package:hamro_footsall/features/auth/presentation/otp_verification_screen.dart';
import 'package:hamro_footsall/features/auth/presentation/register_screen.dart';
import 'package:hamro_footsall/features/auth/domain/usecase/authentication_usecase.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_packages_use_case.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_templates_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_packages/public_packages_bloc.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_footsall/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/domain/usecase/profile_usecase.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/profile_page.dart';
import 'package:hamro_footsall/features/courts/presentation/pages/create_courts_page.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_details_page.dart';
import 'package:hamro_footsall/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_footsall/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_footsall/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/pages/stepper_logic_screen.dart';

class AppRouters {
  AppRouters._();

  static GoRouter router(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        // GoRoute(
        //   name: AppRouterParams.splash.name,
        //   path: AppRouterParams.splash.path,
        //   builder: (context, state) => const SplashScreen(),
        // ),
        GoRoute(
          name: AppRouterParams.login.name,
          path: AppRouterParams.login.path,
          builder: (context, state) => BlocProvider<AuthenticationBloc>(
            create: (_) =>
                AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          name: AppRouterParams.register.name,
          path: AppRouterParams.register.path,
          builder: (context, state) => BlocProvider<AuthenticationBloc>(
            create: (_) =>
                AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          name: AppRouterParams.forgotPassword.name,
          path: AppRouterParams.forgotPassword.path,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          name: AppRouterParams.otpVerification.name,
          path: AppRouterParams.otpVerification.path,
          builder: (context, state) => BlocProvider<AuthenticationBloc>(
            create: (_) =>
                AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
            child: OtpVerificationScreen(
              email: (state.extra as String?) ?? state.queryParameters['email'],
            ),
          ),
        ),
        GoRoute(
          name: AppRouterParams.dashboard.name,
          path: AppRouterParams.dashboard.path,
          builder: (context, state) => BlocProvider(
            lazy: false,
            create: (context) =>
                ProfileBloc(ProfileUseCase(ProfileRepositoryImpl()))
                  ..add(const FetchProfileEvent()),
            child: const DashboardScreen(),
          ),
        ),

        GoRoute(
          name: AppRouterParams.createCourts.name,
          path: AppRouterParams.createCourts.path,
          builder: (context, state) => const CreateCourtsPage(),
        ),
        GoRoute(
          name: AppRouterParams.profile.name,
          path: AppRouterParams.profile.path,
          builder: (context, state) => BlocProvider(
            lazy: false,
            create: (context) =>
                ProfileBloc(ProfileUseCase(ProfileRepositoryImpl()))
                  ..add(const FetchProfileEvent()),
            child: const ProfilePage(),
          ),
          routes: <RouteBase>[
            GoRoute(
              name: AppRouterParams.profileDetails.name,
              path: 'details',
              builder: (context, state) =>
                  ProfileDetailsPage(user: state.extra as UserData?),
            ),
          ],
        ),

        GoRoute(
          name: AppRouterParams.courtDetails.name,
          path: AppRouterParams.courtDetails.path,
          builder: (context, state) => const CourtDetailPage(),
        ),
        // GoRoute(
        //   name: AppRouterParams.vendorOnboarding.name,
        //   path: AppRouterParams.vendorOnboarding.path,
        //   builder: (context, state) => const VendorOnboardingPage(),
        // ),
        GoRoute(
          name: AppRouterParams.vendorStepper.name,
          path: AppRouterParams.vendorStepper.path,
          builder: (context, state) {
            final publicRepository = PublicRepositoryImpl();
            final vendorOnboardingRepository = VendorOnboardingRepositoryImpl();
            final vendorOnboardingUseCase = VendorOnboardingUseCase(
              vendorOnboardingRepository,
            );
            return MultiBlocProvider(
              providers: <BlocProvider<dynamic>>[
                BlocProvider<PublicTemplatesBloc>(
                  lazy: false,
                  create: (_) => PublicTemplatesBloc(
                    GetPublicTemplatesUseCase(publicRepository),
                  )..add(FetchPublicTemplatesEvent()),
                ),
                BlocProvider<PublicPackagesBloc>(
                  lazy: false,
                  create: (_) => PublicPackagesBloc(
                    GetPublicPackagesUseCase(publicRepository),
                  )..add(FetchPublicPackagesEvent()),
                ),
                BlocProvider<VendorOnboardingCubit>(
                  lazy: false,
                  create: (_) => VendorOnboardingCubit(
                    const SharedPreferencesVendorDraftRepository(),
                    onboardingUseCase: vendorOnboardingUseCase,
                  ),
                ),
              ],
              child: const StepperLogicScreen(),
            );
          },
        ),
      ],
    );
  }
}
