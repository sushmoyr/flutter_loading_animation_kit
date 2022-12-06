import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit_widget.dart';
import 'package:flutter_loading_animation_kit/src/utils/extensions/path_extensions.dart';

class CartLoading extends StatelessWidget {
  const CartLoading({
    Key? key,
    this.dimension,
    this.inactiveColor,
    this.activeColor,
    this.strokeWidth,
    this.curve,
    this.loopDuration,
  }) : super(key: key);

  final double? dimension;
  final Color? inactiveColor;
  final Color? activeColor;
  final double? strokeWidth;
  final Curve? curve;
  final Duration? loopDuration;

  @override
  Widget build(BuildContext context) {
    return CanvasKit(
      size: Size.square(dimension ?? 160.0),
      delegate: _CartLoadingDelegate(
        inactiveColor: inactiveColor ?? Theme.of(context).disabledColor,
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        strokeWidth: strokeWidth != null
            ? strokeWidth!
            : (dimension != null)
                ? dimension! / 16
                : 10,
        curve: curve ?? Curves.decelerate,
        loopDuration: loopDuration ?? const Duration(milliseconds: 2500),
      ),
    );
  }
}

class _CartLoadingDelegate extends CanvasKitDelegate {
  final Color inactiveColor;
  final Color activeColor;
  final double strokeWidth;
  final Curve curve;
  final Duration loopDuration;

  _CartLoadingDelegate({
    required this.inactiveColor,
    required this.activeColor,
    required this.strokeWidth,
    required this.curve,
    required this.loopDuration,
  });

  @override
  void update(double t) {
    double totalTime = loopDuration.inMilliseconds * 1.0;
    double time = ((t * 1000) % totalTime);
    double timeProgress = time / totalTime;

    drawRect(
        Offset.zero & size,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke);

    Offset viewPort = const Offset(126, 126);
    List<Offset> pathPoints = const [
      Offset(0, 0),
      Offset(19, 0),
      Offset(27, 22),
      Offset(126, 22),
      Offset(110, 63),
      Offset(27, 63),
      Offset(35, 84),
      Offset(110, 84),
    ];

    Paint activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Paint inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Size renderArea = Size.square(size.longestSide - (2 * strokeWidth));

    double wheelOuterRadius = size.height * 0.1;
    Offset rightWheelCenter = Offset(size.width - (size.width * 0.3),
        size.height - strokeWidth - wheelOuterRadius);
    Offset leftWheelCenter =
        Offset(size.width * 0.3, size.height - strokeWidth - wheelOuterRadius);
    drawCircle(rightWheelCenter, wheelOuterRadius, inactivePaint);
    drawCircle(leftWheelCenter, wheelOuterRadius, inactivePaint);

    double angleOffset = 6 * pi * timeProgress;

    List<Offset> points = pathPoints.map((e) {
      double xP = e.dx / viewPort.dx;
      double yP = e.dy / viewPort.dy;
      return Offset(renderArea.width * xP, renderArea.height * yP) +
          Offset(strokeWidth, strokeWidth);
    }).toList();

    Path path = Path()..moveTo(points.first.dx, points.first.dy);
    Rect arcRectRight =
        Rect.fromCircle(center: rightWheelCenter, radius: wheelOuterRadius);

    Rect arcRectLeft =
        Rect.fromCircle(center: leftWheelCenter, radius: wheelOuterRadius);

    for (var p in points) {
      path.lineTo(p.dx, p.dy);
    }

    drawPath(path, inactivePaint);

    if (timeProgress <= 0.4) {
      //go forward direction
      // print('Forward ${timeProgress / 0.4}');
      double pathProgress = curve.transform(timeProgress / 0.4);
      double sweep = 2 * pi * 0.6;
      drawPath(
        path.createAnimatedPath(1 - pathProgress, reverse: true),
        activePaint,
      );

      drawArc(arcRectRight, (pi / 2) + angleOffset, sweep * pathProgress, false,
          activePaint);

      drawArc(arcRectLeft, (-pi / 2) + angleOffset, sweep * pathProgress, false,
          activePaint);
    } else if (timeProgress > 0.6) {
      double pathProgress = curve.transform((1 - timeProgress) / 0.4);
      double sweep = 2 * pi * 0.6;
      drawPath(
        path.createAnimatedPath(pathProgress),
        activePaint,
      );

      drawArc(arcRectRight, (pi / 2) + angleOffset, sweep * pathProgress, false,
          activePaint);

      drawArc(arcRectLeft, (-pi / 2) + angleOffset, sweep * pathProgress, false,
          activePaint);
    } else {
      double sweep = 2 * pi * 0.6;
      drawPath(path, activePaint);
      drawArc(arcRectRight, (pi / 2) + angleOffset, sweep, false, activePaint);

      drawArc(arcRectLeft, (-pi / 2) + angleOffset, sweep, false, activePaint);
    }
  }
}
