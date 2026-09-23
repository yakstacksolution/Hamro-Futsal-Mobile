import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

/// The row of OTP boxes, sized to fill the width it is given.
///
/// The boxes are sized from the space the card actually gives the row: up to
/// 56pt wide, near-square, tightly spaced and centred as one group.
///
/// Shared by OTP verification and the forgot-password reset screen so the two
/// code inputs cannot drift apart visually.
class OtpDigitRow extends StatelessWidget {
  const OtpDigitRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  }) : assert(controllers.length == focusNodes.length);

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  /// Called with the index of the box that changed and its new text.
  final void Function(int index, String value) onChanged;

  /// The size a box gets whenever there is room for it. Six boxes this wide
  /// exceed the width of a phone card, so it is an upper bound, not a promise.
  static const double _maxBoxWidth = AppDimens.sizeX56;

  /// The floor, reached only on a 320pt phone, where six boxes plus gutters
  /// cannot all be comfortable inside the card.
  static const double _minBoxWidth = AppDimens.sizeX32;

  static const double _heightRatio = 1.15;

  /// Even spacing between boxes; enough to tell them apart, tight enough that
  /// the six still read as one code.
  static const double _gap = AppDimens.sizeX8;

  /// The gutter a 320pt phone gets: at the full [_gap] the six boxes no longer
  /// fit inside the card there.
  static const double _tightGap = AppDimens.sizeX6;

  /// Below this the row switches to [_tightGap].
  static const double _tightLayoutWidth = 280;

  @override
  Widget build(BuildContext context) {
    final int length = controllers.length < focusNodes.length
        ? controllers.length
        : focusNodes.length;
    if (length == 0) return const SizedBox.shrink();

    return AutofillGroup(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double given = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : AppDimens.otpRowMaxWidth;
          // Strictly what the card gives us: reaching past it put the last
          // box under the card's rounded corner.
          final double available = given;
          final double gap = available < _tightLayoutWidth ? _tightGap : _gap;
          final double totalGap = gap * (length - 1);
          final double boxWidth = ((available - totalGap) / length).clamp(
            _minBoxWidth,
            _maxBoxWidth,
          );
          final double boxHeight = boxWidth * _heightRatio;
          final Widget row = Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(length * 2 - 1, (int slot) {
              if (slot.isOdd) return SizedBox(width: gap);
              final int index = slot ~/ 2;
              return OtpDigitField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                width: boxWidth,
                height: boxHeight,
                onChanged: (String value) => onChanged(index, value),
              );
            }),
          );

          return SizedBox(
            height: boxHeight,
            child: Center(child: row),
          );
        },
      ),
    );
  }
}

/// One box of an OTP row. Sized by its parent — see [OtpDigitRow].
class OtpDigitField extends StatelessWidget {
  const OtpDigitField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.width,
    this.height,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  /// Falls back to a fixed responsive size when used outside [OtpDigitRow].
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final double boxWidth = width ?? AppDimens.sizeX48;
    final double boxHeight = height ?? boxWidth * 1.1;
    // The digit is the whole point of the box, so it takes as much of it as it
    // can without touching the border.
    final double fontSize = (boxWidth * 0.66).clamp(
      AppDimens.fontHeadingSubTitle,
      AppDimens.fontHeadingMedium,
    );
    const double radius = AppDimens.radiusX6;
    final double borderWidth = 1.5;

    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      // Both the text and the focus drive the look: the box being edited is
      // outlined and clear, the rest sit quietly in a tinted fill.
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[controller, focusNode]),
        builder: (BuildContext context, _) {
          final bool isFocused = focusNode.hasFocus;
          final Color fill = isFocused
              ? LightColor.whiteColor
              : LightColor.inputFillColor;
          final Color border = isFocused
              ? LightColor.inputFocusBorderColor
              : LightColor.inputBorderColor;

          return TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.oneTimeCode],
            enableSuggestions: false,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            cursorColor: LightColor.primaryTextColor,
            style: textTheme.headingSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
              fontSize: fontSize,
              height: 1.0,
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              isDense: true,
              // `inputFillColor`/`inputBorderColor` are the tokens that carry
              // a usable contrast in both themes. The page background does
              // not: in dark mode it is the same near-black as the card, which
              // is what turned the row into six invisible slabs.
              fillColor: fill,
              // The box owns its height, so the field must not add padding of
              // its own — that is what pushed the digit off-centre.
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(color: border, width: borderWidth),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                  color: LightColor.inputFocusBorderColor,
                  width: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
