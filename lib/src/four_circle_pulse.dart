import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit_widget.dart';

/// The loading animation where four circles are animated. Circles are expanded
/// to the corners from the center. Then it is rotated 90 degree clockwise by
/// [turns]. Then the circles returns to center.
class FourCirclePulse extends StatelessWidget {
  const FourCirclePulse({
    Key? key,
    this.circleColor,
    this.dimension = 48.0,
    this.turns = 2,
    this.loopDuration = const Duration(milliseconds: 1500),
    this.curve,
  }) : super(key: key);

  /// The color of each circle. By default primary color from theme is used
  final Color? circleColor;

  /// The widget is square in size. Dimension refers to the length of the side or width or height. Default value is 48
  final double dimension;

  /// Defines the number of turns it takes in one loop. Each turn is 90 degree. Default value is 2
  final double turns;

  /// Duration of each loop. Default value is 1500 milliseconds.
  final Duration loopDuration;

  /// The curve of the animation. Default is [Curves.linear]
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: CanvasKit(
        delegate: _FourCirclePulseDelegate(
          color: circleColor ?? Theme.of(context).colorScheme.primary,
          curve: curve ?? Curves.linear,
          rotation: turns,
          phaseDuration: loopDuration,
        ),
      ),
    );
  }
}

class _FourCirclePulseDelegate extends CanvasKitDelegate {
  final Color color;
  final Curve curve;
  final double rotation;
  final Duration phaseDuration;

  _FourCirclePulseDelegate({
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
