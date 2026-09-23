import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_futsal/features/auth/presentation/widgets/auth_screen_frame.dart';
import 'package:hamro_futsal/features/auth/presentation/widgets/otp_digit_field.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// Which flow the OTP screen was opened for, sent to `POST /auth/resend-otp`
/// as `purpose` so the backend re-mails the right kind of code.
abstract final class OtpPurpose {
  static const String registration = 'registration';
  static const String passwordReset = 'password_reset';
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    this.email,
    this.purpose = OtpPurpose.registration,
  });

  final String? email;

  /// One of [OtpPurpose]; decides what a resend asks the backend to send.
  final String purpose;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  static const int _resendDelay = 30;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final ValueNotifier<int> _secondsLeftNotifier;
  late final ValueNotifier<bool> _canVerifyNotifier;
  Timer? _timer;

  String get _maskedEmail {
    final String email = widget.email?.trim() ?? '';
    if (email.isEmpty || !email.contains('@')) return 'your email';

    final List<String> parts = email.split('@');
    final String name = parts.first;
    final String domain = parts.last;
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      _otpLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(_otpLength, (_) => FocusNode());
    _secondsLeftNotifier = ValueNotifier<int>(_resendDelay);
    _canVerifyNotifier = ValueNotifier<bool>(false);
    for (final TextEditingController controller in _controllers) {
      controller.addListener(_updateCanVerify);
    }
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final TextEditingController controller in _controllers) {
      controller.removeListener(_updateCanVerify);
      controller.dispose();
    }
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    _secondsLeftNotifier.dispose();
    _canVerifyNotifier.dispose();
    super.dispose();
  }

  void _updateCanVerify() {
    final bool canVerify = _controllers.every(
      (TextEditingController c) => c.text.length == 1,
    );
    if (_canVerifyNotifier.value != canVerify) {
      _canVerifyNotifier.value = canVerify;
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    _secondsLeftNotifier.value = _resendDelay;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      if (_secondsLeftNotifier.value <= 1) {
        timer.cancel();
        _secondsLeftNotifier.value = 0;
        return;
      }
      _secondsLeftNotifier.value--;
    });
  }

  void _onOtpChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (value.length > 1) {
      _setOtpDigits(digits.length >= _otpLength ? 0 : index, digits);
      setState(() {});
      return;
    }

    if (digits.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (digits.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
  }

  void _setOtpDigits(int startIndex, String digits) {
    if (digits.isEmpty) return;
    final int end = (startIndex + digits.length).clamp(0, _otpLength).toInt();
    for (int i = startIndex; i < end; i++) {
      final digit = digits[i - startIndex];
      _controllers[i].value = TextEditingValue(
        text: digit,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }
    final nextIndex = end >= _otpLength ? _otpLength - 1 : end;
    _focusNodes[nextIndex].requestFocus();
    _updateCanVerify();
  }

  String get _otp =>
      _controllers.map((TextEditingController c) => c.text).join();

  void _submit() {
    if (!_canVerifyNotifier.value) return;
    context.read<AuthenticationBloc>().add(
      OtpVerificationEvent(email: widget.email ?? '', otp: _otp),
    );
  }

  void _resendOtp() {
    if (_secondsLeftNotifier.value > 0) return;
    final String email = widget.email?.trim() ?? '';
    if (email.isEmpty) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.resendOtpFailedPleaseTryAgain,
      );
      return;
    }

    for (final TextEditingController controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    _startResendTimer();
    context.read<AuthenticationBloc>().add(
      ResendOtpEvent(email: email, purpose: widget.purpose),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (AuthenticationState previous, AuthenticationState current) =>
          previous.otpVerificationStatus != current.otpVerificationStatus ||
          previous.resendOtpStatus != current.resendOtpStatus,
      listener: (BuildContext context, AuthenticationState state) {
        if (state.resendOtpStatus == AuthStatus.failure &&
            state.errorMessage != null) {
          AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
        }

        if (state.resendOtpStatus == AuthStatus.success) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            state.successMessage.isNotEmpty
                ? state.successMessage
                : 'OTP resent successfully. Check your email.',
          );
        }

        if (state.otpVerificationStatus == AuthStatus.failure &&
            state.errorMessage != null) {
          AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
        }

        if (state.otpVerificationStatus == AuthStatus.success) {
          // Password reset: the code is now proven, but the reset endpoint
          // still needs it in its body, so it travels to the password screen
          // rather than being typed a second time.
          if (widget.purpose == OtpPurpose.passwordReset) {
            AppUtils().showSnackBar(
              context,
              MsgType.success,
              StringConstants.codeVerifiedChooseANewPassword,
            );
            context.pushNamed(
              AppRouterParams.createNewPassword.name,
              extra: <String, dynamic>{
                'email': widget.email?.trim() ?? '',
                'otp': _otp,
              },
            );
            return;
          }

          final Map<String, dynamic> responseData =
              state.otpVerificationData is Map<String, dynamic>
              ? state.otpVerificationData as Map<String, dynamic>
              : <String, dynamic>{};
          final String? nextStep = responseData['next_step'] as String?;
          final bool hasSessionToken =
              (responseData['access_token'] ?? responseData['token']) != null;

          AppUtils().showSnackBar(
            context,
            MsgType.success,
            hasSessionToken
                ? 'OTP verified successfully.'
                : 'OTP verified successfully. Please sign in to continue.',
          );

          if (nextStep == 'vendor_onboarding') {
            context.goNamed(AppRouterParams.vendorOnboarding.name);
            return;
          }

          context.goNamed(
            hasSessionToken
                ? AppRouterParams.dashboard.name
                : AppRouterParams.login.name,
          );
        }
      },
      builder: (BuildContext context, AuthenticationState state) {
        return ValueListenableBuilder<int>(
          valueListenable: _secondsLeftNotifier,
          builder: (BuildContext context, int secondsLeft, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _canVerifyNotifier,
              builder: (BuildContext context, bool canVerify, _) {
                return AuthScreenFrame(
                  isLoading: state.otpVerificationStatus == AuthStatus.loading,
                  title: StringConstants.otpVerification,
                  subtitle:
                      'Enter the $_otpLength-digit code sent to $_maskedEmail',
                  headerIcon: Icons.mark_email_read_rounded,
                  primaryButtonLabel: 'Verify OTP',
                  primaryButtonEnabled:
                      canVerify &&
                      state.otpVerificationStatus != AuthStatus.loading,
                  onPrimaryTap: _submit,
                  secondaryPrefixText: secondsLeft > 0
                      ? 'Resend code in ${secondsLeft}s'
                      : 'Didn\'t receive code',
                  secondaryActionText: secondsLeft > 0 ? 'Wait' : 'Resend OTP',
                  onSecondaryTap: _resendOtp,
                  formFields: <Widget>[
                    SizedBox(height: AppDimens.sizeX12),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppDimens.otpRowMaxWidth,
                        ),
                        child: OtpDigitRow(
                          controllers: _controllers,
                          focusNodes: _focusNodes,
                          onChanged: _onOtpChanged,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimens.sizeX14),
                    Text(
                      StringConstants.checkYourInboxAndSpamFolder,
                      textAlign: TextAlign.center,
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: LightColor.secondaryTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
