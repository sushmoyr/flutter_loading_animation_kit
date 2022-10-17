import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit_widget.dart';

class FourCirclePulse extends StatelessWidget {
  const FourCirclePulse({
    Key? key,
    this.circleColor,
    this.dimension = 48.0,
    this.rotation = 2,
    this.loopDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  final Color? circleColor;
  final double dimension;
  final double rotation;
  final Duration loopDuration;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: CanvasKit(
        delegate: FourCirclePulseDelegate(
          color: circleColor ?? Theme.of(context).colorScheme.primary,
          curve: Curves.linear,
          rotation: rotation,
          phaseDuration: loopDuration,
        ),
      ),
    );
  }
}

class FourCirclePulseDelegate extends CanvasKitDelegate {
  final Color color;
  final Curve curve;
  final double rotation;
  final Duration phaseDuration;

  FourCirclePulseDelegate({
    required this.color,
    required this.curve,
    required this.rotation,
    required this.phaseDuration,
  });

  @override
  void update(double t) {
    //
    double duration = phaseDuration.inMilliseconds / 1000.0;
    double segment = t % duration;

    double progress = curve.transform(segment / duration);
    // print('Progress : $progress');

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (progress <= 0.3) {
      //we will expand the circles here
      final outProgress = progress / 0.3;
      // print('Out Progress : $outProgress');
      renderCircle(paint, outProgress);
    } else if (progress > 0.7) {
      //we will close the circles here
      final inProgress = (1 - progress) / 0.3;
      // print('In Progress : ${inProgress}');
      renderCircle(paint, inProgress);
    } else {
      double stayProgress = (progress - 0.3) / (0.4);
      double maxAngle = (pi / 2) * rotation;

      translate(size.width / 2, size.height / 2);
      rotate(maxAngle * stayProgress);
      translate(-size.width / 2, -size.height / 2);
      renderCircle(paint, 1);
    }
  }

  void renderCircle(Paint paint, double threshold) {
    double radius = (size.width * 0.3) / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 4; i++) {
      Offset direction = Offset.fromDirection(
          (pi / 2) * i, ((size.height / 2) - radius) * threshold);
      drawCircle(center + direction, radius, paint);
    }
  }
}
