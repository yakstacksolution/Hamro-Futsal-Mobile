import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

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
      backgroundColor: LightColor.white,
      appBar: AppBar(
        backgroundColor: LightColor.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Vendor Onboarding',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),

        leading: InkWell(
          onTap: isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Icon(
            size: 18,
            Icons.arrow_back_ios_rounded,
            color: LightColor.black,
          ),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'reset') {
                onReset();
              }
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'reset',
                    child: Text('Reset onboarding'),
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
