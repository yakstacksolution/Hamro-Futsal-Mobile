import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';

/// Widest the onboarding forms grow: a readable form column on a tablet and
/// on desktop, the full width on a phone.
double vendorFormMaxWidth(BuildContext context) => context.isDesktop
    ? 920
    : context.isTablet
    ? 760
    : double.infinity;

/// Centres [child] at [vendorFormMaxWidth] on a tablet or desktop window and
/// leaves it untouched on a phone — so the venue and court onboarding forms,
/// their headers and their action bar share one column instead of stretching
/// across the window.
///
/// Sized to its child's height (`heightFactor: 1`), so it is safe inside a
/// bottom bar, which may otherwise be as tall as the screen.
class VendorFormColumn extends StatelessWidget {
  const VendorFormColumn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!context.isTabletOrWider) return child;
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: vendorFormMaxWidth(context)),
        child: child,
      ),
    );
  }
}

/// Desktop onboarding is a two-pane wizard: a step rail on the left and the
/// form on the right, centred together at [kVendorWizardMaxWidth].
const double kVendorWizardMaxWidth = 1240;
const double kVendorRailWidth = 320;
const double kVendorRailGap = 24;
const double kVendorWizardGutter = 24;

/// The desktop two-pane frame: [rail] and [content] each scroll on their own,
/// so the steps stay in view while a long form scrolls.
class VendorWizardFrame extends StatelessWidget {
  const VendorWizardFrame({
    super.key,
    required this.rail,
    required this.content,
  });

  final List<Widget> rail;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets scrollPadding = EdgeInsets.only(top: 20, bottom: 24);
    // Top-aligned, both panes the full height: each scrolls on its own.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kVendorWizardMaxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kVendorWizardGutter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: kVendorRailWidth,
                child: SingleChildScrollView(
                  padding: scrollPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: rail,
                  ),
                ),
              ),
              const SizedBox(width: kVendorRailGap),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: scrollPadding,
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lines a bottom bar's actions up with the form: under the content pane on
/// desktop, in the form column on a tablet. Sized to its child's height.
class VendorActionsAlignment extends StatelessWidget {
  const VendorActionsAlignment({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) return VendorFormColumn(child: child);
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kVendorWizardMaxWidth),
        child: Padding(
          // The bar's own 8px inset is outside this box, which is centred
          // exactly like [VendorWizardFrame]'s.
          padding: const EdgeInsets.symmetric(horizontal: kVendorWizardGutter),
          child: Row(
            children: <Widget>[
              const SizedBox(width: kVendorRailWidth + kVendorRailGap),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
