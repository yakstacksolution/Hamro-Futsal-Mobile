import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_footsall/features/auth/presentation/widgets/auth_screen_frame.dart';

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
  Timer? _timer;
  int _secondsLeft = _resendDelay;

  bool get _canVerify =>
      _controllers.every((TextEditingController c) => c.text.length == 1);

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
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _secondsLeft = _resendDelay;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
        return;
      }
      setState(() {
        _secondsLeft--;
      });
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
    if (!_canVerify) return;
    context.read<AuthenticationBloc>().add(
      OtpVerificationEvent(
        email: widget.email ?? '',
        otp: _controllers.map((TextEditingController c) => c.text).join(),
      ),
    );
    // context.goNamed(AppRouterParams.login.name);
  }

  void _resendOtp() {
    if (_secondsLeft > 0) return;
    for (final TextEditingController controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    _startResendTimer();
    setState(() {});
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
        return AuthScreenFrame(
          isLoading: state.otpVerificationStatus == AuthStatus.loading,
          title: 'OTP Verification',
          subtitle: 'Enter the 6-digit code sent to $_maskedEmail',
          headerIcon: Icons.mark_email_read_rounded,
          primaryButtonLabel: 'Verify OTP',
          primaryButtonEnabled:
              _canVerify && state.otpVerificationStatus != AuthStatus.loading,
          onPrimaryTap: _submit,
          secondaryPrefixText: _secondsLeft > 0
              ? 'Resend code in ${_secondsLeft}s'
              : 'Didn\'t receive code',
          secondaryActionText: _secondsLeft > 0 ? 'Wait' : 'Resend OTP',
          onSecondaryTap: _resendOtp,
          formFields: <Widget>[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List<Widget>.generate(_otpLength, (int index) {
                return _OtpDigitField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (String value) => _onOtpChanged(index, value),
                );
              }),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Check your inbox and spam folder.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LightColor.darkgrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
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
    return SizedBox(
      width: 64,
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: LightColor.titleTextColor,
          fontSize: 20,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: LightColor.background.withValues(alpha: 0.9),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: LightColor.lightGrey,
              width: 1.1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
