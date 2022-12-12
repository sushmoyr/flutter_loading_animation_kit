import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit_widget.dart';

class MerryGoRound extends StatelessWidget {
  const MerryGoRound({
    Key? key,
    this.dimension,
    this.curve,
    this.outlineColor,
    this.merryColor,
    this.loopDuration,
    this.outlineStrokeWidth,
  }) : super(key: key);

  final double? dimension;
  final Curve? curve;
  final Color? outlineColor;
  final Color? merryColor;
  final Duration? loopDuration;
  final double? outlineStrokeWidth;

  @override
  Widget build(BuildContext context) {
    return CanvasKit(
      size: Size.square(dimension ?? 48),
      delegate: _MerryGoRoundDelegate(
        curve: curve ?? Curves.easeInOutSine,
        outlineColor: outlineColor ?? Theme.of(context).colorScheme.primary,
        merryColor: merryColor ?? Theme.of(context).colorScheme.primary,
        loopDuration: loopDuration ?? const Duration(milliseconds: 80),
        outlineStrokeWidth: outlineStrokeWidth ?? 3,
      ),
    );
  }
}

class _MerryGoRoundDelegate extends CanvasKitDelegate {
  final Curve curve;
  final Color outlineColor;
  final Color merryColor;
  final Duration loopDuration;
  final double outlineStrokeWidth;

  _MerryGoRoundDelegate({
    required this.curve,
    required this.outlineColor,
    required this.merryColor,
    required this.loopDuration,
    required this.outlineStrokeWidth,
  });

  @override
  void update(double t) {
    double time =
        ((t * 100) % loopDuration.inMilliseconds) / loopDuration.inMilliseconds;
    double timeOffset = curve.transform(time);
    Paint outlineStroke = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineStrokeWidth;
    Offset center = size.center(Offset.zero);
    double radius = (size.shortestSide / 2) - outlineStrokeWidth;
    drawCircle(center, radius, outlineStroke);

    Paint merryPaint = Paint()
      ..color = merryColor
      ..style = PaintingStyle.fill;
    double merryRadius = radius * 0.25;
    Offset merryCenter =
        Offset.fromDirection((-pi / 2) + ((2 * pi) * timeOffset), radius * 0.5);
    drawCircle(center + merryCenter, merryRadius, merryPaint);
  }
}
