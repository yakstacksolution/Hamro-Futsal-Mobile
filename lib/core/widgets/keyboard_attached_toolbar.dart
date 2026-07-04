// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class KeyboardAttachedToolbar extends StatelessWidget {
  final QuillController controller;

  const KeyboardAttachedToolbar({super.key, required this.controller});

  QuillIconTheme get _iconTheme => QuillIconTheme(
    iconButtonSelectedData: IconButtonData(
      color: LightColor.secondaryColor,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          LightColor.secondaryLight.withValues(alpha: 0.18),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
        ),
      ),
    ),
    iconButtonUnselectedData: IconButtonData(
      color: LightColor.primaryTextColor,
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
        ),
      ),
    ),
  );

  QuillToolbarToggleStyleButtonOptions get _toggleButtonOptions =>
      QuillToolbarToggleStyleButtonOptions(
        iconSize: AppDimens.sizeX12,
        iconTheme: _iconTheme,
      );

  QuillToolbarHistoryButtonOptions get _historyButtonOptions =>
      QuillToolbarHistoryButtonOptions(
        iconSize: AppDimens.sizeX12,
        iconTheme: _iconTheme,
      );

  QuillToolbarClearFormatButtonOptions get _clearFormatButtonOptions =>
      QuillToolbarClearFormatButtonOptions(
        iconSize: AppDimens.sizeX12,
        iconTheme: _iconTheme,
      );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        elevation: 0,
        color: LightColor.cardColor,
        child: SizedBox(
          width: double.infinity,
          child: ColoredBox(
            color: LightColor.whiteColor,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuillButton(
                        child: QuillToolbarHistoryButton(
                          options: _historyButtonOptions,
                          controller: controller,
                          isUndo: true,
                        ),
                        tooltip: StringConstants.undo,
                      ),
                      _buildQuillButton(
                        child: QuillToolbarHistoryButton(
                          options: _historyButtonOptions,
                          controller: controller,
                          isUndo: false,
                        ),
                        tooltip: StringConstants.redo,
                      ),
                      _buildQuillButton(
                        child: QuillToolbarToggleStyleButton(
                          options: _toggleButtonOptions,
                          attribute: Attribute.bold,
                          controller: controller,
                        ),
                        tooltip: StringConstants.bold,
                      ),
                      _buildQuillButton(
                        child: QuillToolbarToggleStyleButton(
                          options: _toggleButtonOptions,
                          attribute: Attribute.italic,
                          controller: controller,
                        ),
                        tooltip: StringConstants.italic,
                      ),
                      _buildQuillButton(
                        child: QuillToolbarToggleStyleButton(
                          options: _toggleButtonOptions,
                          attribute: Attribute.underline,
                          controller: controller,
                        ),
                        tooltip: StringConstants.underline,
                      ),
                      _buildQuillButton(
                        child: QuillToolbarToggleStyleButton(
                          options: _toggleButtonOptions,
                          attribute: Attribute.strikeThrough,
                          controller: controller,
                        ),
                        tooltip: StringConstants.strikethrough,
                      ),
                      _buildIconButton(
                        icon: Icons.link,
                        tooltip: StringConstants.link,
                        onTap: () => _showLinkDialog(context),
                        context: context,
                      ),
                    ],
                  ),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuillButton(
                        child: QuillToolbarToggleStyleButton(
                          options: _toggleButtonOptions,
                          attribute: Attribute.ul,
                          controller: controller,
                        ),
                        tooltip: StringConstants.bulletList,
                      ),
                      _buildQuillButton(
                        child: QuillToolbarToggleStyleButton(
                          options: _toggleButtonOptions,
                          attribute: Attribute.ol,
                          controller: controller,
                        ),
                        tooltip: StringConstants.numberedList,
                      ),
                      _buildQuillButton(
                        child: QuillToolbarToggleStyleButton(
                          options: _toggleButtonOptions,
                          attribute: Attribute.blockQuote,
                          controller: controller,
                        ),
                        tooltip: StringConstants.quote,
                      ),
                      _buildIconButton(
                        icon: Icons.code,
                        tooltip: StringConstants.code,
                        onTap: () =>
                            controller.formatSelection(Attribute.codeBlock),
                        context: context,
                      ),
                      _buildIconButton(
                        icon: Icons.format_color_text,
                        tooltip: StringConstants.textColor,
                        onTap: () => _showColorPicker(context, false),
                        context: context,
                      ),
                      _buildIconButton(
                        icon: Icons.format_color_fill,
                        tooltip: StringConstants.backgroundColor,
                        onTap: () => _showColorPicker(context, true),
                        context: context,
                      ),
                      _buildQuillButton(
                        child: QuillToolbarClearFormatButton(
                          options: _clearFormatButtonOptions,
                          controller: controller,
                        ),
                        tooltip: StringConstants.clearFormat,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuillButton({required Widget child, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: LightColor.secondaryColor),
          ),
        ),
      ),
    );
  }

  void _showLinkDialog(BuildContext context) {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(StringConstants.insertLink),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: StringConstants.urlExample,
                labelText: StringConstants.url,
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(StringConstants.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                final selection = controller.selection;
                if (selection.isCollapsed) {
                  controller.replaceText(
                    selection.start,
                    selection.end,
                    urlController.text,
                    null,
                  );
                  controller.formatText(
                    selection.start,
                    urlController.text.length,
                    LinkAttribute(urlController.text),
                  );
                } else {
                  controller.formatSelection(LinkAttribute(urlController.text));
                }
                Navigator.pop(context);
              }
            },
            child: const Text(StringConstants.insert),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, bool isBackground) {
    final colors = [
      {'name': 'Black', 'color': Colors.black},
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Blue', 'color': Colors.green},
      {'name': 'Yellow', 'color': Colors.yellow},
      {'name': 'Orange', 'color': Colors.orange},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Grey', 'color': Colors.grey},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isBackground ? 'Select Background Color' : 'Select Text Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((colorData) {
                return InkWell(
                  onTap: () {
                    final color = (colorData['color'] as Color);
                    final hex =
                        '#${color.value.toRadixString(16).substring(2)}';

                    if (isBackground) {
                      controller.formatSelection(
                        Attribute('background', AttributeScope.inline, hex),
                      );
                    } else {
                      controller.formatSelection(
                        Attribute('color', AttributeScope.inline, hex),
                      );
                    }

                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorData['color'] as Color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
