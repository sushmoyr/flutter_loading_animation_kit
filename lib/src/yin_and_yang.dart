import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit_widget.dart';

/// This loading animation animates the **Yin and Yang ☯** symbol.
class YinAndYang extends StatelessWidget {
  const YinAndYang({
    Key? key,
    this.loopDuration = const Duration(seconds: 2),
    this.curve = Curves.linear,
    this.yinColor = Colors.white,
    this.yangColor = Colors.black,
    this.dimension = 48.0,
  }) : super(key: key);

  /// Duration of each loop. Default value is 2 seconds.
  final Duration loopDuration;

  /// The curve of the animation. Default is [Curves.linear]
  final Curve curve;

  /// The color of the yin part. Default is [Colors.white]
  final Color yinColor;

  /// The color of the yang part. Default is [Colors.black]
  final Color yangColor;

  /// The widget is square in size. Dimension refers to the length of the side
  /// or width or height. Default value is 48
  final double dimension;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: CanvasKit(
        delegate: _YinAndYangDelegate(
          loopDuration: loopDuration,
          curve: curve,
          yinColor: yinColor,
          yangColor: yangColor,
        ),
      ),
    );
  }
}

class _YinAndYangDelegate extends CanvasKitDelegate {
  _YinAndYangDelegate({
    required this.yinColor,
    required this.yangColor,
    required this.curve,
    required this.loopDuration,
  });

  final Color yinColor;
  final Color yangColor;
  final Curve curve;
  final Duration loopDuration;

  @override
  void update(double t) {
    // double progress = (t % 15) / 15;
    // print(progress);
    //
    double outerRadius = size.width / 2 - 1;
    Offset center = size.center(Offset.zero);
    Paint border = Paint()
      ..color = yangColor
      ..style = PaintingStyle.stroke
      ..filterQuality = FilterQuality.high
      ..strokeWidth = 1;
    Paint yang = Paint()
      ..color = yangColor
      ..style = PaintingStyle.fill;
    Paint yin = Paint()
      ..color = yinColor
      ..style = PaintingStyle.fill;
    drawCircle(center, outerRadius, border);
    double innerRadius = outerRadius / 2;
    Path path = Path();
    path.moveTo(outerRadius, 0);
    path.arcToPoint(
      Offset(outerRadius, outerRadius),
      radius: Radius.circular(innerRadius),
    );
    path.arcToPoint(
      Offset(outerRadius, size.height),
      radius: Radius.circular(innerRadius),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(outerRadius, 0),
      radius: Radius.circular(outerRadius),
      clockwise: false,
    );
    path.close();

    double duration = loopDuration.inMilliseconds / 1000.0;
    double segment = t % duration;

    double progress = curve.transform(segment / duration);

    double maxAngle = 2 * pi;
    translate(size.width / 2, size.height / 2);
    rotate(maxAngle * progress);
    translate(-size.width / 2, -size.height / 2);

    drawPath(path, yang);

    drawCircle(Offset(outerRadius, innerRadius), innerRadius / 4, yang);
    drawCircle(Offset(size.width - outerRadius, size.height - innerRadius),
        innerRadius / 4, yin);

    // path.addArc(
    //     Rect.fromCircle(
    //         center: Offset(outerRadius, innerRadius), radius: innerRadius),
    //     0,
    //     pi / 2);
  }
}
