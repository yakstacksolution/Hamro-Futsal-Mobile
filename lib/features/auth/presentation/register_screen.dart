import 'package:flutter/material.dart';
import 'package:hamro_futsal/features/auth/presentation/auth_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(initialMode: AuthMode.register);
  }
}
