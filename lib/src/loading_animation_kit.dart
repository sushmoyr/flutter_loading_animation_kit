import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/flutter_loading_animation_kit.dart';

class LoadingAnimationKit {
  static Widget fourCirclePulse({
    Key? key,
    Color? circleColor,
    double dimension = 48.0,
    double turns = 2,
    Duration loopDuration = const Duration(milliseconds: 1500),
    Curve? curve,
  }) =>
      FourCirclePulse(
        key: key,
        circleColor: circleColor,
        dimension: dimension,
        turns: turns,
        loopDuration: loopDuration,
        curve: curve,
      );

  static Widget lineEllipsis({
    Key? key,
    double ellipseRadius = 8,
    int ellipseCount = 5,
    Color? ellipseColor,
    double speed = 4,
    Curve curve = Curves.linear,
  }) =>
      LineEllipsis(
        key: key,
        ellipseRadius: ellipseRadius,
        speed: speed,
        curve: curve,
        ellipseColor: ellipseColor,
        ellipseCount: ellipseCount,
      );

  static Widget rippleRing({
    Key? key,
    Color? rippleColor,
    Duration? frequency,
    Duration? timeToLive,
    double dimension = 48.0,
    double strokeWidth = 2,
    Curve curve = Curves.linear,
  }) =>
      RippleRing(
        key: key,
        rippleColor: rippleColor,
        frequency: frequency,
        timeToLive: timeToLive,
        dimension: dimension,
        strokeWidth: strokeWidth,
        curve: curve,
      );

  static Widget yinAndYang({
    Key? key,
    Duration loopDuration = const Duration(seconds: 2),
    Curve curve = Curves.linear,
    Color? yinColor,
    Color? yangColor,
    double dimension = 48.0,
  }) =>
      YinAndYang(
        key: key,
        loopDuration: loopDuration,
        curve: curve,
        yinColor: yinColor,
        yangColor: yangColor,
        dimension: dimension,
      );
}
