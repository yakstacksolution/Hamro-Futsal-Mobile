import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_footsall/features/auth/presentation/widgets/auth_screen_frame.dart';
import 'package:hamro_footsall/features/auth/presentation/widgets/login_form.dart';
import 'package:hamro_footsall/features/auth/presentation/widgets/register_form.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.login});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const List<String> _accountTypes = <String>[
    'Player',
    'Footsall Vendor',
  ];

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  late final ValueNotifier<AuthMode> _modeNotifier;
  late final ValueNotifier<bool> _isAnimatingNotifier;
  late final ValueNotifier<bool> _obscureLoginPasswordNotifier;
  late final ValueNotifier<bool> _obscureRegisterPasswordNotifier;
  late final ValueNotifier<bool> _obscureConfirmPasswordNotifier;
  late final ValueNotifier<bool> _rememberMeNotifier;
  late final ValueNotifier<bool> _acceptedTermsNotifier;
  late final ValueNotifier<bool> _loginValidationEnabledNotifier;
  late final ValueNotifier<bool> _registerValidationEnabledNotifier;
  late final ValueNotifier<String?> _selectedAccountTypeNotifier;

  // Login
  final FocusNode _loginEmailFocus = FocusNode();
  final FocusNode _loginPasswordFocus = FocusNode();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Register
  final FocusNode _registerNameFocus = FocusNode();
  final FocusNode _registerAccountTypeFocus = FocusNode();
  final FocusNode _registerEmailFocus = FocusNode();
  final FocusNode _registerPasswordFocus = FocusNode();
  final FocusNode _registerConfirmPasswordFocus = FocusNode();

  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _modeNotifier = ValueNotifier<AuthMode>(widget.initialMode);
    _isAnimatingNotifier = ValueNotifier<bool>(false);
    _obscureLoginPasswordNotifier = ValueNotifier<bool>(true);
    _obscureRegisterPasswordNotifier = ValueNotifier<bool>(true);
    _obscureConfirmPasswordNotifier = ValueNotifier<bool>(true);
    _rememberMeNotifier = ValueNotifier<bool>(true);
    _acceptedTermsNotifier = ValueNotifier<bool>(false);
    _loginValidationEnabledNotifier = ValueNotifier<bool>(false);
    _registerValidationEnabledNotifier = ValueNotifier<bool>(false);
    _selectedAccountTypeNotifier = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();

    _registerNameFocus.dispose();
    _registerAccountTypeFocus.dispose();
    _registerEmailFocus.dispose();
    _registerPasswordFocus.dispose();
    _registerConfirmPasswordFocus.dispose();

    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _modeNotifier.dispose();
    _isAnimatingNotifier.dispose();
    _obscureLoginPasswordNotifier.dispose();
    _obscureRegisterPasswordNotifier.dispose();
    _obscureConfirmPasswordNotifier.dispose();
    _rememberMeNotifier.dispose();
    _acceptedTermsNotifier.dispose();
    _loginValidationEnabledNotifier.dispose();
    _registerValidationEnabledNotifier.dispose();
    _selectedAccountTypeNotifier.dispose();
    super.dispose();
  }

  bool get _isLogin => _modeNotifier.value == AuthMode.login;

  void _setMode(AuthMode mode) {
    if (_modeNotifier.value == mode || _isAnimatingNotifier.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    _isAnimatingNotifier.value = true;
    _modeNotifier.value = mode;
    _loginValidationEnabledNotifier.value = false;
    _registerValidationEnabledNotifier.value = false;

    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      _isAnimatingNotifier.value = false;
    });
  }

  void _toggleMode() {
    _setMode(_isLogin ? AuthMode.register : AuthMode.login);
  }

  String? _validateName(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Full name is required';
    if (text.length < 3) return 'Enter your full name';
    return null;
  }

  String? _validateEmail(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Please confirm your password';
    if (text != _registerPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (_isLogin) {
      _loginValidationEnabledNotifier.value = true;
      final bool valid = _loginFormKey.currentState?.validate() ?? false;
      if (!valid) return;

      context.read<AuthenticationBloc>().add(
        LoginEvent(
          email: _loginEmailController.text.trim(),
          password: _loginPasswordController.text,
          rememberMe: _rememberMeNotifier.value,
        ),
      );
      return;
    }

    _registerValidationEnabledNotifier.value = true;
    final bool valid = _registerFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    context.read<AuthenticationBloc>().add(
      RegisterEvent(
        fullName: _registerNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        passwordConfirmation: _registerConfirmPasswordController.text,
        accountType: _selectedAccountTypeNotifier.value!,
        termsAccepted: _acceptedTermsNotifier.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (AuthenticationState previous, AuthenticationState current) =>
          previous.loginStatus != current.loginStatus ||
          previous.googleLoginStatus != current.googleLoginStatus ||
          previous.registrationStatus != current.registrationStatus,
      listener: (BuildContext context, AuthenticationState state) {
        final Map<String, dynamic>? errorData =
            state.loginErrorData is Map<String, dynamic>
            ? state.loginErrorData as Map<String, dynamic>
            : state.googleLoginErrorData is Map<String, dynamic>
            ? state.googleLoginErrorData as Map<String, dynamic>
            : state.registrationErrorData is Map<String, dynamic>
            ? state.registrationErrorData as Map<String, dynamic>
            : null;
        final bool requiresVerification =
            errorData?['verification_required'] == true &&
            errorData?['next_step'] == 'verify_otp';
        // context.goNamed(AppRouterParams.dashboard.name);
        // return;
        if ((state.loginStatus == AuthStatus.failure ||
                state.googleLoginStatus == AuthStatus.failure ||
                state.registrationStatus == AuthStatus.failure) &&
            (state.errorMessage != null || errorData != null)) {
          AppUtils().showSnackBar(
            context,
            requiresVerification ? MsgType.info : MsgType.error,
            state.errorMessage ?? '',
          );
          if (requiresVerification &&
              (errorData?['email'] as String?) != null) {
            context.pushNamed(
              AppRouterParams.otpVerification.name,
              extra: (errorData!['email'] as String).trim(),
            );
          }
        }

        if (state.googleLoginStatus == AuthStatus.success &&
            state.successMessage.isNotEmpty) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            state.successMessage,
          );
          context.goNamed(AppRouterParams.dashboard.name);
          return;
        }

        if ((state.loginStatus == AuthStatus.success ||
                state.registrationStatus == AuthStatus.success) &&
            state.successMessage.isNotEmpty) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            state.successMessage,
          );
          if (_isLogin) {
            context.goNamed(AppRouterParams.dashboard.name);
            return;
          }
          context.goNamed(
            AppRouterParams.otpVerification.name,
            queryParameters: {'email': _registerEmailController.text.trim()},
          );
        }
        if (state.registrationStatus == AuthStatus.success) {
          _setMode(AuthMode.login);
          context.goNamed(
            AppRouterParams.otpVerification.name,
            queryParameters: {'email': _registerEmailController.text.trim()},
          );
        }
      },
      builder: (BuildContext context, AuthenticationState state) {
        final bool isGoogleSubmitting =
            state.googleLoginStatus == AuthStatus.loading;
        final bool isSubmitting =
            state.loginStatus == AuthStatus.loading ||
            state.registrationStatus == AuthStatus.loading;

        return AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            _modeNotifier,
            _isAnimatingNotifier,
            _obscureLoginPasswordNotifier,
            _obscureRegisterPasswordNotifier,
            _obscureConfirmPasswordNotifier,
            _rememberMeNotifier,
            _acceptedTermsNotifier,
            _loginValidationEnabledNotifier,
            _registerValidationEnabledNotifier,
            _selectedAccountTypeNotifier,
          ]),
          builder: (BuildContext context, _) {
            final bool isLogin = _modeNotifier.value == AuthMode.login;
            final bool isAnimating = _isAnimatingNotifier.value;

            return AuthScreenFrame(
              isLoading:
                  state.loginStatus == AuthStatus.loading ||
                  state.registrationStatus == AuthStatus.loading,
              // Google sign-in tracks its own loading state via the footer.
              isRotate: isLogin,
              title: isLogin ? 'Welcome Back' : 'Create Your Account',
              subtitle: isLogin
                  ? 'Sign in to book matches or manage your footsall.'
                  : 'Join as a player or a footsall vendor.',
              primaryButtonLabel: isLogin ? 'Sign In' : 'Create Account',
              primaryButtonIcon: isLogin
                  ? Icons.login_rounded
                  : Icons.check_circle_outline_rounded,
              headerIcon: isLogin
                  ? Icons.sports_soccer_rounded
                  : Icons.person_add_alt_1_rounded,
              primaryButtonEnabled:
                  !isAnimating && !isSubmitting && !isGoogleSubmitting,
              onPrimaryTap: _submit,
              secondaryPrefixText: isLogin
                  ? 'New to Footsall App?'
                  : 'Already have an account?',
              secondaryActionText: isLogin ? 'Create account' : 'Sign in',
              onSecondaryTap: _toggleMode,
              footer: isLogin
                  ? _GoogleLoginSection(
                      enabled:
                          !isAnimating && !isSubmitting && !isGoogleSubmitting,
                      isLoading: isGoogleSubmitting,
                      onTap: () => context.read<AuthenticationBloc>().add(
                        const GoogleLoginEvent(),
                      ),
                    )
                  : null,
              formFields: <Widget>[
                AnimatedSize(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    reverseDuration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          final bool isLoginChild =
                              (child.key as ValueKey<String>).value ==
                              'login-form';

                          final Offset beginOffset = isLoginChild
                              ? const Offset(-0.08, 0)
                              : const Offset(0.08, 0);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: beginOffset,
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.985, end: 1)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutBack,
                                      ),
                                    ),
                                child: child,
                              ),
                            ),
                          );
                        },
                    child: IgnorePointer(
                      key: ValueKey<String>(
                        isLogin ? 'login-form' : 'register-form',
                      ),
                      ignoring: isAnimating || isSubmitting,
                      child: isLogin
                          ? LoginForm(
                              formKey: _loginFormKey,
                              autovalidateMode:
                                  _loginValidationEnabledNotifier.value
                                  ? AutovalidateMode.always
                                  : AutovalidateMode.disabled,
                              obscurePassword:
                                  _obscureLoginPasswordNotifier.value,
                              rememberMe: _rememberMeNotifier.value,
                              emailController: _loginEmailController,
                              passwordController: _loginPasswordController,
                              emailFocus: _loginEmailFocus,
                              passwordFocus: _loginPasswordFocus,
                              emailValidator: _validateEmail,
                              passwordValidator: _validatePassword,
                              onForgotPasswordTap: () {
                                context.pushNamed(
                                  AppRouterParams.forgotPassword.name,
                                );
                              },
                              onTogglePassword: () {
                                _obscureLoginPasswordNotifier.value =
                                    !_obscureLoginPasswordNotifier.value;
                              },
                              onRememberMeChanged: (bool? value) {
                                _rememberMeNotifier.value = value ?? false;
                              },
                            )
                          : RegisterForm(
                              formKey: _registerFormKey,
                              autovalidateMode:
                                  _registerValidationEnabledNotifier.value
                                  ? AutovalidateMode.always
                                  : AutovalidateMode.disabled,
                              obscurePassword:
                                  _obscureRegisterPasswordNotifier.value,
                              obscureConfirmPassword:
                                  _obscureConfirmPasswordNotifier.value,
                              selectedAccountType:
                                  _selectedAccountTypeNotifier.value,
                              acceptedTerms: _acceptedTermsNotifier.value,
                              accountTypes: _accountTypes,
                              nameController: _registerNameController,
                              emailController: _registerEmailController,
                              passwordController: _registerPasswordController,
                              confirmPasswordController:
                                  _registerConfirmPasswordController,
                              nameFocus: _registerNameFocus,
                              accountTypeFocus: _registerAccountTypeFocus,
                              emailFocus: _registerEmailFocus,
                              passwordFocus: _registerPasswordFocus,
                              confirmPasswordFocus:
                                  _registerConfirmPasswordFocus,
                              nameValidator: _validateName,
                              emailValidator: _validateEmail,
                              passwordValidator: _validatePassword,
                              confirmPasswordValidator:
                                  _validateConfirmPassword,
                              onTogglePassword: () {
                                _obscureRegisterPasswordNotifier.value =
                                    !_obscureRegisterPasswordNotifier.value;
                              },
                              onToggleConfirmPassword: () {
                                _obscureConfirmPasswordNotifier.value =
                                    !_obscureConfirmPasswordNotifier.value;
                              },
                              onAccountTypeChanged: (String? value) {
                                _selectedAccountTypeNotifier.value = value;
                              },
                              onTermsChanged: (bool? value) {
                                _acceptedTermsNotifier.value = value ?? false;
                              },
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// "or" divider + "Continue with Google" button shown under the login form.
class _GoogleLoginSection extends StatelessWidget {
  const _GoogleLoginSection({
    required this.enabled,
    required this.onTap,
    this.isLoading = false,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Divider(height: 1, color: LightColor.dividerColor),
            ),
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX12,
              ),
              child: Text(
                'or',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ),
            const Expanded(
              child: Divider(height: 1, color: LightColor.dividerColor),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sizeX14),
        Material(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            child: Container(
              height: AppDimens.sizeX44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                border: Border.all(color: LightColor.greyBorderColor),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: AppDimens.sizeX18,
                      height: AppDimens.sizeX18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons/google_logo.svg',
                          width: AppDimens.sizeX18,
                          height: AppDimens.sizeX18,
                        ),
                        const SizedBox(width: AppDimens.paddingX10),
                        Text(
                          'Continue with Google',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
