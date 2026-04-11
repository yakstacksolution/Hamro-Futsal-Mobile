import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/routers/app_routers.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  await AppSettings().init(SharedPreferencesWrapper(preferences));

  final bool hasLoggedIn =
      AppSettings().tokenModel.accessToken?.trim().isNotEmpty ?? false;
  final String initialLocation = hasLoggedIn
      ? AppRouterParams.dashboard.path
      : AppRouterParams.login.path;

  runApp(MyApp(initialLocation: initialLocation));
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
    _router = AppRouters.router(widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    Client(
      logout: () async {
        await navigatorKey.currentState!.pushNamedAndRemoveUntil(
          "login",
          (Route<dynamic> route) => false,
        );
      },
    );
    return MaterialApp.router(
      title: 'Hamro Futsal',
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.lightTheme,
      theme: FutsalTheme.setTheme(context),
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      routerConfig: _router,
    );
  }
}
