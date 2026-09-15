import 'dart:math' as math;

import 'package:flutter/material.dart';

class CenteredHorizontalSelectionRow extends StatefulWidget {
  const CenteredHorizontalSelectionRow({
    super.key,
    required this.itemCount,
    required this.selectedIndex,
    required this.itemBuilder,
    this.spacing = 8,
    this.physics = const BouncingScrollPhysics(),
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
  });

  final int itemCount;
  final int selectedIndex;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;
  final ScrollPhysics physics;
  final Duration duration;
  final Curve curve;

  @override
  State<CenteredHorizontalSelectionRow> createState() =>
      _CenteredHorizontalSelectionRowState();
}

class _CenteredHorizontalSelectionRowState
    extends State<CenteredHorizontalSelectionRow> {
  final ScrollController _controller = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _itemKeys = List<GlobalKey>.generate(widget.itemCount, (_) => GlobalKey());
    _scheduleCenterSelected();
  }

  @override
  void didUpdateWidget(CenteredHorizontalSelectionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _itemKeys = List<GlobalKey>.generate(
        widget.itemCount,
        (_) => GlobalKey(),
      );
    }
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.itemCount != widget.itemCount) {
      _scheduleCenterSelected();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleCenterSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _centerSelected();
    });
  }

  void _centerSelected() {
    final int index = widget.selectedIndex;
    if (index < 0 || index >= _itemKeys.length || !_controller.hasClients) {
      return;
    }

    final BuildContext? itemContext = _itemKeys[index].currentContext;
    final BuildContext? viewportContext = _viewportKey.currentContext;
    final RenderBox? itemBox = itemContext?.findRenderObject() as RenderBox?;
    final RenderBox? viewportBox =
        viewportContext?.findRenderObject() as RenderBox?;
    if (itemBox == null || viewportBox == null) return;

    final double itemCenter = itemBox
        .localToGlobal(
          Offset(itemBox.size.width / 2, itemBox.size.height / 2),
          ancestor: viewportBox,
        )
        .dx;
    final ScrollPosition position = _controller.position;
    final double target =
        (_controller.offset + itemCenter - (viewportBox.size.width / 2)).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );

    if ((_controller.offset - target).abs() < 0.5) return;
    _controller.animateTo(
      target,
      duration: widget.duration,
      curve: widget.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: _viewportKey,
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: widget.physics,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < widget.itemCount; i++) ...<Widget>[
            KeyedSubtree(
              key: _itemKeys[i],
              child: widget.itemBuilder(context, i),
            ),
            if (i < widget.itemCount - 1)
              SizedBox(width: math.max(0, widget.spacing)),
          ],
        ],
      ),
    );
  }
}
