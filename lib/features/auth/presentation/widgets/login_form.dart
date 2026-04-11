import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_checkbox.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
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
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppDimens.sizeX12),
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
          const SizedBox(height: AppDimens.sizeX18),
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
                color: LightColor.secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: CustomCheckbox(
                  value: rememberMe,
                  onChanged: onRememberMeChanged,
                  label: 'Remember me',
                  textStyle: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              Flexible(
                child: InkWell(
                  onTap: onForgotPasswordTap,
                  child: Text(
                    'Forgot password?',
                    style: FutsalTheme.getTextTheme(
                      context,
                    ).bodyTextSmall?.copyWith(color: LightColor.secondaryColor),
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
