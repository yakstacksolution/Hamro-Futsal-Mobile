import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class VendorOnboardingShell extends StatelessWidget {
  const VendorOnboardingShell({
    super.key,
    required this.isSubmitting,
    required this.onReset,
    required this.body,
    required this.bottomBar,
  });

  final bool isSubmitting;
  final VoidCallback onReset;
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
          'Vendor Onboarding',
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
          PopupMenuButton<String>(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX16),
            onSelected: (String value) {
              if (value == 'reset') {
                onReset();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'reset',
                child: Text(
                  'Reset onboarding',
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: bottomBar,
      body: body,
    );
  }
}
