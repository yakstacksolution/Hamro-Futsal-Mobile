import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  Widget? child,
  WidgetBuilder? builder,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool wrapWithCustomSheet = true,
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
    builder: (BuildContext sheetContext) {
      final Widget content = builder != null ? builder(sheetContext) : child!;
      if (wrapWithCustomSheet) {
        return CustomBottomSheet(child: content);
      }
      return content;
    },
  );
}

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
    this.showDragHandle = true,
    this.radius = 30,
    this.backgroundColor = LightColor.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final bool showDragHandle;
  final double radius;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.accentGreen.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding:
          padding ??
          EdgeInsets.fromLTRB(18, 12, 18, 18 + mediaQuery.viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showDragHandle)
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[LightColor.lightGrey, LightColor.secondary],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          if (showDragHandle) const SizedBox(height: 12),
          Flexible(child: child),
        ],
      ),
    );

    if (useSafeArea) {
      content = SafeArea(top: false, child: content);
    }

    return content;
  }
}
