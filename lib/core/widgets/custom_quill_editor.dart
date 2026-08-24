import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/keyboard_attached_toolbar.dart';

typedef FutureStringCallback = Future<String> Function(String htmlText);

class _EditorTokens {
  static const double radiusSm = 8;
  static const double toolbarDividerWidth = 1;
  static Color get fieldFill => LightColor.inputFillColor;

  static EdgeInsets editorPadding = AppUtils().getPadding(
    symmetricHorizontal: AppDimens.paddingX14,
    symmetricVertical: AppDimens.paddingX12,
  );

  static EdgeInsets hintPadding = AppUtils().getPadding(
    symmetricHorizontal: AppDimens.paddingX14,
    symmetricVertical: AppDimens.paddingX14,
  );

  static const Duration animDuration = Duration(milliseconds: 220);
  static const Curve animCurve = Curves.easeInOut;
}

class CustomQuillEditor extends StatefulWidget {
  final String? initialContent;
  final FutureStringCallback? onContentChanged;
  final bool isReadOnly;
  final QuillController controller;
  final ScrollController scrollController;
  final String? hintText;

  const CustomQuillEditor({
    super.key,
    this.initialContent,
    this.onContentChanged,
    required this.isReadOnly,
    required this.controller,
    required this.scrollController,
    this.hintText,
  });

  @override
  State<CustomQuillEditor> createState() => _CustomQuillEditorState();
}

class _CustomQuillEditorState extends State<CustomQuillEditor>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _showHint = true;
  bool _isFocused = false;
  late final AnimationController _focusAnim;
  late final Animation<double> _borderOpacity;

  @override
  void initState() {
    super.initState();

    _focusAnim = AnimationController(
      vsync: this,
      duration: _EditorTokens.animDuration,
    );
    _borderOpacity = CurvedAnimation(
      parent: _focusAnim,
      curve: _EditorTokens.animCurve,
    );

    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
    _checkIfEmpty();
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (_isFocused == focused) return;
    setState(() => _isFocused = focused);
    focused ? _focusAnim.forward() : _focusAnim.reverse();
  }

  void _checkIfEmpty() {
    final plain = widget.controller.document.toPlainText();
    final empty = plain.trim().isEmpty || plain == '\n';
    if (_showHint != empty) setState(() => _showHint = empty);
  }

  void _onTextChanged() {
    _checkIfEmpty();
  }

  @override
  void dispose() {
    _focusAnim.dispose();
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextSelectionThemeData selectionTheme = TextSelectionThemeData(
      cursorColor: LightColor.primaryTextColor,
      selectionColor: LightColor.primaryTextColor.withValues(alpha: 0.18),
      selectionHandleColor: LightColor.primaryTextColor,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _borderOpacity,
              builder: (context, child) => _EditorCard(
                focusProgress: _borderOpacity.value,
                child: child!,
              ),
              child: Column(
                children: [
                  _EmbeddedToolbar(controller: widget.controller),
                  Expanded(
                    child: Stack(
                      children: [
                        if (_showHint && widget.hintText != null)
                          _HintOverlay(text: widget.hintText!),
                        CupertinoScrollbar(
                          controller: widget.scrollController,
                          child: TextSelectionTheme(
                            data: selectionTheme,
                            child: QuillEditor(
                              controller: widget.controller,
                              scrollController: widget.scrollController,
                              focusNode: _focusNode,
                              config: _buildEditorConfig(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  QuillEditorConfig _buildEditorConfig(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return QuillEditorConfig(
      scrollable: true,
      expands: false,
      scrollBottomInset: 56,
      detectWordBoundary: true,
      autoFocus: false,
      showCursor: true,
      padding: _EditorTokens.editorPadding,
      // flutter_quill still marks its supported search configuration as
      // experimental; this is intentionally pinned to the current API.
      // ignore: experimental_member_use
      searchConfig: const QuillSearchConfig(
        // ignore: experimental_member_use
        searchEmbedMode: SearchEmbedMode.plainText,
      ),
      customStyles: DefaultStyles(
        paragraph: DefaultTextBlockStyle(
          FutsalTheme.getTextTheme(context).bodyTextMedium!.copyWith(
            height: 1.65,
            letterSpacing: 0.1,
            color: cs.onSurface,
          ),

          const HorizontalSpacing(0, 0),
          const VerticalSpacing(0, 0),
          const VerticalSpacing(0, 0),
          null,
        ),
        bold: const TextStyle(fontWeight: FontWeight.w700),
        italic: const TextStyle(fontStyle: FontStyle.italic),
        underline: const TextStyle(decoration: TextDecoration.underline),
        strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
        link: TextStyle(
          color: LightColor.secondaryColor,
          decoration: TextDecoration.underline,
          decorationColor: LightColor.secondaryColor.withValues(alpha: 0.5),
        ),
        h1: _headingStyle(cs, 26, FontWeight.w800, 20, 10),
        h2: _headingStyle(cs, 22, FontWeight.w700, 16, 8),
        h3: _headingStyle(cs, 18, FontWeight.w600, 12, 6),
      ),
      embedBuilders: [
        ...FlutterQuillEmbeds.editorBuilders(),
        TimeStampEmbedBuilder(),
      ],
    );
  }

  DefaultTextBlockStyle _headingStyle(
    ColorScheme cs,
    double size,
    FontWeight weight,
    double vTop,
    double vBottom,
  ) {
    return DefaultTextBlockStyle(
      FutsalTheme.getTextTheme(context).bodyTextLarge!.copyWith(
        fontSize: size,
        height: 1.3,
        fontWeight: weight,
        letterSpacing: -0.4,
        color: cs.onSurface,
      ),
      const HorizontalSpacing(0, 0),
      VerticalSpacing(vTop, vBottom),
      const VerticalSpacing(0, 0),
      null,
    );
  }
}

class _EmbeddedToolbar extends StatelessWidget {
  final QuillController controller;
  const _EmbeddedToolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(
          bottom: BorderSide(
            color: LightColor.greyBorderColor,
            width: _EditorTokens.toolbarDividerWidth,
          ),
        ),
      ),
      child: KeyboardAttachedToolbar(controller: controller),
    );
  }
}

class _EditorCard extends StatelessWidget {
  final double focusProgress;
  final Widget child;

  const _EditorCard({required this.focusProgress, required this.child});

  @override
  Widget build(BuildContext context) {
    final Color focusBorderColor = LightColor.greyBorderColor;

    return AnimatedContainer(
      duration: _EditorTokens.animDuration,
      curve: _EditorTokens.animCurve,
      decoration: BoxDecoration(
        color: _EditorTokens.fieldFill,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: focusBorderColor, width: 1.15),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _HintOverlay extends StatelessWidget {
  final String text;
  const _HintOverlay({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: Padding(
        padding: _EditorTokens.hintPadding,
        child: IgnorePointer(
          child: Align(
            alignment: Alignment.topLeft,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: _EditorTokens.animDuration,
              child: Text(
                text,
                style: FutsalTheme.getTextTheme(context).bodyTextMedium
                    ?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) => node.value.data as String;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX2,
        symmetricVertical: AppDimens.paddingX4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(_EditorTokens.radiusSm),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.18),
            width: 0.8,
          ),
        ),
        child: Padding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX8,
            symmetricVertical: AppDimens.paddingX2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: AppDimens.sizeX14,
                color: cs.primary,
              ),
              const SizedBox(width: AppDimens.sizeX4),
              Text(
                embedContext.node.value.data as String,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
