import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';

class VendorOnboardingShell extends StatelessWidget {
  const VendorOnboardingShell({
    super.key,
    required this.isSubmitting,
    required this.onExitToHome,
    required this.body,
    required this.bottomBar,
  });

  final bool isSubmitting;
  final Future<void> Function() onExitToHome;
  final Widget body;
  final Widget bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.whiteColor,
      appBar: AppBar(
        backgroundColor: LightColor.whiteColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          StringConstants.vendorOnboarding,
          style: FutsalTheme.getTextTheme(
            context,
          ).headingSmall?.copyWith(fontWeight: FontWeight.w500),
        ),

        leading: InkWell(
          onTap: isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Icon(
            size: AppDimens.sizeX18,
            Icons.arrow_back_ios_rounded,
            color: LightColor.primaryTextColor,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Home',
            onPressed: isSubmitting
                ? null
                : () async {
                    final bool shouldExit = await showConfirmDialog(
                      context: context,
                      title: 'Save changes & exit?',

                      message:
                          'Your current onboarding progress will be saved before returning home.',
                      confirmText: 'Save & go home',
                      cancelText: 'Stay here',
                      iconWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const CustomImageView(
                          imagePath: ImageConstants.navHomeFill,
                          width: AppDimens.sizeX28,
                          height: AppDimens.sizeX20,
                          fit: BoxFit.contain,
                          color: LightColor.secondaryColor,
                        ),
                      ),
                    );
                    if (context.mounted && shouldExit) {
                      await onExitToHome();
                    }
                  },
            icon: const CustomImageView(
              imagePath: ImageConstants.navHome,
              width: AppDimens.sizeX22,
              height: AppDimens.sizeX22,
              fit: BoxFit.contain,
              color: LightColor.secondaryColor,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX8),
        ],
      ),
      bottomNavigationBar: bottomBar,
      body: body,
    );
  }
}
