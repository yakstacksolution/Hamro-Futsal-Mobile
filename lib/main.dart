import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/core/helper/fcm_helper.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/routers/app_routers.dart';
import 'package:hamro_footsall/core/routers/notification_redirection.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/theme/app_theme_controller.dart';
import 'package:hamro_footsall/features/app_update/data/repositories/app_update_repository_impl.dart';
import 'package:hamro_footsall/features/app_update/domain/usecase/check_app_update_use_case.dart';
import 'package:hamro_footsall/features/app_update/presentation/bloc/app_update_bloc.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/app_update_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guarded: an unhandled throw here kills the app before runApp() with no UI
  // and no Crashlytics report, which is what a launch crash looks like from
  // TestFlight. Analytics/Crashlytics/FCM are all optional to rendering, so a
  // failure degrades the launch instead of ending it.
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (error, stack) {
    debugPrint('Firebase initialization failed: $error\n$stack');
  }

  if (firebaseReady) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  await AppSettings().init(SharedPreferencesWrapper(preferences));
  final bool hasLoggedIn =
      AppSettings().tokenModel.accessToken?.trim().isNotEmpty ?? false;
  // A missing or unbundled .env used to throw here, before runApp() — which
  // rendered a black screen on release builds instead of the app.
  try {
    await dotenv.load(fileName: ".env");
  } catch (error, stack) {
    // Initialise empty so every later dotenv.env read falls back instead of
    // throwing NotInitializedError.
    dotenv.loadFromString(envString: '');
    if (firebaseReady) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    }
  }

  // Biometric login is only a quick sign-in on the login screen after a
  // logout — an already signed-in user goes straight to the dashboard.
  final String initialLocation = hasLoggedIn
      ? AppRouterParams.dashboard.path
      : AppRouterParams.login.path;

  runApp(MyApp(initialLocation: initialLocation));

  // Deliberately after runApp and unawaited. FirebaseMessaging.requestPermission
  // blocks on the iOS system permission sheet and an APNs round trip, so
  // awaiting it here held back the first frame and left the native splash on
  // screen far longer than Android's. FcmHelper.init is idempotent and every
  // step inside it already handles its own failures.
  unawaited(
    FcmHelper().init().then((_) async {
      if (hasLoggedIn) {
        await FcmHelper().syncTokenAfterLogin();
      }
    }),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialLocation});

  final String initialLocation;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouters.router(
      widget.initialLocation,
      observers: Firebase.apps.isEmpty
          ? const <NavigatorObserver>[]
          : <NavigatorObserver>[
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ],
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => flushPendingNotificationNavigation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Client(
      logout: () async {
        _router.goNamed(AppRouterParams.login.name);
      },
    );
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return BlocProvider<AppUpdateBloc>(
          // App-scoped: a forced update has to be able to cover every route, and
          // a background download must survive navigation.
          create: (_) =>
              AppUpdateBloc(CheckAppUpdateUseCase(AppUpdateRepositoryImpl())),
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: AppThemeController.instance,
            builder: (BuildContext context, ThemeMode mode, Widget? child) {
              return MaterialApp.router(
                title: StringConstants.hamroFutsal,
                debugShowCheckedModeBanner: false,
                theme: FutsalTheme.lightTheme,
                darkTheme: FutsalTheme.darkTheme,
                themeMode: mode,
                // No cross-fade. Only widgets reading Theme.of(context) can be
                // lerped; the rest of the app reads LightColor and switches in
                // one frame. Animating half the screen while the other half
                // snaps is what made the toggle look like it changed twice.
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  FlutterQuillLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                routerConfig: _router,
                builder: (BuildContext context, Widget? child) {
                  return MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.3,
                    child: AppUpdateGate(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
