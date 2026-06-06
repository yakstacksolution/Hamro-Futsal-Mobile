import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

/// Conversation search box with an inline clear action.
class MessageSearchField extends StatelessWidget {
  const MessageSearchField({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return SizedBox(
      height: 40,
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
          fillColor: LightColor.whiteColor,
          hintText: 'Search conversations',
          hintStyle: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.hintTextColor,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: LightColor.iconGrey,
            size: AppDimens.sizeX18,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: query.isEmpty
              ? null
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClear,
                  child: const Icon(
                    Icons.close_rounded,
                    color: LightColor.iconGrey,
                    size: AppDimens.sizeX16,
                  ),
                ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 40,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            borderSide: const BorderSide(color: LightColor.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            borderSide: const BorderSide(color: LightColor.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            borderSide: const BorderSide(
              color: LightColor.secondaryColor,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
