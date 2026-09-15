import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';

/// One box of an OTP row.
///
/// Shared by OTP verification and the forgot-password reset screen so the two
/// code inputs cannot drift apart visually.
class OtpDigitField extends StatelessWidget {
  const OtpDigitField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return SizedBox(
      width: context.responsive<double>(
        mobile: AppDimens.sizeX64,
        tablet: AppDimens.sizeX76,
        desktop: AppDimens.sizeX84,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        autofillHints: const <String>[AutofillHints.oneTimeCode],
        enableSuggestions: false,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
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
          // Plain EdgeInsets: AppUtils.getPadding scales by screenWidth/375,
          // which inflates ~2.7x on a tablet.
          contentPadding: EdgeInsets.symmetric(
            vertical: context.isTabletOrWider
                ? AppDimens.paddingX18
                : AppDimens.paddingX14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            borderSide: BorderSide(color: LightColor.borderColor, width: 1.1),
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
