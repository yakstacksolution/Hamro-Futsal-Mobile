import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/api/api_client/booking_type_payload.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/routers/deep_link_target.dart';
import 'package:hamro_futsal/core/routers/root_navigator_key.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/auth/data/repositories/authentication_repository_impl.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/pages/booking_overview_screen.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/presentation/pages/booking_details_page.dart';
import 'package:hamro_futsal/features/bookings/presentation/pages/manual_booking_page.dart';
import 'package:hamro_futsal/features/change_password/data/repositories/change_password_repository_impl.dart';
import 'package:hamro_futsal/features/change_password/domain/usecase/change_password_usecase.dart';
import 'package:hamro_futsal/features/change_password/presentation/bloc/change_password_bloc/change_password_bloc.dart';
import 'package:hamro_futsal/features/change_password/presentation/pages/change_password_page.dart';
import 'package:hamro_futsal/features/courts/presentation/pages/venue_courts_list_page_widget.dart';
import 'package:hamro_futsal/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_futsal/features/courts_details/presentation/page/court_location_map_page.dart';
import 'package:hamro_futsal/features/account/presentation/pages/account_screen.dart';
import 'package:hamro_futsal/features/expenses/presentation/pages/expenses_screen.dart';
import 'package:hamro_futsal/features/coupons/data/repositories/coupon_repository_impl.dart';
import 'package:hamro_futsal/features/coupons/domain/usecase/apply_coupon_use_case.dart';
import 'package:hamro_futsal/features/coupons/domain/usecase/get_active_coupons_use_case.dart';
import 'package:hamro_futsal/features/coupons/presentation/bloc/coupon_bloc.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_checkout_route_args.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/slots_selection_route_args.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/view/booking_checkout_page.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/view/slots_selection_page.dart';
import 'package:hamro_futsal/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/booking_hold_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/check_recurring_availability_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/create_booking_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/get_available_courts_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/get_court_payment_qr_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/get_venue_slots_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/bloc/booking_hold/booking_hold_bloc.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/bloc/create_booking/create_booking_bloc.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/bloc/payment_qr/payment_qr_bloc.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/bloc/slots_selection/slots_selection_bloc.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/pages/opponent_match_screen.dart';
import 'package:hamro_futsal/features/profile/presentation/pages/about_app_page.dart';
import 'package:hamro_futsal/features/profile/presentation/pages/feedback_details_page.dart';
import 'package:hamro_futsal/features/profile/presentation/pages/feedback_page.dart';
import 'package:hamro_futsal/features/profile/presentation/pages/my_feedback_page.dart';
import 'package:hamro_futsal/features/profile/presentation/pages/settings_page.dart';
import 'package:hamro_futsal/features/rewards/presentation/pages/reward_history_page.dart';
import 'package:hamro_futsal/features/rewards/presentation/pages/rewards_page.dart';
import 'package:hamro_futsal/features/products/presentation/pages/products_screen.dart';
import 'package:hamro_futsal/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_futsal/features/public/presentation/pages/venue_filter_page.dart';
import 'package:hamro_futsal/features/auth/presentation/forgot_password_screen.dart';
import 'package:hamro_futsal/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_futsal/features/auth/presentation/create_new_password_screen.dart';
import 'package:hamro_futsal/features/auth/presentation/login_screen.dart';
import 'package:hamro_futsal/features/auth/presentation/otp_verification_screen.dart';
import 'package:hamro_futsal/features/auth/presentation/register_screen.dart';
import 'package:hamro_futsal/features/auth/domain/usecase/authentication_usecase.dart';
import 'package:hamro_futsal/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_futsal/features/notifications/presentation/pages/notifications_page.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/view/futsal_details_page_view.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_public_templates_use_case.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_futsal/features/public/presentation/pages/help_faq_page.dart';
import 'package:hamro_futsal/features/public/presentation/pages/venue_link_page.dart';
import 'package:hamro_futsal/features/transactions/domain/model/booking_transaction.dart';
import 'package:hamro_futsal/features/transactions/presentation/pages/transaction_history_page.dart';
import 'package:hamro_futsal/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hamro_futsal/features/profile/data/model/profile_model.dart';
import 'package:hamro_futsal/features/profile/domain/usecase/profile_usecase.dart';
import 'package:hamro_futsal/features/profile/presentation/pages/profile_page.dart';
import 'package:hamro_futsal/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_futsal/features/profile/presentation/widgets/profile_details_page.dart';
import 'package:hamro_futsal/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_futsal/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_futsal/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_futsal/features/vendor/presentation/pages/stepper_logic_screen.dart';

class AppRouters {
  AppRouters._();

  /// The active [GoRouter], exposed so navigation triggered from outside the
  /// widget tree (e.g. FCM notification taps) can push named routes.
  static GoRouter? instance;

