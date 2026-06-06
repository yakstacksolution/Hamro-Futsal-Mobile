import 'package:flutter/material.dart';
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
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/view/futsal_details_page_view.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_templates_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_footsall/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/domain/usecase/profile_usecase.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/profile_page.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_details_page.dart';
import 'package:hamro_footsall/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_footsall/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_footsall/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/pages/stepper_logic_screen.dart';

class AppRouters {
  AppRouters._();

  static GoRouter router(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
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
          routes: [
            GoRoute(
              name: AppRouterParams.courtDetails.name,
              path: AppRouterParams.courtDetails.path,
              pageBuilder: (context, state) {
                PublicListingVenueModel publicListingVenueModel =
                    state.extra as PublicListingVenueModel;
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  transitionDuration: const Duration(milliseconds: 620),
                  reverseTransitionDuration: const Duration(milliseconds: 420),
                  child: FutsalDetailsPageView(
                    publicVenue: publicListingVenueModel,
                  ),
                  transitionsBuilder:
                      (
                        BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                        Widget child,
                      ) {
                        final Animation<double> primaryCurve = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutQuint,
                          reverseCurve: Curves.easeInCubic,
                        );
                        final Animation<double> contentCurve = CurvedAnimation(
                          parent: animation,
                          curve: const Interval(
                            0.12,
                            1,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                        return FadeTransition(
                          opacity: contentCurve,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.045),
                              end: Offset.zero,
                            ).animate(contentCurve),
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.985,
                                end: 1,
                              ).animate(primaryCurve),
                              child: child,
                            ),
                          ),
                        );
                      },
                );
              },
            ),
          ],
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
          name: AppRouterParams.vendorStepper.name,
          path: AppRouterParams.vendorStepper.path,
          builder: (context, state) {
            final int? futsalId = state.queryParameters['futsalId'] != null
                ? int.tryParse(state.queryParameters['futsalId']!)
                : null;
            final int? mainStep = state.queryParameters['mainStep'] != null
                ? int.tryParse(state.queryParameters['mainStep']!)
                : null;
            final int? subStep = state.queryParameters['subStep'] != null
                ? int.tryParse(state.queryParameters['subStep']!)
                : null;
            final publicRepository = PublicRepositoryImpl();
            final vendorOnboardingRepository = VendorOnboardingRepositoryImpl();
            final vendorOnboardingUseCase = VendorOnboardingUseCase(
              vendorOnboardingRepository,
            );
            return MultiBlocProvider(
              providers: <BlocProvider<dynamic>>[
                BlocProvider<PublicTemplatesBloc>(
                  create: (_) => PublicTemplatesBloc(
                    GetPublicTemplatesUseCase(publicRepository),
                  )..add(FetchPublicTemplatesEvent()),
                ),

                BlocProvider<VendorOnboardingCubit>(
                  create: (_) => VendorOnboardingCubit(
                    const EphemeralVendorDraftRepository(),
                    onboardingUseCase: vendorOnboardingUseCase,
                  ),
                ),
              ],
              child: StepperLogicScreen(
                futsalId: futsalId,
                mainStep: mainStep,
                subStep: subStep,
              ),
            );
          },
        ),
      ],
    );
  }
}
