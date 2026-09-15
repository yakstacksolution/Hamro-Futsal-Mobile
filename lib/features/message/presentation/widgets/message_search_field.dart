import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class MessageSearchField extends StatelessWidget {
  const MessageSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: LightColor.secondaryColor,
        textAlignVertical: TextAlignVertical.center,
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.primaryTextColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: context.appColors.inputFill,
          hintText: StringConstants.searchConversations,
          hintStyle: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.hintTextColor,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: LightColor.iconGrey,
            size: AppDimens.sizeX18,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          // Driven by the controller, not the (debounced) query, so the clear
          // affordance shows the moment the field has text.
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      color: LightColor.iconGrey,
                      size: AppDimens.sizeX16,
                    ),
                  ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 40,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          // Borderless — the rounded fill + soft shadow define the field.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
