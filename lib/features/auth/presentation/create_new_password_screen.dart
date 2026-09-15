import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_futsal/features/auth/presentation/widgets/auth_screen_frame.dart';
import 'package:hamro_futsal/features/auth/presentation/widgets/otp_digit_field.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key, required this.email, this.otp});

  /// The address the OTP was sent to. Submitted with the reset, so the user
  /// never retypes it and cannot reset a different account by editing a field.
  final String email;

  /// The already-verified code, when the OTP screen sent us here.
  final String? otp;

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  static const int _otpLength = 4;
  static const int _resendDelay = 30;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;

  final ValueNotifier<int> _secondsLeftNotifier = ValueNotifier<int>(
    _resendDelay,
  );
  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(
    true,
  );
  final ValueNotifier<bool> _obscureConfirmNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<AutovalidateMode> _autovalidateNotifier =
      ValueNotifier<AutovalidateMode>(AutovalidateMode.disabled);

  Timer? _timer;

  String get _maskedEmail {
    final String email = widget.email.trim();
    if (email.isEmpty || !email.contains('@')) return 'your email';

    final List<String> parts = email.split('@');
    final String name = parts.first;
    final String domain = parts.last;
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  /// True when the code arrived already verified, so no code row is shown.
  bool get _hasVerifiedOtp => (widget.otp?.trim().length ?? 0) == _otpLength;

  String get _otp => _hasVerifiedOtp
      ? widget.otp!.trim()
      : _otpControllers.map((TextEditingController c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _otpControllers = List<TextEditingController>.generate(
      _otpLength,
      (_) => TextEditingController(),
    );
    _otpFocusNodes = List<FocusNode>.generate(_otpLength, (_) => FocusNode());
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
    // Nothing to resend once the code is verified: the only action left is to
    // submit the new password.
    if (!_hasVerifiedOtp) _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final TextEditingController controller in _otpControllers) {
      controller.dispose();
    }
    for (final FocusNode node in _otpFocusNodes) {
      node.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _secondsLeftNotifier.dispose();
    _obscurePasswordNotifier.dispose();
    _obscureConfirmNotifier.dispose();
    _autovalidateNotifier.dispose();
    super.dispose();
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
      _otpFocusNodes[index + 1].requestFocus();
    } else if (digits.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    // The submit button's enablement follows the code's completeness.
    setState(() {});
  }

  void _setOtpDigits(int startIndex, String digits) {
    if (digits.isEmpty) return;
    final int end = (startIndex + digits.length).clamp(0, _otpLength).toInt();
    for (int i = startIndex; i < end; i++) {
      final digit = digits[i - startIndex];
      _otpControllers[i].value = TextEditingValue(
        text: digit,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }
    final nextIndex = end >= _otpLength ? _otpLength - 1 : end;
    _otpFocusNodes[nextIndex].requestFocus();
  }

  String? _validatePassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return StringConstants.passwordIsRequired;
    if (text.length < 8) {
      return StringConstants.passwordMustBeAtLeast8Characters;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return StringConstants.pleaseConfirmYourNewPassword;
    if (text != _passwordController.text) {
      return StringConstants.passwordsDoNotMatch;
    }
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    _autovalidateNotifier.value = AutovalidateMode.onUserInteraction;

    if (_otp.length != _otpLength) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.enterTheDigitCodeToContinue,
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthenticationBloc>().add(
      ResetPasswordEvent(
        email: widget.email.trim(),
        otp: _otp,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      ),
    );
  }

  void _resendOtp() {
    if (_secondsLeftNotifier.value > 0) return;
    for (final TextEditingController controller in _otpControllers) {
      controller.clear();
    }
    setState(() {});
    _otpFocusNodes.first.requestFocus();
    _startResendTimer();
    context.read<AuthenticationBloc>().add(
      ForgotPasswordEvent(email: widget.email.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (AuthenticationState previous, AuthenticationState current) =>
          previous.resetPasswordStatus != current.resetPasswordStatus ||
          previous.forgotPasswordStatus != current.forgotPasswordStatus,
      listener: (BuildContext context, AuthenticationState state) {
        if (state.forgotPasswordStatus == AuthStatus.success) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            StringConstants.aNewCodeIsOnItsWay,
          );
        }

        if (state.resetPasswordStatus == AuthStatus.failure ||
            state.forgotPasswordStatus == AuthStatus.failure) {
          AppUtils().showSnackBar(
            context,
            MsgType.error,
            state.errorMessage ?? StringConstants.somethingWentWrong,
          );
          return;
        }

        if (state.resetPasswordStatus == AuthStatus.success) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            state.successMessage.isNotEmpty
                ? state.successMessage
                : StringConstants.passwordResetSuccessfully,
          );
          // The reset does not create a session, so the user signs in with the
          // new password. goNamed, not push: the whole reset flow is finished
          // and nothing behind it should be reachable with back.
          context.goNamed(AppRouterParams.login.name);
        }
      },
      builder: (BuildContext context, AuthenticationState state) {
        final bool isSubmitting =
            state.resetPasswordStatus == AuthStatus.loading;

        return ValueListenableBuilder<int>(
          valueListenable: _secondsLeftNotifier,
          builder: (BuildContext context, int secondsLeft, _) {
            return AuthScreenFrame(
              isLoading: isSubmitting,
              title: StringConstants.createNewPassword,
              subtitle: _hasVerifiedOtp
                  ? 'Choose a new password for $_maskedEmail'
                  : 'Enter the $_otpLength-digit code sent to $_maskedEmail '
                        'and choose a new password',
              headerIcon: Icons.password_rounded,
              primaryButtonLabel: StringConstants.resetPassword,
              primaryButtonEnabled: _otp.length == _otpLength && !isSubmitting,
              onPrimaryTap: _submit,
              secondaryPrefixText: _hasVerifiedOtp
                  ? StringConstants.rememberPassword
                  : secondsLeft > 0
                  ? 'Resend code in ${secondsLeft}s'
                  : StringConstants.didntReceiveCode,
              secondaryActionText: _hasVerifiedOtp
                  ? StringConstants.backToSignIn
                  : secondsLeft > 0
                  ? StringConstants.wait
                  : StringConstants.resendOtp,
              onSecondaryTap: _hasVerifiedOtp
                  ? () => context.goNamed(AppRouterParams.login.name)
                  : _resendOtp,
              formFields: <Widget>[
                const SizedBox(height: AppDimens.sizeX12),
                if (!_hasVerifiedOtp) ...<Widget>[
                  _buildOtpRow(context),
                  const SizedBox(height: AppDimens.sizeX14),
                ],
                _buildPasswordFields(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOtpRow(BuildContext context) {
    // On wide cards, cap and centre the row so the digit boxes stay a readable
    // group instead of spreading to the edges.
    return AutofillGroup(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTabletOrWider
                ? AppDimens.otpRowMaxWidth
                : double.infinity,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(_otpLength, (int index) {
              return OtpDigitField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                onChanged: (String value) => _onOtpChanged(index, value),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordFields() {
    return ValueListenableBuilder<AutovalidateMode>(
      valueListenable: _autovalidateNotifier,
      builder: (BuildContext context, AutovalidateMode autovalidateMode, _) {
        return Form(
          key: _formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ValueListenableBuilder<bool>(
                valueListenable: _obscurePasswordNotifier,
                builder: (BuildContext context, bool obscure, _) {
                  return CustomTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: obscure,
                    labelText: StringConstants.newPassword,
                    hintText: StringConstants.use8Characters,
                    icon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: _validatePassword,
                    onSubmitted: (_) => FocusScope.of(
                      context,
                    ).requestFocus(_confirmPasswordFocus),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          _obscurePasswordNotifier.value = !obscure,
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: LightColor.secondaryTextColor,
                        size: AppDimens.sizeX20,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimens.sizeX14),
              ValueListenableBuilder<bool>(
                valueListenable: _obscureConfirmNotifier,
                builder: (BuildContext context, bool obscure, _) {
                  return CustomTextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    obscureText: obscure,
                    labelText: StringConstants.confirmPassword,
                    hintText: StringConstants.reEnterYourNewPassword,
                    icon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.done,
                    validator: _validateConfirmPassword,
                    onSubmitted: (_) => _submit(),
                    suffixIcon: IconButton(
                      onPressed: () => _obscureConfirmNotifier.value = !obscure,
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: LightColor.secondaryTextColor,
                        size: AppDimens.sizeX20,
                      ),
                    ),
                  );
                },
              ),
              if (!_hasVerifiedOtp) ...<Widget>[
                const SizedBox(height: AppDimens.sizeX14),
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
            ],
          ),
        );
      },
    );
  }
}
