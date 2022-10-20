import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit_widget.dart';

/// This creates a widget that displays several rings with ripple effect.
class RippleRing extends StatelessWidget {
  const RippleRing({
    Key? key,
    this.rippleColor,
    this.frequency,
    this.timeToLive,
    this.dimension = 48.0,
    this.strokeWidth = 2,
    this.curve = Curves.linear,
  }) : super(key: key);

  /// The color of the rings of ripples. Default is primary color from theme
  final Color? rippleColor;

  /// Frequency of rings to appear. Default is 1 second.
  final Duration? frequency;

  /// Duration of a ring to stay in the view. Default is 3 second
  final Duration? timeToLive;

  /// Size of the widget. Default is 48.0
  final double dimension;

  /// Width of stroke of rings. Default is 2.0
  final double strokeWidth;

  /// The curve that controls the speed at which rings are spread. Default is
  /// [Curves.linear]
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return CanvasKit(
      delegate: _RippleRingDelegate(
        rippleColor: rippleColor ?? Theme.of(context).colorScheme.primary,
        frequency: frequency ?? const Duration(seconds: 1),
        timeToLive: timeToLive ?? const Duration(seconds: 3),
        strokeWidth: strokeWidth,
        curve: curve,
      ),
      size: Size.square(dimension),
    );
  }
}

class _RippleRingDelegate extends CanvasKitDelegate {
  _RippleRingDelegate({
    required this.rippleColor,
    required this.frequency,
    required this.timeToLive,
    required this.strokeWidth,
    required this.curve,
  });

  final Color rippleColor;
  final Duration frequency;
  final Duration timeToLive;
  final double strokeWidth;
  final Curve curve;

  final List<Duration> _spawnTime = [];

  void spawn(double t) {
    _spawnTime.add(Duration(milliseconds: (t * 1000).toInt()));
  }

  @override
  void update(double t) {
    Duration current = Duration(milliseconds: (t * 1000).toInt());

    if (_spawnTime.isEmpty ||
        current - _spawnTime[_spawnTime.length - 1] > frequency) {
      spawn(t);
    }

    _renderRipples(t);
  }

  void _renderRipples(double t) {
    Offset center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2.0;

    List<Duration> pointsToRemove = [];

    for (Duration startPoint in _spawnTime) {
      Duration currentFrame = Duration(milliseconds: (t * 1000).toInt());
      Duration elapsed = currentFrame - startPoint;
      if (elapsed > timeToLive) {
        pointsToRemove.add(startPoint);
      } else {
        double progress = (elapsed.inMilliseconds / timeToLive.inMilliseconds);
        Paint paint = Paint()
          ..color = rippleColor.withOpacity(1 - progress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
        drawCircle(center, maxRadius * curve.transform(progress), paint);
      }
    }

    for (Duration d in pointsToRemove) {
      _spawnTime.remove(d);
    }
  }
}
