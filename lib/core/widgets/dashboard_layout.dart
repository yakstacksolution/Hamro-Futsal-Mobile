import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

/// Section heading for the tablet / desktop dashboards, flush with the edge of
/// the card below it.
class DashboardSectionLabel extends StatelessWidget {
  const DashboardSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX10),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }
}

/// Two labelled cards side by side whose tops *and* bottoms line up — the
/// standard dashboard row. With [stacked] they sit one above the other
/// instead (tablet), each at its natural height.
class DashboardPair extends StatelessWidget {
  const DashboardPair({
    super.key,
    required this.leftLabel,
    required this.left,
    required this.rightLabel,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.gap = AppDimens.paddingX18,
    this.stacked = false,
  });

  final String leftLabel;
  final Widget left;
  final String rightLabel;
  final Widget right;
  final int leftFlex;
  final int rightFlex;
  final double gap;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DashboardSectionLabel(leftLabel),
          left,
          SizedBox(height: gap),
          DashboardSectionLabel(rightLabel),
          right,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Labels share one row, at the cards' column widths.
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(flex: leftFlex, child: DashboardSectionLabel(leftLabel)),
            SizedBox(width: gap),
            Expanded(flex: rightFlex, child: DashboardSectionLabel(rightLabel)),
          ],
        ),
        DashboardEqualHeightRow(
          flexes: <int>[leftFlex, rightFlex],
          gap: gap,
          children: <Widget>[left, right],
        ),
      ],
    );
  }
}

/// Lays [children] out side by side in [flexes] proportions, every child as
/// tall as the tallest one, so a row of cards shares its top and bottom edge.
///
/// `IntrinsicHeight` cannot do this here: cards built on `LayoutBuilder` or a
/// shrink-wrapped grid cannot report an intrinsic height. Instead each child
/// is laid out once at its column width to measure it, then again at the
/// row's height. A card given the extra height simply grows, its content
/// staying at the top.
class DashboardEqualHeightRow extends MultiChildRenderObjectWidget {
  const DashboardEqualHeightRow({
    super.key,
    required this.flexes,
    required super.children,
    this.gap = AppDimens.paddingX18,
  }) : assert(flexes.length == children.length);

  final List<int> flexes;
  final double gap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderDashboardEqualHeightRow(flexes: flexes, gap: gap);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDashboardEqualHeightRow renderObject,
  ) {
    renderObject
      ..flexes = flexes
      ..gap = gap;
  }
}

class _EqualHeightParentData extends ContainerBoxParentData<RenderBox> {}

class RenderDashboardEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualHeightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualHeightParentData> {
  RenderDashboardEqualHeightRow({required List<int> flexes, required double gap})
    : _flexes = flexes,
      _gap = gap;

  List<int> _flexes;
  set flexes(List<int> value) {
    if (_flexes == value) return;
    _flexes = value;
    markNeedsLayout();
  }

  double _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EqualHeightParentData) {
      child.parentData = _EqualHeightParentData();
    }
  }

  List<double> _widths(double total) {
    final int count = childCount;
    final int flexSum = _flexes
        .take(count)
        .fold<int>(0, (int a, int b) => a + b);
    final double free = math.max(0, total - _gap * (count - 1));
    return <double>[
      for (int i = 0; i < count; i++)
        flexSum == 0 ? free / count : free * _flexes[i] / flexSum,
    ];
  }

  @override
  void performLayout() {
    final double width = constraints.maxWidth;
    final List<double> widths = _widths(width);

    // Pass 1: natural height of each child at its column width.
    double tallest = 0;
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      child.layout(
        BoxConstraints(minWidth: widths[i], maxWidth: widths[i]),
        parentUsesSize: true,
      );
      tallest = math.max(tallest, child.size.height);
      child = childAfter(child);
      i++;
    }

    // Pass 2: every child at the row's height, placed left to right.
    double x = 0;
    child = firstChild;
    i = 0;
    while (child != null) {
      child.layout(
        BoxConstraints.tightFor(width: widths[i], height: tallest),
        parentUsesSize: true,
      );
      (child.parentData! as _EqualHeightParentData).offset = Offset(x, 0);
      x += widths[i] + _gap;
      child = childAfter(child);
      i++;
    }
    size = constraints.constrain(Size(width, tallest));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
