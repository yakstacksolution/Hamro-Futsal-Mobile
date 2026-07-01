import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/routers/root_navigator_key.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/features/auth/data/repositories/authentication_repository_impl.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/pages/booking_overview_screen.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/pages/booking_details_page.dart';
import 'package:hamro_footsall/features/change_password/data/repositories/change_password_repository_impl.dart';
import 'package:hamro_footsall/features/change_password/domain/usecase/change_password_usecase.dart';
import 'package:hamro_footsall/features/change_password/presentation/bloc/change_password_bloc/change_password_bloc.dart';
import 'package:hamro_footsall/features/change_password/presentation/pages/change_password_page.dart';
import 'package:hamro_footsall/features/courts/presentation/pages/venue_courts_list_page_widget.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_location_map_page.dart';
import 'package:hamro_footsall/features/expenses/presentation/pages/expenses_screen.dart';
import 'package:hamro_footsall/features/coupons/data/repositories/coupon_repository_impl.dart';
import 'package:hamro_footsall/features/coupons/domain/usecase/apply_coupon_use_case.dart';
import 'package:hamro_footsall/features/coupons/domain/usecase/get_active_coupons_use_case.dart';
import 'package:hamro_footsall/features/coupons/presentation/bloc/coupon_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/view/booking_checkout_page.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/view/slots_selection_page.dart';
import 'package:hamro_footsall/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/booking_hold_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/check_recurring_availability_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/create_booking_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_available_courts_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_court_payment_qr_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_venue_slots_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/booking_hold/booking_hold_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/create_booking/create_booking_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/payment_qr/payment_qr_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/slots_selection/slots_selection_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/pages/opponent_match_screen.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/about_app_page.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/settings_page.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_footsall/features/public/presentation/pages/venue_filter_page.dart';
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
import 'package:hamro_footsall/features/public/presentation/pages/help_faq_page.dart';
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

  /// The active [GoRouter], exposed so navigation triggered from outside the
  /// widget tree (e.g. FCM notification taps) can push named routes.
  static GoRouter? instance;

  static GoRouter router(
    String initialLocation, {
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) {
    final GoRouter router = GoRouter(
      navigatorKey: RootNavigatorKey.key,
      initialLocation: initialLocation,
      observers: observers,
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
          name: AppRouterParams.helpFaq.name,
          path: AppRouterParams.helpFaq.path,
          builder: (context, state) => const HelpFaqPage(),
        ),

        GoRoute(
          name: AppRouterParams.settings.name,
          path: AppRouterParams.settings.path,
          builder: (context, state) => const SettingsPage(),
        ),

        GoRoute(
          name: AppRouterParams.changePassword.name,
          path: AppRouterParams.changePassword.path,
          builder: (context, state) => BlocProvider<ChangePasswordBloc>(
            create: (_) => ChangePasswordBloc(
              ChangePasswordUseCase(ChangePasswordRepositoryImpl()),
            ),
            child: const ChangePasswordPage(),
          ),
        ),

        GoRoute(
          name: AppRouterParams.aboutApp.name,
          path: AppRouterParams.aboutApp.path,
          builder: (context, state) => const AboutAppPage(),
        ),

        GoRoute(
          name: AppRouterParams.opponentMatch.name,
          path: AppRouterParams.opponentMatch.path,
          builder: (context, state) => const OpponentMatchScreen(),
        ),

        GoRoute(
          name: AppRouterParams.bookingOverview.name,
          path: AppRouterParams.bookingOverview.path,
          builder: (context, state) => const BookingOverviewScreen(),
        ),

        GoRoute(
          name: AppRouterParams.expenses.name,
          path: AppRouterParams.expenses.path,
          builder: (context, state) => const ExpensesScreen(),
        ),

        GoRoute(
          name: AppRouterParams.yourVenues.name,
          path: AppRouterParams.yourVenues.path,
          builder: (context, state) => Scaffold(
            backgroundColor: LightColor.background,
            appBar: const CustomAppBar(title: 'Your Venues'),
            body: const SafeArea(top: false, child: VenueCourtsListPage()),
          ),
        ),

        GoRoute(
          name: AppRouterParams.bookingDetails.name,
          path: AppRouterParams.bookingDetails.path,
          builder: (context, state) => BookingDetailsPage(
            booking: state.extra as BookingModel,
            isFutsalView: state.queryParameters['futsal'] == 'true',
          ),
        ),

        GoRoute(
          name: AppRouterParams.courtLocationMap.name,
          path: AppRouterParams.courtLocationMap.path,
          builder: (context, state) => CourtLocationMapPage(
            latitude: double.parse(state.queryParameters['lat']!),
            longitude: double.parse(state.queryParameters['lng']!),
            venueName: state.queryParameters['name'],
            address: state.queryParameters['address'],
          ),
        ),

        GoRoute(
          name: AppRouterParams.slotsSelection.name,
          path: AppRouterParams.slotsSelection.path,
          builder: (context, state) {
            final CourtDetailModel court = state.extra as CourtDetailModel;
            final FutsalDetailsRepositoryImpl repository =
                FutsalDetailsRepositoryImpl();
            return BlocProvider<SlotsSelectionBloc>(
              create: (_) => SlotsSelectionBloc(
                GetAvailableCourtsUseCase(repository),
                GetVenueSlotsUseCase(repository),
                CheckRecurringAvailabilityUseCase(repository),
              )..add(InitializeSlotsSelectionEvent(court: court)),
              child: SlotsSelectionPage(court: court),
            );
          },
        ),

        GoRoute(
          name: AppRouterParams.venueFilter.name,
          path: AppRouterParams.venueFilter.path,
          builder: (context, state) => VenueFilterPage(
            initialFilter: (state.extra as VenueFilter?) ?? VenueFilter.empty,
          ),
        ),

        GoRoute(
          name: AppRouterParams.bookingCheckout.name,
          path: AppRouterParams.bookingCheckout.path,
          builder: (context, state) {
            final BookingDraft draft = state.extra as BookingDraft;
            final CouponRepositoryImpl couponRepository =
                CouponRepositoryImpl();
            final FutsalDetailsRepositoryImpl futsalRepository =
                FutsalDetailsRepositoryImpl();
            return MultiBlocProvider(
              providers: <BlocProvider>[
                BlocProvider<CouponBloc>(
                  create: (_) => CouponBloc(
                    GetActiveCouponsUseCase(couponRepository),
                    ApplyCouponUseCase(couponRepository),
                  )..add(const LoadActiveCouponsEvent()),
                ),
                BlocProvider<PaymentQrBloc>(
                  create: (_) {
                    final PaymentQrBloc bloc = PaymentQrBloc(
                      GetCourtPaymentQrUseCase(futsalRepository),
                    );
                    if (draft.courtId != null) {
                      bloc.add(LoadPaymentQrEvent(draft.courtId!));
                    }
                    return bloc;
                  },
                ),
                BlocProvider<CreateBookingBloc>(
                  create: (_) =>
                      CreateBookingBloc(CreateBookingUseCase(futsalRepository)),
                ),
                BlocProvider<BookingHoldBloc>(
                  create: (_) =>
                      BookingHoldBloc(BookingHoldUseCase(futsalRepository)),
                ),
              ],
              child: BookingCheckoutPage(draft: draft),
            );
          },
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
    instance = router;
    return router;
  }
}