  /// Where "home" is for this session — the dashboard once signed in, the
  /// login screen otherwise. Deep-link recovery goes here rather than to a
  /// hard-coded route, so a shared link never drops a signed-out user into a
  /// screen they cannot use.
  static String startLocation = AppRouterParams.dashboard.path;

  /// The link the app was launched with, once it has been turned into the
  /// router's initial location. [DeepLinkService] compares against it so a
  /// cold-start link is not opened twice — once by the router and once by
  /// `AppLinks.getInitialLink`.
  static DeepLinkTarget? consumedLaunchTarget;

  static GoRouter router(
    String initialLocation, {
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) {
    startLocation = initialLocation;

    // A cold start from a shared link arrives as the platform's initial route,
    // which go_router would otherwise try to match before any of this app's
    // paths — the "no routes for location" screen people were seeing. It is
    // recognised here and opened as the venue-link route instead.
    final String platformRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    final DeepLinkTarget? launchTarget = DeepLinkTarget.parseLocation(
      platformRoute,
    );
    consumedLaunchTarget = launchTarget;

    final String effectiveInitialLocation = switch (launchTarget) {
      VenueDeepLink(location: final String location) => location,
      _ => initialLocation,
    };

    final GoRouter router = GoRouter(
      navigatorKey: RootNavigatorKey.key,
      initialLocation: effectiveInitialLocation,
      observers: observers,
      // Every signed-in screen lives under /dashboard. Guarding the whole
      // subtree here means a notification tap, a shared link or a stale
      // location can never build a screen that would fire authenticated
      // requests without a session — those come back 401 and nothing else.
      redirect: (BuildContext context, GoRouterState state) {
        final String location = state.location.split('?').first;
        if (!location.startsWith(AppRouterParams.dashboard.path)) return null;
        if (AppSettings().hasSession) return null;
        return AppRouterParams.login.path;
      },
      // Nothing the app owns should end on go_router's default error screen:
      // an unknown location that still parses as one of our links opens it,
      // and anything else offers a way home.
      errorBuilder: (BuildContext context, GoRouterState state) {
        final DeepLinkTarget? target = DeepLinkTarget.parseLocation(
          state.location,
        );
        return switch (target) {
          VenueDeepLink(slug: final String? slug, id: final int? id) =>
            VenueLinkPage(slug: slug, venueId: id),
          _ => const _UnknownLocationPage(),
        };
      },
      routes: <RouteBase>[
        // Shared links. `/` is here too: a bare-domain link used to fall
        // through to the error screen.
        GoRoute(
          path: '/',
          redirect: (BuildContext context, GoRouterState state) =>
              startLocation,
        ),
        GoRoute(
          name: AppRouterParams.venueLink.name,
          path: AppRouterParams.venueLink.path,
          builder: _buildVenueLinkPage,
        ),
        GoRoute(
          name: AppRouterParams.venueLinkAlias.name,
          path: AppRouterParams.venueLinkAlias.path,
          builder: _buildVenueLinkPage,
        ),
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
          builder: (context, state) => BlocProvider<AuthenticationBloc>(
            create: (_) =>
                AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
            child: const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          name: AppRouterParams.createNewPassword.name,
          path: AppRouterParams.createNewPassword.path,
          builder: (context, state) {
            // `extra` is an {email, otp} map from the OTP screen; the bare
            // string and the query parameter are the direct-entry paths.
            final Object? extra = state.extra;
            final String email =
                (extra is Map
                    ? extra['email'] as String?
                    : extra is String
                    ? extra
                    : null) ??
                state.queryParameters['email'] ??
                '';
            final String? otp = extra is Map ? extra['otp'] as String? : null;

            // A reset cannot be submitted without the address the OTP went to,
            // so an entry with no email restarts the flow instead of showing a
            // form that can only fail.
            if (email.trim().isEmpty) {
              return BlocProvider<AuthenticationBloc>(
                create: (_) => AuthenticationBloc(
                  AuthUseCase(AuthenticationRepositoryImpl()),
                ),
                child: const ForgotPasswordScreen(),
              );
            }

            return BlocProvider<AuthenticationBloc>(
              create: (_) => AuthenticationBloc(
                AuthUseCase(AuthenticationRepositoryImpl()),
              ),
              child: CreateNewPasswordScreen(email: email.trim(), otp: otp),
            );
          },
        ),
        GoRoute(
          name: AppRouterParams.otpVerification.name,
          path: AppRouterParams.otpVerification.path,
          builder: (context, state) => BlocProvider<AuthenticationBloc>(
            create: (_) =>
                AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
            child: OtpVerificationScreen(
              // `extra` is a bare email string from the registration flow and
              // an {email, purpose} map from the forgot-password flow.
              email:
                  _otpExtra(state, 'email') ?? state.queryParameters['email'],
              purpose: _otpExtra(state, 'purpose') ?? OtpPurpose.registration,
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
          name: AppRouterParams.notifications.name,
          path: AppRouterParams.notifications.path,
          builder: (context, state) => const NotificationsPage(),
        ),

        GoRoute(
          name: AppRouterParams.transactions.name,
          path: AppRouterParams.transactions.path,
          builder: (context, state) => TransactionHistoryPage(
            perspective: state.queryParameters['futsal'] == 'true'
                ? TransactionPerspective.futsal
                : TransactionPerspective.player,
          ),
        ),

        GoRoute(
          name: AppRouterParams.helpFaq.name,
          path: AppRouterParams.helpFaq.path,
          builder: (context, state) => const HelpFaqPage(),
        ),

        GoRoute(
          name: AppRouterParams.feedback.name,
          path: AppRouterParams.feedback.path,
          builder: (context, state) => const FeedbackPage(),
        ),

        GoRoute(
          name: AppRouterParams.myFeedback.name,
          path: AppRouterParams.myFeedback.path,
          builder: (context, state) => const MyFeedbackPage(),
        ),

        GoRoute(
          name: AppRouterParams.feedbackDetails.name,
          path: AppRouterParams.feedbackDetails.path,
          builder: (context, state) =>
              FeedbackDetailsPage(feedbackId: (state.extra as String?) ?? ''),
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
          name: AppRouterParams.account.name,
          path: AppRouterParams.account.path,
          builder: (context, state) => const AccountScreen(),
        ),

        GoRoute(
          name: AppRouterParams.rewards.name,
          path: AppRouterParams.rewards.path,
          builder: (context, state) => const RewardsPage(),
        ),

        GoRoute(
          name: AppRouterParams.rewardHistory.name,
          path: AppRouterParams.rewardHistory.path,
          builder: (context, state) => RewardHistoryPage.standalone(),
        ),

        GoRoute(
          name: AppRouterParams.products.name,
          path: AppRouterParams.products.path,
          builder: (context, state) => const ProductsScreen(),
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
            appBar: const CustomAppBar(title: StringConstants.yourVenues),
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
            final SlotsSelectionRouteArgs args =
                SlotsSelectionRouteArgs.maybeFromExtra(state.extra) ??
                const SlotsSelectionRouteArgs(
                  court: _MissingCourtDetailModel(),
                );
            final CourtDetailModel court = args.court;
            if (court is _MissingCourtDetailModel) {
              return const _MissingSlotsSelectionArgsPage();
            }
            final FutsalDetailsRepositoryImpl repository =
                FutsalDetailsRepositoryImpl();
            return BlocProvider<SlotsSelectionBloc>(
              create: (_) =>
                  SlotsSelectionBloc(
                    GetAvailableCourtsUseCase(repository),
                    GetVenueSlotsUseCase(repository),
                    CheckRecurringAvailabilityUseCase(repository),
                  )..add(
                    InitializeSlotsSelectionEvent(
                      court: court,
                      initialDate: args.initialDate,
                      initialStartTime: args.initialStartTime,
                      // Walk-ins arrive here from the manual booking form.
                      bookingType: BookingTypePayload.of(
                        isManual: args.manualBooking != null,
                      ),
                    ),
                  ),
              child: SlotsSelectionPage(
                court: court,
                manualBooking: args.manualBooking,
                successAction: args.successAction,
              ),
            );
          },
        ),

        GoRoute(
          name: AppRouterParams.manualBooking.name,
          path: AppRouterParams.manualBooking.path,
          builder: (context, state) => const ManualBookingPage(),
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
            final BookingCheckoutRouteArgs? args =
                BookingCheckoutRouteArgs.maybeFromExtra(state.extra);
            if (args == null) return const _MissingBookingCheckoutArgsPage();
            final BookingDraft draft = args.draft;
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
              child: BookingCheckoutPage(
                draft: draft,
                successAction: args.successAction,
              ),
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
            final String? futsalSlug = state.queryParameters['futsalSlug']
                ?.trim();
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
                futsalSlug: futsalSlug == null || futsalSlug.isEmpty
                    ? null
                    : futsalSlug,
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

/// The venue-link route's page: the slug comes from the path, the id from
/// `?venue=` (`venue_id` is accepted too, since older links use it).
Widget _buildVenueLinkPage(BuildContext context, GoRouterState state) {
  final String? slug = state.pathParameters['slug']?.trim();
  final int? id = int.tryParse(
    (state.queryParameters['venue'] ?? state.queryParameters['venue_id'] ?? '')
        .trim(),
  );
  return VenueLinkPage(
    slug: slug == null || slug.isEmpty ? null : slug,
    venueId: id,
  );
}

/// Shown for a location the app does not own. Unlike go_router's own error
/// screen it says nothing about match phases and always offers a way out.
class _UnknownLocationPage extends StatelessWidget {
  const _UnknownLocationPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.explore_off_rounded,
                  size: AppDimens.sizeX36,
                  color: LightColor.hintTextColor,
                ),
                const SizedBox(height: AppDimens.sizeX12),
                Text(
                  StringConstants.pageNotFound,
                  textAlign: TextAlign.center,
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX8),
                Text(
                  StringConstants.thatLinkDoesNotOpenAnythingInTheApp,
                  textAlign: TextAlign.center,
                  style: FutsalTheme.getTextTheme(
                    context,
                  ).bodyTextSmall?.copyWith(color: LightColor.hintTextColor),
                ),
                const SizedBox(height: AppDimens.sizeX20),
                CustomButton(
                  text: StringConstants.browseVenues,
                  onPressed: () =>
                      GoRouter.of(context).go(AppRouters.startLocation),
                  minHeight: AppDimens.sizeX46,
                  minWidth: AppDimens.sizeX180,
                  borderRadius: AppDimens.radiusX10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingCourtDetailModel extends CourtDetailModel {
  const _MissingCourtDetailModel()
    : super(
        name: '',
        location: '',
        address: '',
        price: '',
        rating: 0,
        reviewCount: 0,
        images: const <String>[],
        isOpen: false,
        distance: '',
        features: const <String>[],
        description: '',
        hostedByName: '',
        hostedByAvatar: '',
        hostedSince: '',
        hostedCourts: 0,
        responseRate: 0,
        policies: const <String>[],
        rules: const <String>[],
        reviews: const <ReviewModel>[],
        openTime: '',
        closeTime: '',
        courtType: '',
        surfaceType: '',
        maxPlayers: 0,
      );
}

/// Slot selection depends on a [CourtDetailModel] carried in route extras.
/// Deep links, restored routes, or stale notification payloads may reach this
/// named route without that object; show a recoverable page instead of letting
/// a cast exception crash the app.
class _MissingSlotsSelectionArgsPage extends StatelessWidget {
  const _MissingSlotsSelectionArgsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.selectMatchDateTime),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.sports_soccer_rounded,
                  size: AppDimens.sizeX36,
                  color: LightColor.hintTextColor,
                ),
                const SizedBox(height: AppDimens.sizeX12),
                Text(
                  StringConstants.courtNotFound,
                  textAlign: TextAlign.center,
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX8),
                Text(
                  'Please choose a venue again to view available slots.',
                  textAlign: TextAlign.center,
                  style: FutsalTheme.getTextTheme(
                    context,
                  ).bodyTextSmall?.copyWith(color: LightColor.hintTextColor),
                ),
                const SizedBox(height: AppDimens.sizeX20),
                CustomButton(
                  text: StringConstants.browseVenues,
                  onPressed: () =>
                      GoRouter.of(context).go(AppRouters.startLocation),
                  minHeight: AppDimens.sizeX46,
                  minWidth: AppDimens.sizeX180,
                  borderRadius: AppDimens.radiusX10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when the checkout route is reached without a booking draft — a
/// restored deep link or a hot reload mid-funnel. There is nothing to check out
/// from here, so the user is sent back to pick a slot again.
class _MissingBookingCheckoutArgsPage extends StatelessWidget {
  const _MissingBookingCheckoutArgsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.checkout),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.receipt_long_rounded,
                  size: AppDimens.sizeX36,
                  color: LightColor.hintTextColor,
                ),
                const SizedBox(height: AppDimens.sizeX12),
                Text(
                  'This booking is no longer available.',
                  textAlign: TextAlign.center,
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX8),
                Text(
                  'Please pick your slot again to continue.',
                  textAlign: TextAlign.center,
                  style: FutsalTheme.getTextTheme(
                    context,
                  ).bodyTextSmall?.copyWith(color: LightColor.hintTextColor),
                ),
                const SizedBox(height: AppDimens.sizeX20),
                CustomButton(
                  text: StringConstants.browseVenues,
                  onPressed: () =>
                      GoRouter.of(context).go(AppRouters.startLocation),
                  minHeight: AppDimens.sizeX46,
                  minWidth: AppDimens.sizeX180,
                  borderRadius: AppDimens.radiusX10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reads [key] off the OTP route's `extra`, which is a bare email string from
/// the registration flow and an `{email, purpose}` map from the
/// forgot-password flow.
String? _otpExtra(GoRouterState state, String key) {
  final Object? extra = state.extra;
  if (extra is Map) {
    final Object? value = extra[key];
    return value is String && value.isNotEmpty ? value : null;
  }
  if (key == 'email' && extra is String && extra.isNotEmpty) {
    return extra;
  }
  return null;
}
