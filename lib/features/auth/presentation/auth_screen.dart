import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/auth/presentation/widgets/auth_screen_frame.dart';

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

  late final ValueNotifier<AuthMode> _mode;
  late final ValueNotifier<int> _switchDirection;
  late final ValueNotifier<bool> _obscurePassword;
  late final ValueNotifier<bool> _obscureConfirmPassword;
  late final ValueNotifier<bool> _rememberMe;
  late final ValueNotifier<bool> _acceptedTerms;
  late final ValueNotifier<String?> _selectedAccountType;

  @override
  void initState() {
    super.initState();
    _mode = ValueNotifier<AuthMode>(widget.initialMode);
    _switchDirection = ValueNotifier<int>(1);
    _obscurePassword = ValueNotifier<bool>(true);
    _obscureConfirmPassword = ValueNotifier<bool>(true);
    _rememberMe = ValueNotifier<bool>(true);
    _acceptedTerms = ValueNotifier<bool>(false);
    _selectedAccountType = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _mode.dispose();
    _switchDirection.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _rememberMe.dispose();
    _acceptedTerms.dispose();
    _selectedAccountType.dispose();
    super.dispose();
  }

  bool get _isLogin => _mode.value == AuthMode.login;

  void _setMode(AuthMode mode) {
    if (_mode.value == mode) return;
    _switchDirection.value = mode == AuthMode.register ? 1 : -1;
    _mode.value = mode;
  }

  void _toggleMode() {
    _setMode(_isLogin ? AuthMode.register : AuthMode.login);
  }

  void _submit() {
    context.goNamed(AppRouterParams.dashboard.name);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthMode>(
      valueListenable: _mode,
      builder: (context, mode, _) {
        final bool isLogin = mode == AuthMode.login;
        return ValueListenableBuilder<int>(
          valueListenable: _switchDirection,
          builder: (context, switchDirection, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _obscurePassword,
              builder: (context, obscurePassword, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _obscureConfirmPassword,
                  builder: (context, obscureConfirmPassword, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: _rememberMe,
                      builder: (context, rememberMe, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _acceptedTerms,
                          builder: (context, acceptedTerms, _) {
                            return ValueListenableBuilder<String?>(
                              valueListenable: _selectedAccountType,
                              builder: (context, selectedAccountType, _) {
                                final bool canSubmit =
                                    isLogin ||
                                    (acceptedTerms &&
                                        selectedAccountType != null);
                                return AuthScreenFrame(
                                  isRotate: isLogin,
                                  title: isLogin
                                      ? 'Welcome Back'
                                      : 'Create Your Account',
                                  subtitle: isLogin
                                      ? 'Sign in to book matches or manage your footsall.'
                                      : 'Join as a player or a footsall vendor.',
                                  primaryButtonLabel: isLogin
                                      ? 'Sign In'
                                      : 'Create Account',
                                  primaryButtonIcon: isLogin
                                      ? Icons.login_rounded
                                      : Icons.check_circle_outline_rounded,
                                  headerIcon: isLogin
                                      ? Icons.sports_soccer_rounded
                                      : Icons.person_add_alt_1_rounded,
                                  primaryButtonEnabled: canSubmit,
                                  onPrimaryTap: _submit,
                                  secondaryPrefixText: isLogin
                                      ? 'New to Footsall App?'
                                      : 'Already have an account?',
                                  secondaryActionText: isLogin
                                      ? 'Create new account'
                                      : 'Sign in',
                                  onSecondaryTap: _toggleMode,
                                  
                                  formFields: [
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 460,
                                      ),
                                      reverseDuration: const Duration(
                                        milliseconds: 320,
                                      ),
                                      // Avoid overshoot curves here because the same animation
                                      // is curved again below for fade/size transitions.
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder:
                                          (
                                            Widget child,
                                            Animation<double> animation,
                                          ) {
                                            final Animation<double> fade =
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOut,
                                                );
                                            final Animation<Offset> slide =
                                                Tween<Offset>(
                                                  begin: Offset(
                                                    switchDirection * 0.12,
                                                    0,
                                                  ),
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                );

                                            return FadeTransition(
                                              opacity: fade,
                                              child: SlideTransition(
                                                position: slide,
                                                child: SizeTransition(
                                                  sizeFactor: CurvedAnimation(
                                                    parent: animation,
                                                    curve:
                                                        Curves.easeInOutCubic,
                                                  ),
                                                  axisAlignment: -1,
                                                  child: child,
                                                ),
                                              ),
                                            );
                                          },
                                      child: isLogin
                                          ? _LoginForm(
                                              key: const ValueKey<String>(
                                                'auth-login-form',
                                              ),
                                              obscurePassword: obscurePassword,
                                              rememberMe: rememberMe,
                                              onForgotPasswordTap: () {
                                                context.pushNamed(
                                                  AppRouterParams
                                                      .forgotPassword
                                                      .name,
                                                );
                                              },
                                              onTogglePassword: () =>
                                                  _obscurePassword.value =
                                                      !_obscurePassword.value,
                                              onRememberMeChanged:
                                                  (bool? value) =>
                                                      _rememberMe.value =
                                                          value ?? false,
                                            )
                                          : _RegisterForm(
                                              key: const ValueKey<String>(
                                                'auth-register-form',
                                              ),
                                              obscurePassword: obscurePassword,
                                              obscureConfirmPassword:
                                                  obscureConfirmPassword,
                                              selectedAccountType:
                                                  selectedAccountType,
                                              acceptedTerms: acceptedTerms,
                                              accountTypes: _accountTypes,
                                              onTogglePassword: () =>
                                                  _obscurePassword.value =
                                                      !_obscurePassword.value,
                                              onToggleConfirmPassword: () =>
                                                  _obscureConfirmPassword
                                                          .value =
                                                      !_obscureConfirmPassword
                                                          .value,
                                              onAccountTypeChanged:
                                                  (String? value) =>
                                                      _selectedAccountType
                                                              .value =
                                                          value,
                                              onTermsChanged: (bool? value) =>
                                                  _acceptedTerms.value =
                                                      value ?? false,
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
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    super.key,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onForgotPasswordTap,
    required this.onTogglePassword,
    required this.onRememberMeChanged,
  });

  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onForgotPasswordTap;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberMeChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 12),
        const CustomTextField(
          keyboardType: TextInputType.emailAddress,
          labelText: 'Email Address',
          hintText: 'you@example.com',
          icon: Icons.alternate_email_rounded,
        ),

        const SizedBox(height: 14),
        CustomTextField(
          obscureText: obscurePassword,
          labelText: 'Password',
          hintText: 'Enter your password',
          icon: Icons.lock_outline_rounded,
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
        const SizedBox(height: 6),
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
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    super.key,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.selectedAccountType,
    required this.acceptedTerms,
    required this.accountTypes,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onAccountTypeChanged,
    required this.onTermsChanged,
  });

  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? selectedAccountType;
  final bool acceptedTerms;
  final List<String> accountTypes;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<String?> onAccountTypeChanged;
  final ValueChanged<bool?> onTermsChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 12),

        const CustomTextField(
          textCapitalization: TextCapitalization.words,
          labelText: 'Full Name',
          hintText: 'Your name',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: selectedAccountType,
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
          hint: Text(
            "Select Player or Footsall Vendor",
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
          onChanged: onAccountTypeChanged,
        ),
        const SizedBox(height: 14),
        const CustomTextField(
          keyboardType: TextInputType.emailAddress,
          labelText: 'Email Address',
          hintText: 'name@footsall.com',
          icon: Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          obscureText: obscurePassword,
          labelText: 'Password',
          hintText: 'Use 8+ characters',
          icon: Icons.lock_outline_rounded,
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
        const SizedBox(height: 14),
        CustomTextField(
          obscureText: obscureConfirmPassword,
          labelText: 'Confirm Password',
          hintText: 'Re-enter your password',
          icon: Icons.verified_user_outlined,
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
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
          ),
          child: Row(
            children: <Widget>[
              Checkbox(
                value: acceptedTerms,
                activeColor: theme.colorScheme.primary,
                onChanged: onTermsChanged,
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
        ),
      ],
    );
  }
}
