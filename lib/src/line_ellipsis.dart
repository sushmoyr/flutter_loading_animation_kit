import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit_widget.dart';

class LineEllipsis extends StatelessWidget {
  const LineEllipsis(
      {Key? key,
      this.ellipseRadius = 8,
      this.speed = 5,
      this.curve = Curves.linear,
      this.ellipseColor,
      this.ellipseCount = 4})
      : super(key: key);

  final double ellipseRadius;
  final int ellipseCount;
  final Color? ellipseColor;
  final double speed;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return CanvasKit(
      delegate: _LineEllipsisDelegate(
        radius: ellipseRadius,
        count: ellipseCount,
        color: ellipseColor ?? Theme.of(context).colorScheme.primary,
        speed: speed,
        curve: curve,
      ),
      size: const Size.square(100),
    );
  }
}

class _LineEllipsisDelegate extends CanvasKitDelegate {
  final double radius;
  final int count;
  final Color color;
  static const _speedModifier = 20.0;
  final double speed;
  final Curve curve;

  _LineEllipsisDelegate({
    required this.radius,
    required this.count,
    required this.color,
    required this.speed,
    required this.curve,
  });

  @override
  void update(double t) {
    final maxWidth = size.width;
    final sWidth = maxWidth / count;
    final offset = sWidth / 2;
    final r = radius;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      double x = (offset + (sWidth * i) + _getTranslateValue(t)) % maxWidth;
      double radOffset = 1;

      if (x / maxWidth < (1 / count)) {
        radOffset = (x / maxWidth) / (1 / count);
      }

      if (x / maxWidth > 1 - (1 / count)) {
        // radOffset = (x / maxWidth) / (1 - (1 / kEllipseCount));
        radOffset = ((1 - (x / maxWidth)) / (1 / count));
      }

      drawCircle(Offset(x, maxWidth / 2), r * radOffset, paint);
    }
  }

  double _getTranslateValue(double t) {
    double current = ((t * _speedModifier * speed) % size.width);
    double p = current / size.width;
    return size.width * curve.transform(p);
    // return prev + (segSize * next);
  }
}
