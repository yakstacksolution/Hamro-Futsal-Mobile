import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/keyboard_attached_toolbar.dart';

typedef FutureStringCallback = Future<String> Function(String htmlText);

// Design tokens
class _EditorTokens {
  static const double radiusSm = 8;
  static const double toolbarDividerWidth = 1;
  static const double fieldRadius = 8;
  static const Color fieldFill = Color(0xFFFBFCFE);
  static const Color toolbarFill = Color(0xFFFDFEFF);

  static const EdgeInsets editorPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
  static const EdgeInsets hintPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.scrollController.hasClients || !mounted) return;
      final offset = widget.scrollController.offset;
      final maxScroll = widget.scrollController.position.maxScrollExtent;
      if (maxScroll - offset < 150) {
        widget.scrollController.animateTo(
          maxScroll,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusAnim.dispose();
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
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
                          child: QuillEditor(
                            controller: widget.controller,
                            scrollController: widget.scrollController,
                            focusNode: _focusNode,
                            config: _buildEditorConfig(context),
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
      searchConfig: const QuillSearchConfig(
        searchEmbedMode: SearchEmbedMode.plainText,
      ),
      customStyles: DefaultStyles(
        paragraph: DefaultTextBlockStyle(
          TextStyle(
            fontSize: 15.5,
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
          color: LightColor.primary,
          decoration: TextDecoration.underline,
          decorationColor: LightColor.primary.withValues(alpha: 0.5),
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
      TextStyle(
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
        color: _EditorTokens.toolbarFill,
        border: Border(
          bottom: BorderSide(
            color: LightColor.borderLight,
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
    final cs = Theme.of(context).colorScheme;
    final focusBorderColor = Color.lerp(
      LightColor.lightGrey.withValues(alpha: 0.95),
      cs.primary.withValues(alpha: 0.92),
      focusProgress,
    )!;

    return AnimatedContainer(
      duration: _EditorTokens.animDuration,
      curve: _EditorTokens.animCurve,
      decoration: BoxDecoration(
        color: _EditorTokens.fieldFill,
        borderRadius: BorderRadius.circular(_EditorTokens.fieldRadius),
        border: Border.all(
          color: focusBorderColor,
          width: lerpDouble(1.0, 1.5, focusProgress),
        ),
        boxShadow: focusProgress > 0
            ? [
                BoxShadow(
                  color: LightColor.secondaryLight.withValues(
                    alpha: 0.08 * focusProgress,
                  ),
                  blurRadius: 18,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated hint overlay
// ─────────────────────────────────────────────────────────────────────────────
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
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.65,
                  letterSpacing: 0.1,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                  fontStyle: FontStyle.italic,
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

// ─────────────────────────────────────────────────────────────────────────────
// Timestamp embed builder
// ─────────────────────────────────────────────────────────────────────────────
class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) => node.value.data as String;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, size: 13, color: cs.primary),
              const SizedBox(width: 5),
              Text(
                embedContext.node.value.data as String,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 12.5,
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

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:hamro_footsall/core/widgets/keyboard_attached_toolbar.dart';

// typedef FutureStringCallback = Future<String> Function(String htmlText);

// class CustomQuillEditor extends StatefulWidget {
//   final String? initialContent;
//   final FutureStringCallback? onContentChanged;
//   final bool isReadOnly;
//   final QuillController controller;
//   final ScrollController scrollController;
//   final String? hintText;

//   const CustomQuillEditor({
//     super.key,
//     this.initialContent,
//     this.onContentChanged,
//     required this.isReadOnly,
//     required this.controller,
//     required this.scrollController,
//     this.hintText,
//   });

//   @override
//   State<CustomQuillEditor> createState() => _CustomQuillEditorState();
// }

// class _CustomQuillEditorState extends State<CustomQuillEditor> {
//   final FocusNode _focusNode = FocusNode();
//   bool _showHint = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkIfEmpty();
//     widget.controller.addListener(_onTextChanged);
//   }

//   void _checkIfEmpty() {
//     final plainText = widget.controller.document.toPlainText();
//     final isEmpty = plainText.trim().isEmpty || plainText == '\n';
//     if (_showHint != isEmpty) {
//       setState(() {
//         _showHint = isEmpty;
//       });
//     }
//   }

//   void _onTextChanged() {
//     _checkIfEmpty();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (widget.scrollController.hasClients && mounted) {
//         final currentScroll = widget.scrollController.offset;
//         final maxScroll = widget.scrollController.position.maxScrollExtent;

//         if (maxScroll - currentScroll < 150) {
//           widget.scrollController.animateTo(
//             maxScroll,
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeOut,
//           );
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     widget.controller.removeListener(_onTextChanged);
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       resizeToAvoidBottomInset: true,
//       body: Column(
//         children: [
//           KeyboardAttachedToolbar(controller: widget.controller),
//           SizedBox(height: 2),
//           Expanded(
//             child: Container(
//               decoration: _editorDecoration(),
//               child: Stack(
//                 children: [
//                   if (_showHint && widget.hintText != null)
//                     Positioned.fill(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: IgnorePointer(
//                           child: Align(
//                             alignment: Alignment.topLeft,
//                             child: Text(
//                               widget.hintText!,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 height: 1.5,
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .onSurfaceVariant
//                                     .withValues(alpha: 0.6),
//                                 fontStyle: FontStyle.italic,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   CupertinoScrollbar(
//                     controller: widget.scrollController,
//                     child: QuillEditor(
//                       controller: widget.controller,
//                       scrollController: widget.scrollController,
//                       focusNode: _focusNode,
//                       config: _editorConfig(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   BoxDecoration _editorDecoration() {
//     return BoxDecoration(
//       color: Theme.of(context).colorScheme.surface,
//       borderRadius: BorderRadius.circular(8),
//     );
//   }

//   QuillEditorConfig _editorConfig() {
//     final theme = Theme.of(context);
//     return QuillEditorConfig(
//       scrollable: true,
//       expands: false,
//       scrollBottomInset: 50,
//       detectWordBoundary: true,
//       searchConfig: QuillSearchConfig(
//         searchEmbedMode: SearchEmbedMode.plainText,
//       ),
//       autoFocus: false,
//       showCursor: true,
//       padding: const EdgeInsets.all(16),
//       customStyles: DefaultStyles(
//         paragraph: DefaultTextBlockStyle(
//           TextStyle(
//             fontSize: 16,
//             height: 1.5,
//             color: theme.colorScheme.onSurface,
//           ),
//           const HorizontalSpacing(2, 8),
//           const VerticalSpacing(0, 0),
//           const VerticalSpacing(0, 0),
//           null,
//         ),
//         bold: const TextStyle(fontWeight: FontWeight.bold),
//         italic: const TextStyle(fontStyle: FontStyle.italic),
//         underline: const TextStyle(decoration: TextDecoration.underline),
//         strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
//         link: TextStyle(
//           color: theme.colorScheme.primary,
//           decoration: TextDecoration.underline,
//         ),
//         h1: DefaultTextBlockStyle(
//           TextStyle(
//             fontSize: 28,
//             height: 1.3,
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//           const HorizontalSpacing(0, 0),
//           const VerticalSpacing(16, 8),
//           const VerticalSpacing(0, 0),
//           null,
//         ),
//         h2: DefaultTextBlockStyle(
//           TextStyle(
//             fontSize: 24,
//             height: 1.3,
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//           const HorizontalSpacing(0, 0),
//           const VerticalSpacing(12, 8),
//           const VerticalSpacing(0, 0),
//           null,
//         ),
//         h3: DefaultTextBlockStyle(
//           TextStyle(
//             fontSize: 20,
//             height: 1.3,
//             fontWeight: FontWeight.w600,
//             color: theme.colorScheme.onSurface,
//           ),
//           const HorizontalSpacing(0, 0),
//           const VerticalSpacing(10, 6),
//           const VerticalSpacing(0, 0),
//           null,
//         ),
//       ),

//       embedBuilders: [
//         ...FlutterQuillEmbeds.editorBuilders(),
//         TimeStampEmbedBuilder(),
//       ],
//     );
//   }
// }

// class TimeStampEmbedBuilder extends EmbedBuilder {
//   @override
//   String get key => 'timeStamp';

//   @override
//   String toPlainText(Embed node) {
//     return node.value.data;
//   }

//   @override
//   Widget build(BuildContext context, EmbedContext embedContext) {
//     final theme = Theme.of(context);
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.access_time_rounded,
//             size: 16,
//             color: theme.colorScheme.onSurfaceVariant,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             embedContext.node.value.data as String,
//             style: TextStyle(
//               color: theme.colorScheme.onSurfaceVariant,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
