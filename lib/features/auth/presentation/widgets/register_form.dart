import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_checkbox.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
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
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppDimens.sizeX12),
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
          const SizedBox(height: AppDimens.sizeX18),
          CustomDropdownField<String>(
            initialValue: selectedAccountType,
            labelText: 'Account Type',
            icon: Icons.badge_outlined,
            hintText: 'Select Player or Vendor',
            items: accountTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: FutsalTheme.getTextTheme(context).bodyTextLarge
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontSize: AppDimens.sizeX12,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              );
            }).toList(),
            focusNode: accountTypeFocus,
            autovalidateMode: autovalidateMode,
            dropdownColor: LightColor.background,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please select an account type';
              }
              return null;
            },
            onChanged: onAccountTypeChanged,
          ),
          const SizedBox(height: AppDimens.sizeX18),
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
          const SizedBox(height: AppDimens.sizeX18),
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
                color: LightColor.secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sizeX18),
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
                color: LightColor.secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sizeX18),
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
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX8,
                  symmetricVertical: AppDimens.paddingX6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  color: LightColor.secondaryTextColor.withValues(alpha: 0.08),
                  border: field.hasError
                      ? Border.all(color: LightColor.redColor)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: CustomCheckbox(
                            value: acceptedTerms,
                            activeColor: LightColor.secondaryColor,
                            borderColor: LightColor.secondaryLightMedium,
                            isExpanded: true,
                            label: 'I agree to the Terms and Privacy Policy.',
                            textStyle: FutsalTheme.getTextTheme(context)
                                .bodyTextSmall
                                ?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                  fontWeight: FontWeight.w400,
                                ),
                            onChanged: (bool? value) {
                              onTermsChanged(value);
                              field.didChange(value ?? false);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (field.hasError)
                      Padding(
                        padding: AppUtils().getPadding(
                          symmetricHorizontal: AppDimens.paddingX12,
                        ),
                        child: Text(
                          field.errorText!,
                          style: FutsalTheme.getTextTheme(
                            context,
                          ).bodyTextSmall?.copyWith(color: LightColor.redColor),
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
