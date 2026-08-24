import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';

/// A dropdown that looks exactly like [CustomTextField] and opens its menu
/// *below* the field instead of over it.
///
/// Material's `DropdownButtonFormField` positions its menu so the selected row
/// lands on top of the button, which covers the field and the label above it.
/// This widget keeps the same API — including [DropdownMenuItem] children, so
/// call sites did not change — but anchors an overlay panel to the bottom edge
/// of the field. It always opens downwards — when the room below is tight the
/// panel shortens and its rows scroll rather than flipping over the field.
class CustomDropdownField<T> extends StatefulWidget {
  const CustomDropdownField({
    super.key,
    required this.labelText,
    required this.items,
    this.icon,
    this.hintText,
    this.initialValue,
    this.focusNode,
    this.autovalidateMode,
    this.validator,
    this.onChanged,
    this.dropdownColor,
    this.contentPadding,
    this.isExpanded = true,
    this.enabled = true,
    this.isRequired = false,
    this.menuMaxHeight = AppDimens.sizeX250,
  });

  final String labelText;
  final IconData? icon;
  final String? hintText;
  final T? initialValue;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;
  final FormFieldValidator<T>? validator;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;
  final Color? dropdownColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool isExpanded;
  final bool enabled;
  final bool isRequired;

  /// Tallest the open panel may get before its rows scroll.
  final double menuMaxHeight;

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _menu = OverlayPortalController();
  final GlobalKey _fieldKey = GlobalKey();

  FocusNode? _ownedFocusNode;
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  T? _value;

  /// Kept between frames so the panel can be sized without measuring the
  /// field again while it is open.
  double _fieldWidth = 0;
  double _availableHeight = AppDimens.sizeX250;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(CustomDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent owns the value: a rebuild with a different `initialValue`
    // (a cleared form, a dependent list reset) must win over the local copy.
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _value) {
      _value = widget.initialValue;
    }
    if (!widget.enabled && _menu.isShowing) _menu.hide();
  }

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  DropdownMenuItem<T>? get _selectedItem {
    for (final DropdownMenuItem<T> item in widget.items) {
      if (item.value == _value) return item;
    }
    return null;
  }

  void _toggle(FormFieldState<T> field) {
    if (!widget.enabled || widget.items.isEmpty) return;
    if (_menu.isShowing) {
      _menu.hide();
      setState(() {});
      return;
    }
    _measure();
    _focusNode.requestFocus();
    _menu.show();
    setState(() {});
  }

  /// Works out the panel's width and how tall it may get below the field.
  void _measure() {
    final RenderBox? box =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double fieldBottom =
        box.localToGlobal(Offset.zero).dy + box.size.height;
    final double spaceBelow =
        screenHeight -
        bottomInset -
        bottomPadding -
        fieldBottom -
        AppDimens.paddingX16;
    _fieldWidth = box.size.width;
    // Never flip over the field: a tight fit shortens the panel and lets its
    // rows scroll instead, so the field and its label stay visible.
    _availableHeight = spaceBelow < AppDimens.sizeX120
        ? AppDimens.sizeX120
        : (spaceBelow < widget.menuMaxHeight
              ? spaceBelow
              : widget.menuMaxHeight);
  }

  void _select(FormFieldState<T> field, T? value) {
    _menu.hide();
    setState(() => _value = value);
    field.didChange(value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);

    final TextStyle valueStyle =
        textTheme.bodyTextLarge?.copyWith(
          color: LightColor.primaryTextColor,
          fontSize: AppDimens.fontBodyTextSmall,
          fontWeight: FontWeight.w400,
        ) ??
        const TextStyle();

    final TextStyle hintStyle =
        textTheme.bodyTextMedium?.copyWith(
          color: LightColor.secondaryTextColor,
          fontSize: AppDimens.sizeX12,
          fontWeight: FontWeight.w400,
        ) ??
        const TextStyle();

    return FormField<T>(
      initialValue: widget.initialValue,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      enabled: widget.enabled,
      builder: (FormFieldState<T> field) {
        // FormField keeps its own copy of the value; a parent-driven reset
        // arrives through didUpdateWidget, so mirror it back onto the field.
        if (field.value != _value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && field.value != _value) field.didChange(_value);
          });
        }

        final DropdownMenuItem<T>? selected = _selectedItem;

        return CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _menu,
            overlayChildBuilder: (BuildContext overlayContext) =>
                _MenuOverlay<T>(
                  link: _link,
                  width: _fieldWidth,
                  maxHeight: _availableHeight,
                  background: widget.dropdownColor ?? LightColor.background,
                  items: widget.items,
                  selectedValue: _value,
                  onDismiss: () {
                    _menu.hide();
                    setState(() {});
                  },
                  onSelected: (T? value) => _select(field, value),
                ),
            child: Focus(
              focusNode: _focusNode,
              canRequestFocus: widget.enabled,
              child: GestureDetector(
                key: _fieldKey,
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggle(field),
                child: InputDecorator(
                  decoration:
                      customTextFieldDecoration(
                        context: context,
                        labelText: widget.labelText,
                        isRequired: widget.isRequired,
                        icon: widget.icon,
                      ).copyWith(
                        contentPadding:
                            widget.contentPadding ??
                            appUtils.getPadding(
                              symmetricHorizontal: AppDimens.paddingX12,
                              symmetricVertical: AppDimens.paddingX10,
                            ),
                        errorText: field.errorText,
                        enabled: widget.enabled,
                      ),
                  isFocused: _focusNode.hasFocus || _menu.isShowing,
                  isEmpty: selected == null,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: selected == null
                            ? Text(
                                widget.hintText ?? '',
                                style: hintStyle,
                                overflow: TextOverflow.ellipsis,
                              )
                            : DefaultTextStyle.merge(
                                style: valueStyle,
                                overflow: TextOverflow.ellipsis,
                                child: Align(
                                  alignment: widget.isExpanded
                                      ? AlignmentDirectional.centerStart
                                      : AlignmentDirectional.center,
                                  child: selected.child,
                                ),
                              ),
                      ),
                      AnimatedRotation(
                        turns: _menu.isShowing ? 0.5 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: LightColor.secondaryTextColor,
                          size: AppDimens.sizeX18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The open panel: a full-screen dismiss layer with the list anchored to the
/// field's bottom edge.
class _MenuOverlay<T> extends StatelessWidget {
  const _MenuOverlay({
    required this.link,
    required this.width,
    required this.maxHeight,
    required this.background,
    required this.items,
    required this.selectedValue,
    required this.onDismiss,
    required this.onSelected,
  });

  final LayerLink link;
  final double width;
  final double maxHeight;
  final Color background;
  final List<DropdownMenuItem<T>> items;
  final T? selectedValue;
  final VoidCallback onDismiss;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Tapping anywhere outside the panel closes it, the same way the
        // Material menu's barrier behaves.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, AppDimens.paddingX4),
          child: SizedBox(
            width: width > 0 ? width : null,
            child: Material(
              color: background,
              elevation: 8,
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX4),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, int i) {
                    final DropdownMenuItem<T> item = items[i];
                    final bool isSelected = item.value == selectedValue;
                    return InkWell(
                      onTap: item.enabled
                          ? () {
                              item.onTap?.call();
                              onSelected(item.value);
                            }
                          : null,
                      child: Container(
                        color: isSelected
                            ? LightColor.secondaryColor.withValues(alpha: 0.12)
                            : null,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingX12,
                          vertical: AppDimens.paddingX12,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: item.child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
