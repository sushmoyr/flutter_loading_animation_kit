import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_loading_animation_kit/src/canvas/canvas_kit.dart';

class CanvasKit extends StatefulWidget {
  const CanvasKit({
    Key? key,
    required this.delegate,
    this.size = Size.zero,
  }) : super(key: key);

  final CanvasKitDelegate delegate;
  final Size size;

  @override
  State<CanvasKit> createState() => _CanvasKitState();
}

class _CanvasKitState extends State<CanvasKit>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<double> _time = ValueNotifier(0);
  late final Ticker _ticker = createTicker(_update);

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      willChange: _ticker.isActive,
      size: widget.size,
      painter: CanvasPainter(
        delegate: widget.delegate,
        time: _time,
      ),
    );
  }

  void _update(Duration elapsed) {
    _time.value = elapsed.inMicroseconds / 1e6;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }
}
