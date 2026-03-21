import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamro_footsall/core/routers/app_routers.dart';
import 'package:hamro_footsall/core/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hamro Footsall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.mulishTextTheme(Theme.of(context).textTheme),
      ),
      routerConfig: AppRouters.router,
    );
  }
}
