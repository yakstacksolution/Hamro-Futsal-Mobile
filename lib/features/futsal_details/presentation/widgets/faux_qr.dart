import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

/// A decorative, QR-looking code rendered from [data]. It is NOT a scannable
/// QR — it stands in for the company's payment QR image until a real QR asset
/// or URL is wired up. The pattern is deterministic for a given [data] string,
/// with the three finder squares a real QR has.
class FauxQr extends StatelessWidget {
  const FauxQr({
    super.key,
    required this.data,
    this.size = 160,
    this.modules = 25,
  });

  final String data;
  final double size;
  final int modules;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FauxQrPainter(data: data, modules: modules),
      ),
    );
  }
}

class _FauxQrPainter extends CustomPainter {
  _FauxQrPainter({required this.data, required this.modules});

  final String data;
  final int modules;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dark = Paint()..color = LightColor.primaryTextColor;
    final double cell = size.width / modules;
    final int seed = _seedFrom(data);

    for (int y = 0; y < modules; y++) {
      for (int x = 0; x < modules; x++) {
        if (_isFinderZone(x, y)) continue;
        // Deterministic pseudo-random fill based on cell position + seed.
        final int v = (x * 73856093) ^ (y * 19349663) ^ seed;
        if ((v & 0x7) > 3) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell * 0.92, cell * 0.92),
            dark,
          );
        }
      }
    }

    // Three finder patterns: top-left, top-right, bottom-left.
    _drawFinder(canvas, 0, 0, cell, dark);
    _drawFinder(canvas, (modules - 7) * cell, 0, cell, dark);
    _drawFinder(canvas, 0, (modules - 7) * cell, cell, dark);
  }

  bool _isFinderZone(int x, int y) {
    const int f = 8;
    final bool topLeft = x < f && y < f;
    final bool topRight = x >= modules - f && y < f;
    final bool bottomLeft = x < f && y >= modules - f;
    return topLeft || topRight || bottomLeft;
  }

  void _drawFinder(
    Canvas canvas,
    double left,
    double top,
    double cell,
    Paint dark,
  ) {
    final Paint light = Paint()..color = LightColor.whiteColor;
    // Outer 7x7 dark square.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, cell * 7, cell * 7),
        Radius.circular(cell),
      ),
      dark,
    );
    // Inner 5x5 light square.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + cell, top + cell, cell * 5, cell * 5),
        Radius.circular(cell * 0.7),
      ),
      light,
    );
    // Center 3x3 dark square.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + cell * 2, top + cell * 2, cell * 3, cell * 3),
        Radius.circular(cell * 0.5),
      ),
      dark,
    );
  }

  int _seedFrom(String value) {
    int hash = 7;
    for (int i = 0; i < value.length; i++) {
      hash = (hash * 31 + value.codeUnitAt(i)) & 0x7fffffff;
    }
    return hash;
  }

  @override
  bool shouldRepaint(covariant _FauxQrPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.modules != modules;
}
