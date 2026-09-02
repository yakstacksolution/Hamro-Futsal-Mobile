import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/auth/presentation/widgets/auth_screen_frame.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

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
      title: StringConstants.forgotPassword,
      subtitle: StringConstants.enterYourEmailAndWeWillSendYouAnOtpCode,
      headerIcon: Icons.lock_reset_rounded,
      primaryButtonLabel: 'Send OTP',
      primaryButtonEnabled: _isEmailValid,
      onPrimaryTap: _submit,
      secondaryPrefixText: StringConstants.rememberPassword,
      secondaryActionText: StringConstants.backToSignIn,
      onSecondaryTap: () => context.goNamed(AppRouterParams.login.name),
      formFields: <Widget>[
        const SizedBox(height: AppDimens.sizeX12),
        CustomTextField(
          keyboardType: TextInputType.emailAddress,
          labelText: StringConstants.emailAddress,
          hintText: StringConstants.youExampleCom,
          icon: Icons.alternate_email_rounded,
          onChanged: (String value) {
            setState(() {
              _email = value;
            });
          },
        ),
        const SizedBox(height: AppDimens.sizeX14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            color: LightColor.secondaryColor.withValues(alpha: 0.08),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.info_outline_rounded,
                color: LightColor.secondaryColor.withValues(alpha: 0.9),
                size: AppDimens.sizeX18,
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Expanded(
                child: Text(
                  StringConstants.weWillSendAVerificationCodeToThisEmail,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(color: LightColor.secondaryTextColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
