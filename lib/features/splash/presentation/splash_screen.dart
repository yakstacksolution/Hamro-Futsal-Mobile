import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToLogin();
  }

  Future<void> _goToLogin() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    context.goNamed(AppRouterParams.login.name);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Hamro Footsall',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
