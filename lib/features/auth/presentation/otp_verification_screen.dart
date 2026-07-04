import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_footsall/features/auth/presentation/widgets/auth_screen_frame.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.email});

  final String? email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 4;
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
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
  }

  void _submit() {
    if (!_canVerifyNotifier.value) return;
    context.read<AuthenticationBloc>().add(
      OtpVerificationEvent(
        email: widget.email ?? '',
        otp: _controllers.map((TextEditingController c) => c.text).join(),
      ),
    );
  }

  void _resendOtp() {
    if (_secondsLeftNotifier.value > 0) return;
    for (final TextEditingController controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (AuthenticationState previous, AuthenticationState current) =>
          previous.otpVerificationStatus != current.otpVerificationStatus,
      listener: (BuildContext context, AuthenticationState state) {
        if (state.otpVerificationStatus == AuthStatus.failure &&
            state.errorMessage != null) {
          AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
        }

        if (state.otpVerificationStatus == AuthStatus.success) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List<Widget>.generate(_otpLength, (int index) {
                        return _OtpDigitField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (String value) =>
                              _onOtpChanged(index, value),
                        );
                      }),
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

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    return SizedBox(
      width: AppDimens.sizeX64,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        cursorColor: LightColor.primaryTextColor,
        style: textTheme.headingSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: LightColor.primaryTextColor,
          fontSize: AppDimens.fontHeadingSmall,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: LightColor.background.withValues(alpha: 0.9),
          contentPadding: appUtils.getPadding(
            symmetricVertical: AppDimens.paddingX14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            borderSide: const BorderSide(
              color: LightColor.borderColor,
              width: 1.1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            borderSide: BorderSide(
              color: LightColor.secondaryColor,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
