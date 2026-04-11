import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

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
    this.radius = AppDimens.radiusX30,
    this.backgroundColor = LightColor.cardColor,
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
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);

    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.14),
            blurRadius: AppDimens.radiusX28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding:
          padding ??
          appUtils.getPadding(
            left: AppDimens.paddingX18,
            top: AppDimens.paddingX12,
            right: AppDimens.paddingX18,
            bottom:
                AppDimens.paddingX18 +
                mediaQuery.viewInsets.bottom +
                mediaQuery.padding.bottom,
          ),
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
                    gradient: const LinearGradient(
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
    );

    if (useSafeArea) {
      content = SafeArea(top: false, child: content);
    }

    return content;
  }
}
