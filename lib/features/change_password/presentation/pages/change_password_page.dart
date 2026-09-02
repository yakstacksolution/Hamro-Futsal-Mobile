import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/change_password/presentation/bloc/change_password_bloc/change_password_bloc.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// Change the signed-in user's password — `PUT /auth/password`.
///
/// Mirrors the forgot-password screen's format: gradient icon header, white
/// form card with [CustomTextField]s and a [CustomButton] that stays disabled
/// until the form is valid — just without the auth background bubbles.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String _oldPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  bool get _isValid =>
      _oldPassword.trim().isNotEmpty &&
      _newPassword.length >= 8 &&
      _newPassword != _oldPassword &&
      _confirmPassword == _newPassword;

  void _submit() {
    if (!_isValid) return;
    FocusScope.of(context).unfocus();
    context.read<ChangePasswordBloc>().add(
      SubmitChangePasswordEvent(
        oldPassword: _oldPassword,
        newPassword: _newPassword,
        confirmPassword: _confirmPassword,
      ),
    );
  }

  Widget _visibilityToggle(bool visible, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: AppDimens.sizeX18,
        color: LightColor.iconGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.changePassword),
      body: SafeArea(
        top: false,
        child: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
          listener: (context, state) {
            if (state.status == ChangePasswordStatus.failure) {
              AppUtils().showSnackBar(
                context,
                MsgType.error,
                state.message ?? 'Could not change the password.',
              );
            }
            if (state.status == ChangePasswordStatus.success) {
              AppUtils().showSnackBar(
                context,
                MsgType.success,
                state.message ?? 'Password updated successfully.',
              );
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingX20,
                  AppDimens.paddingX24,
                  AppDimens.paddingX20,
                  AppDimens.paddingX20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        (AppDimens.sizeX130 + AppDimens.sizeX130) *
                        AppDimens.sizeX2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const _ChangePasswordHeader(),
                      const SizedBox(height: AppDimens.sizeX18),
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.paddingX20,
                          AppDimens.paddingX20,
                          AppDimens.paddingX20,
                          AppDimens.paddingX14,
                        ),
                        decoration: BoxDecoration(
                          color: LightColor.whiteColor.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX20,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(height: AppDimens.sizeX12),
                            CustomTextField(
                              labelText: StringConstants.currentPassword,
                              hintText: StringConstants.enterCurrentPassword,
                              icon: Icons.lock_outline_rounded,
                              obscureText: !_showOld,
                              textInputAction: TextInputAction.next,
                              onChanged: (String value) {
                                setState(() => _oldPassword = value);
                              },
                              suffixIcon: _visibilityToggle(
                                _showOld,
                                () => setState(() => _showOld = !_showOld),
                              ),
                            ),
                            const SizedBox(height: AppDimens.sizeX14),
                            CustomTextField(
                              labelText: StringConstants.newPassword,
                              hintText: StringConstants.enterNewPassword,
                              icon: Icons.lock_reset_rounded,
                              obscureText: !_showNew,
                              textInputAction: TextInputAction.next,
                              onChanged: (String value) {
                                setState(() => _newPassword = value);
                              },
                              suffixIcon: _visibilityToggle(
                                _showNew,
                                () => setState(() => _showNew = !_showNew),
                              ),
                            ),
                            const SizedBox(height: AppDimens.sizeX14),
                            CustomTextField(
                              labelText: StringConstants.confirmNewPassword,
                              hintText: StringConstants.reEnterNewPassword,
                              icon: Icons.check_circle_outline_rounded,
                              obscureText: !_showConfirm,
                              textInputAction: TextInputAction.done,
                              onChanged: (String value) {
                                setState(() => _confirmPassword = value);
                              },
                              onSubmitted: (_) => _submit(),
                              suffixIcon: _visibilityToggle(
                                _showConfirm,
                                () => setState(
                                  () => _showConfirm = !_showConfirm,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimens.sizeX14),
                            Container(
                              padding: AppUtils().getPadding(
                                symmetricHorizontal: AppDimens.paddingX12,
                                symmetricVertical: AppDimens.paddingX10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusX12,
                                ),
                                color: LightColor.secondaryColor.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: LightColor.secondaryColor.withValues(
                                      alpha: 0.9,
                                    ),
                                    size: AppDimens.sizeX18,
                                  ),
                                  const SizedBox(width: AppDimens.sizeX8),
                                  Expanded(
                                    child: Text(
                                      StringConstants
                                          .passwordMustDifferFromCurrent,
                                      style: FutsalTheme.getTextTheme(context)
                                          .bodyTextSmall
                                          ?.copyWith(
                                            color:
                                                LightColor.secondaryTextColor,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppDimens.sizeX18),
                            CustomButton(
                              text: StringConstants.updatePassword,
                              minHeight: AppDimens.sizeX44,
                              isLoading: state.isSubmitting,
                              backgroundColor: LightColor.buttonColor,
                              onPressed: _isValid && !state.isSubmitting
                                  ? _submit
                                  : null,
                            ),
                            const SizedBox(height: AppDimens.sizeX10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Same header format as the auth screens: gradient circle icon beside the
/// title and helper subtitle.
class _ChangePasswordHeader extends StatelessWidget {
  const _ChangePasswordHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: AppDimens.sizeX58,
          height: AppDimens.sizeX58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                LightColor.secondaryColor,
                LightColor.secondaryColor,
                LightColor.secondaryDark,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: LightColor.secondaryColor.withValues(alpha: 0.25),
                blurRadius: AppDimens.radiusX18,
                offset: const Offset(0, AppDimens.sizeX8),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            color: LightColor.inverseTextColor,
            size: AppDimens.sizeX28,
          ),
        ),
        const SizedBox(width: AppDimens.sizeX14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                StringConstants.changePassword,
                style: FutsalTheme.getTextTheme(
                  context,
                ).headingSubTitle?.copyWith(color: LightColor.primaryTextColor),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                StringConstants.enterYourCurrentPasswordAndChooseANewOne,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
