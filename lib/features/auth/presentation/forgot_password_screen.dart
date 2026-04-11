import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/auth/presentation/widgets/auth_screen_frame.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  String _email = '';

  bool get _isEmailValid => _emailRegex.hasMatch(_email.trim());

  void _submit() {
    if (!_isEmailValid) return;
    context.pushNamed(
      AppRouterParams.otpVerification.name,
      extra: _email.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenFrame(
      title: 'Forgot Password',
      subtitle: 'Enter your email and we will send you an OTP code.',
      headerIcon: Icons.lock_reset_rounded,
      primaryButtonLabel: 'Send OTP',
      primaryButtonEnabled: _isEmailValid,
      onPrimaryTap: _submit,
      secondaryPrefixText: 'Remember your password',
      secondaryActionText: 'Back to sign in',
      onSecondaryTap: () => context.goNamed(AppRouterParams.login.name),
      formFields: <Widget>[
        const SizedBox(height: 12),
        CustomTextField(
          keyboardType: TextInputType.emailAddress,
          labelText: 'Email Address',
          hintText: 'you@example.com',
          icon: Icons.alternate_email_rounded,
          onChanged: (String value) {
            setState(() {
              _email = value;
            });
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: LightColor.skyBlue.withValues(alpha: 0.08),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.info_outline_rounded,
                color: LightColor.skyBlue.withValues(alpha: 0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We will send a verification code to this email.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LightColor.darkgrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
