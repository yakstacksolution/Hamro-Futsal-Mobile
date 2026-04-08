import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_footsall/features/auth/presentation/widgets/auth_screen_frame.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.login});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  static const List<String> _accountTypes = <String>[
    'Player',
    'Footsall Vendor',
  ];

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  late AuthMode _mode;
  bool _isAnimating = false;

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;
  bool _acceptedTerms = false;

  bool _loginValidationEnabled = false;
  bool _registerValidationEnabled = false;

  String? _selectedAccountType;

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
    _mode = widget.initialMode;
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
    super.dispose();
  }

  bool get _isLogin => _mode == AuthMode.login;

  void _setMode(AuthMode mode) {
    if (_mode == mode || _isAnimating) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isAnimating = true;
      _mode = mode;
      _loginValidationEnabled = false;
      _registerValidationEnabled = false;
    });

    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        _isAnimating = false;
      });
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
      setState(() => _loginValidationEnabled = true);
      final bool valid = _loginFormKey.currentState?.validate() ?? false;
      if (!valid) return;

      context.read<AuthenticationBloc>().add(
        LoginEvent(
          email: _loginEmailController.text.trim(),
          password: _loginPasswordController.text,
          rememberMe: _rememberMe,
        ),
      );
      return;
    }

    setState(() => _registerValidationEnabled = true);
    final bool valid = _registerFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    context.read<AuthenticationBloc>().add(
      RegisterEvent(
        fullName: _registerNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        passwordConfirmation: _registerConfirmPasswordController.text,
        accountType: _selectedAccountType!,
        termsAccepted: _acceptedTerms,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (AuthenticationState previous, AuthenticationState current) =>
          previous.loginStatus != current.loginStatus ||
          previous.registrationStatus != current.registrationStatus,
      listener: (BuildContext context, AuthenticationState state) {
        final Map<String, dynamic>? errorData =
            state.loginErrorData is Map<String, dynamic>
            ? state.loginErrorData as Map<String, dynamic>
            : state.registrationErrorData is Map<String, dynamic>
            ? state.registrationErrorData as Map<String, dynamic>
            : null;
        final bool requiresVerification =
            errorData?['verification_required'] == true &&
            errorData?['next_step'] == 'verify_otp';

        if ((state.loginStatus == AuthStatus.failure ||
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
        final bool isSubmitting =
            state.loginStatus == AuthStatus.loading ||
            state.registrationStatus == AuthStatus.loading;

        return AuthScreenFrame(
          isLoading:
              state.loginStatus == AuthStatus.loading ||
              state.registrationStatus == AuthStatus.loading,
          isRotate: _isLogin,
          title: _isLogin ? 'Welcome Back' : 'Create Your Account',
          subtitle: _isLogin
              ? 'Sign in to book matches or manage your footsall.'
              : 'Join as a player or a footsall vendor.',
          primaryButtonLabel: _isLogin ? 'Sign In' : 'Create Account',
          primaryButtonIcon: _isLogin
              ? Icons.login_rounded
              : Icons.check_circle_outline_rounded,
          headerIcon: _isLogin
              ? Icons.sports_soccer_rounded
              : Icons.person_add_alt_1_rounded,
          primaryButtonEnabled: !_isAnimating && !isSubmitting,
          onPrimaryTap: _submit,
          secondaryPrefixText: _isLogin
              ? 'New to Footsall App?'
              : 'Already have an account?',
          secondaryActionText: _isLogin ? 'Create new account' : 'Sign in',
          onSecondaryTap: _toggleMode,
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
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final bool isLoginChild =
                      (child.key as ValueKey<String>).value == 'login-form';

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
                        scale: Tween<double>(begin: 0.985, end: 1).animate(
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
                    _isLogin ? 'login-form' : 'register-form',
                  ),
                  ignoring: _isAnimating || isSubmitting,
                  child: _isLogin
                      ? _LoginForm(
                          formKey: _loginFormKey,
                          autovalidateMode: _loginValidationEnabled
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          obscurePassword: _obscureLoginPassword,
                          rememberMe: _rememberMe,
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
                            setState(() {
                              _obscureLoginPassword = !_obscureLoginPassword;
                            });
                          },
                          onRememberMeChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        )
                      : _RegisterForm(
                          formKey: _registerFormKey,
                          autovalidateMode: _registerValidationEnabled
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          obscurePassword: _obscureRegisterPassword,
                          obscureConfirmPassword: _obscureConfirmPassword,
                          selectedAccountType: _selectedAccountType,
                          acceptedTerms: _acceptedTerms,
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
                          confirmPasswordFocus: _registerConfirmPasswordFocus,
                          nameValidator: _validateName,
                          emailValidator: _validateEmail,
                          passwordValidator: _validatePassword,
                          confirmPasswordValidator: _validateConfirmPassword,
                          onTogglePassword: () {
                            setState(() {
                              _obscureRegisterPassword =
                                  !_obscureRegisterPassword;
                            });
                          },
                          onToggleConfirmPassword: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          onAccountTypeChanged: (String? value) {
                            setState(() {
                              _selectedAccountType = value;
                            });
                          },
                          onTermsChanged: (bool? value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.autovalidateMode,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onForgotPasswordTap,
    required this.onTogglePassword,
    required this.onRememberMeChanged,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.emailValidator,
    required this.passwordValidator,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onForgotPasswordTap;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberMeChanged;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          CustomTextField(
            controller: emailController,
            focusNode: emailFocus,
            keyboardType: TextInputType.emailAddress,
            labelText: 'Email Address',
            hintText: 'you@example.com',
            icon: Icons.alternate_email_rounded,
            textInputAction: TextInputAction.next,
            validator: emailValidator,
            isRequired: true,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(passwordFocus);
            },
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: passwordController,
            focusNode: passwordFocus,
            obscureText: obscurePassword,
            labelText: 'Password',
            hintText: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            validator: passwordValidator,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: LightColor.darkgrey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: rememberMe,
                        activeColor: theme.colorScheme.secondary,
                        onChanged: onRememberMeChanged,
                      ),
                    ),
                    Text(
                      'Remember me',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: LightColor.darkgrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: InkWell(
                  onTap: onForgotPasswordTap,
                  child: Text(
                    'Forgot password?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: LightColor.secondaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.autovalidateMode,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.selectedAccountType,
    required this.acceptedTerms,
    required this.accountTypes,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onAccountTypeChanged,
    required this.onTermsChanged,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocus,
    required this.accountTypeFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.confirmPasswordFocus,
    required this.nameValidator,
    required this.emailValidator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? selectedAccountType;
  final bool acceptedTerms;
  final List<String> accountTypes;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<String?> onAccountTypeChanged;
  final ValueChanged<bool?> onTermsChanged;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocus;
  final FocusNode accountTypeFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmPasswordFocus;
  final FormFieldValidator<String> nameValidator;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final FormFieldValidator<String> confirmPasswordValidator;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          CustomTextField(
            controller: nameController,
            focusNode: nameFocus,
            textCapitalization: TextCapitalization.words,
            labelText: 'Full Name',
            hintText: 'Your name',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: nameValidator,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(accountTypeFocus);
            },
          ),
          const SizedBox(height: 18),

          DropdownButtonFormField<String>(
            initialValue: selectedAccountType,
            focusNode: accountTypeFocus,
            autovalidateMode: autovalidateMode,
            decoration:
                customTextFieldDecoration(
                  context: context,
                  labelText: 'Account Type',
                  icon: Icons.badge_outlined,
                ).copyWith(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: LightColor.darkgrey,
              size: 18,
            ),
            hint: const Text(
              'Select Player or Footsall Vendor',
              style: TextStyle(color: LightColor.darkgrey, fontSize: 13),
            ),
            dropdownColor: LightColor.background,
            items: accountTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please select an account type';
              }
              return null;
            },
            onChanged: onAccountTypeChanged,
          ),
          const SizedBox(height: 18),

          CustomTextField(
            controller: emailController,
            focusNode: emailFocus,
            keyboardType: TextInputType.emailAddress,
            labelText: 'Email Address',
            hintText: 'name@footsall.com',
            icon: Icons.alternate_email_rounded,
            textInputAction: TextInputAction.next,
            validator: emailValidator,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(passwordFocus);
            },
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: passwordController,
            focusNode: passwordFocus,
            obscureText: obscurePassword,
            labelText: 'Password',
            hintText: 'Use 8+ characters',
            icon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: passwordValidator,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(confirmPasswordFocus);
            },
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: LightColor.darkgrey,
              ),
            ),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocus,
            obscureText: obscureConfirmPassword,
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            icon: Icons.verified_user_outlined,
            textInputAction: TextInputAction.done,
            validator: confirmPasswordValidator,
            suffixIcon: IconButton(
              onPressed: onToggleConfirmPassword,
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: LightColor.darkgrey,
              ),
            ),
          ),
          const SizedBox(height: 18),
          FormField<bool>(
            initialValue: acceptedTerms,
            autovalidateMode: autovalidateMode,
            validator: (bool? value) {
              if (acceptedTerms != true) {
                return 'You must accept the terms to continue';
              }
              return null;
            },
            builder: (FormFieldState<bool> field) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                  border: field.hasError
                      ? Border.all(color: theme.colorScheme.error)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: acceptedTerms,
                          activeColor: theme.colorScheme.secondary,
                          onChanged: (bool? value) {
                            onTermsChanged(value);
                            field.didChange(value ?? false);
                          },
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms and Privacy Policy.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: LightColor.darkgrey,
                              fontSize: 12.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Text(
                          field.errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
