import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  Widget? child,
  WidgetBuilder? builder,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool wrapWithCustomSheet = true,
  Color? barrierColor,
  double bottomSpacing = AppDimens.paddingX18,
  Duration transitionDuration = const Duration(milliseconds: 280),
  Duration reverseTransitionDuration = const Duration(milliseconds: 220),
  Duration keyboardAnimationDuration = const Duration(milliseconds: 250),
  Curve keyboardAnimationCurve = Curves.easeOutCubic,
}) {
  assert(
    child != null || builder != null,
    'Either child or builder must be provided',
  );

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor ?? LightColor.scrimColor,
    sheetAnimationStyle: AnimationStyle(
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
    ),
    builder: (BuildContext sheetContext) {
      final Widget content = builder != null ? builder(sheetContext) : child!;
      final Widget sheet = wrapWithCustomSheet
          ? CustomBottomSheet(bottomSpacing: bottomSpacing, child: content)
          : content;

      return KeyboardAwareBottomSheet(
        duration: keyboardAnimationDuration,
        curve: keyboardAnimationCurve,
        child: sheet,
      );
    },
  );
}

/// Animates a bottom sheet with the system keyboard instead of jumping when
/// [MediaQueryData.viewInsets] changes.
///
/// Keep this widget outside the sheet's size constraint so the complete sheet
/// moves above the keyboard, rather than only adding padding inside its body.
class KeyboardAwareBottomSheet extends StatelessWidget {
  const KeyboardAwareBottomSheet({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: duration,
      curve: curve,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: child,
      ),
    );
  }
}

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
    this.showDragHandle = true,
    this.radius = AppDimens.radiusX14,
    this.backgroundColor,
    this.bottomSpacing = AppDimens.paddingX18,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final bool showDragHandle;
  final double radius;
  final Color? backgroundColor;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);

    final borderRadius = BorderRadius.vertical(top: Radius.circular(radius));
    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.14),
            blurRadius: AppDimens.radiusX28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor ?? context.appColors.surface,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding:
              padding ??
              appUtils.getPadding(
                left: AppDimens.paddingX18,
                top: AppDimens.paddingX12,
                right: AppDimens.paddingX18,
                bottom: bottomSpacing,
              ),
          // Icons default to the same on-surface colour as the sheet's text
          // (near-white in dark, near-black in light). Without this they fall
          // through to the global `iconTheme`, which is the muted secondary
          // tone and reads as washed-out on a dark sheet.
          child: IconTheme.merge(
            data: IconThemeData(color: context.appColors.primaryText),
            child: DefaultTextStyle(
              style:
                  textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                  ) ??
                  Theme.of(context).textTheme.bodyMedium ??
                  const TextStyle(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (showDragHandle)
                    Container(
                      margin: appUtils.getMargin(bottom: AppDimens.marginX12),
                      alignment: Alignment.center,
                      child: Container(
                        width: AppDimens.sizeX44,
                        height: AppDimens.sizeX4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              LightColor.dividerColor,
                              LightColor.secondaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (useSafeArea) {
      content = SafeArea(top: false, child: content);
    }

    return content;
  }
}
